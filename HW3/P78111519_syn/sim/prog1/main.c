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

extern unsigned int array_size;
extern short array_addr;
extern short _test_start;

int main() {
    int i, j, key;

    for (i = 1; i < array_size; i++)
    {
        key = (&array_addr)[i];
        j = i - 1;

        while (j >= 0 && (&array_addr)[j] > key)
        {
            (&array_addr)[j + 1] = (&array_addr)[j];
            j = j - 1;
        }

        (&array_addr)[j + 1] = key;
    }

    for (i = 0; i < array_size; i++)
    {
        (&_test_start)[i] = (&array_addr)[i];
    }

    return 0;
}
