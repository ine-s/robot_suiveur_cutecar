#include <stdio.h>
#include <unistd.h>
#include <stdint.h>

/* Remplacer par vos vraies adresses */
#define DATA0_BASE      0x00000030
#define DATAREADY_BASE  0x00000020

int main(void)
{
    volatile uint32_t *data0_ptr     = (volatile uint32_t *) DATA0_BASE;
    volatile uint32_t *dataready_ptr = (volatile uint32_t *) DATAREADY_BASE;
	
	volatile int i;
	
    uint32_t data0;
    uint32_t ready;
	
	printf("Lecture capteur \n");

	while(1){
		
		/* Lecture du PIO data_ready */
		ready = (*dataready_ptr) & 0x01;
		

		if(ready){
			/* Lecture du PIO data0 */
			data0 = (*data0_ptr) & 0xFF;

			printf("data0 = %lu\n", (unsigned long)data0);
		}
	}
	

    return 0;
}