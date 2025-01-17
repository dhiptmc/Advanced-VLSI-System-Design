//Bootloader introduction:
//  The first program that CPU will execute after reset state
//  Used to load main programs or OS to faster memories.

//The booting program is stored in ROM
//Booting program will move instr & data from DRAM to IM and DM

void boot() {
    extern unsigned int _dram_i_start;       //instruction start address in DRAM.
    extern unsigned int _dram_i_end;         //instruction end address in DRAM.
    extern unsigned int _imem_start;         //instruction start address in IM

    extern unsigned int __sdata_start;       //main data start address in DM.
    extern unsigned int __sdata_end;         //main data end address in DM.
    extern unsigned int __sdata_paddr_start; //main data start address in DRAM

    extern unsigned int __data_start;        //main data start address in DM.
    extern unsigned int __data_end;          //main data end address in DM.
    extern unsigned int __data_paddr_start;  //main data start address in DRAM

    volatile unsigned int *dma_addr_boot = (int *) 0x10020000;
  
    asm("li t0, 0x800");
    asm("csrw mie, t0"); // MEIE of mie -> [11] MEIE 機器模式外部中斷允許位
    //DMA source addr
    dma_addr_boot[0x80] = (unsigned int)&_dram_i_start;
    //DMA destination addr
    dma_addr_boot[0xC0] = (unsigned int)&_imem_start;
    //DMA len
    dma_addr_boot[0x100]= (unsigned int)&_dram_i_end - (unsigned int)&_dram_i_start + 1;
    //Enable DMA Controller
    dma_addr_boot[0x40] = 1; // Enable DMA (DMAEN)
    asm("wfi");

    asm("li t0, 0x800");
    asm("csrw mie, t0");
    //DMA source addr
    dma_addr_boot[0x80] = (unsigned int)&__sdata_paddr_start;
    //DMA destination addr
    dma_addr_boot[0xC0] = (unsigned int)&__sdata_start;
    //DMA len
    dma_addr_boot[0x100]= (unsigned int)&__sdata_end - (unsigned int)&__sdata_start + 1;
    //Enable DMA Controller
    dma_addr_boot[0x40] = 1;
    asm("wfi");

    asm("li t0, 0x800");
    asm("csrw mie, t0");
    //DMA source addr
    dma_addr_boot[0x80] = (unsigned int)&__data_paddr_start;
    //DMA destination addr
    dma_addr_boot[0xC0] = (unsigned int)&__data_start;
    //DMA len
    dma_addr_boot[0x100]= (unsigned int)&__data_end - (unsigned int)&__data_start + 1;
    //Enable DMA Controller
    dma_addr_boot[0x40] = 1;
    asm("wfi");

    asm("li t0, 0x000");
    asm("csrw mie, t0");
}