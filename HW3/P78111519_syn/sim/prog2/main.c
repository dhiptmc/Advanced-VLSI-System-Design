#include <stdint.h>

#define MIP_MEIP (1 << 11) // External interrupt pending
#define MIP_MTIP (1 << 7)  // Timer interrupt pending
#define MIP 0x344

volatile unsigned int *WDT_addr = (int *) 0x10010000;
volatile unsigned int *dma_addr_boot = (int *) 0x10020000;




void timer_interrupt_handler(void) {
  asm("csrsi mstatus, 0x0"); // MIE of mstatus
  WDT_addr[0x40] = 0; // WDT_en
  asm("j _start");
}

void external_interrupt_handler(void) {
	volatile unsigned int *dma_addr_boot = (int *) 0x10020000;
	asm("csrsi mstatus, 0x0"); // MIE of mstatus
	dma_addr_boot[0x40] = 0; // disable DMA
} 

void trap_handler(void) {
    uint32_t mip;
    asm volatile("csrr %0, %1" : "=r"(mip) : "i"(MIP));
	
    if ((mip & MIP_MTIP) >> 7) {
        timer_interrupt_handler();
    }

    if ((mip & MIP_MEIP) >> 11) {
        external_interrupt_handler();
    }
}

int main(void) {
    extern char _test_start;
    extern char _binary_image_bmp_start;        //start addr of colored img
    extern char _binary_image_bmp_end;          //end addr of colored img
    extern unsigned int _binary_image_bmp_size; //total length of colored img

    int i;
    for(i=0; i<54; i++)
        (&_test_start)[i]=(&_binary_image_bmp_start)[i];

    int j;
    int b=0,g=0,r=0;
    for(j=54; j < &_binary_image_bmp_size; j=j+3){
        int result=0, tmp=0;
        b=(&_binary_image_bmp_start)[j];
        g=(&_binary_image_bmp_start)[j+1];
        r=(&_binary_image_bmp_start)[j+2];

        tmp=b<<16;
        result+=tmp;
        tmp=b<<15;
        result+=tmp;
        tmp=b<<14;
        result+=tmp;
        tmp=b<<9;
        result+=tmp;
        tmp=b<<7;
        result+=tmp;
        tmp=b<<4;
        result+=tmp;

        tmp=g<<19;
        result+=tmp;
        tmp=g<<16;
        result+=tmp;
        tmp=g<<14;
        result+=tmp;
        tmp=g<<13;
        result+=tmp;
        tmp=g<<12;
        result+=tmp;
        tmp=g<<7;
        result+=tmp;
        tmp=g<<5;
        result+=tmp;
        tmp=g<<2;
        result+=tmp;

        tmp=r<<18;
        result+=tmp;
        tmp=r<<15;
        result+=tmp;
        tmp=r<<14;
        result+=tmp;
        tmp=r<<11;
        result+=tmp;
        tmp=r<<10;
        result+=tmp;
        tmp=r<<7;
        result+=tmp;
        tmp=r<<6;
        result+=tmp;
        tmp=r<<3;
        result+=tmp;
        tmp=r<<2;
        result+=tmp;
        result+=r;

        result = result >> 20;

        (&_test_start)[j]=result;
        (&_test_start)[j+1]=result;
        (&_test_start)[j+2]=result;
    }
    return 0;
}
