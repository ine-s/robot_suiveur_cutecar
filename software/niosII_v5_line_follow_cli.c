#include <stdint.h>
#include <stdio.h>

/* PIO map from nios_v5_system.qsys (data master map). */
#define VECT_POS_BASE  0x00000100u
#define NIVEAU_BASE    0x00000110u
#define PORT_S_BASE    0x00000120u
#define BASE_DUTY_BASE 0x00000130u
#define PORT_E_BASE    0x00000140u

#define REG8(addr)  (*(volatile uint8_t  *)(addr))
#define REG32(addr) (*(volatile uint32_t *)(addr))

#define VECT_POS   REG32(VECT_POS_BASE)
#define NIVEAU     REG8(NIVEAU_BASE)
#define PORT_S     REG32(PORT_S_BASE)
#define BASE_DUTY  REG32(BASE_DUTY_BASE)
#define PORT_E     REG32(PORT_E_BASE)

#define START_SL_MASK 0x1u

static void print_help(void)
{
	printf("Commands:\n");
	printf("  g        start line-follow (start_SL=1)\n");
	printf("  s        stop line-follow (start_SL=0)\n");
	printf("  b <0..4095>  set base duty\n");
	printf("  n <0..255>   set threshold (niveau)\n");
	printf("  p        print status\n");
	printf("  h        print this help\n");
}

static void print_status(void)
{
	uint32_t vect = VECT_POS & 0x7Fu;
	uint32_t port_s = PORT_S & 0x7u;
	uint32_t port_e = PORT_E & 0x3u;

	printf("STATUS: PORT_S=0x%01lX, PORT_E=0x%01lX, VECT_POS=0x%02lX, BASE_DUTY=%lu, NIVEAU=%u\n",
		(unsigned long)port_s,
		(unsigned long)port_e,
		(unsigned long)vect,
		(unsigned long)(BASE_DUTY & 0x0FFFu),
		(unsigned)NIVEAU);
}

static void drain_line(void)
{
	int c;
	while ((c = getchar()) != '\n' && c != '\r' && c != EOF) { }
}

int main(void)
{
	/* Auto init */
	NIVEAU    = 0x6C;          // 108
	BASE_DUTY = 0x0900;        // duty only (2304 decimal)
	PORT_S    = 0;             // stopped by default

	printf("Init: NIVEAU=0x6C, BASE_DUTY=0x900\n");
	print_help();
	print_status();

	while (1)
	{
		int c = getchar();
		if (c == EOF) continue;

		if (c == 'g') {
			PORT_S = PORT_S | START_SL_MASK;
			printf("GO (start_SL=1)\n");
		}
		else if (c == 's') {
			PORT_S = PORT_S & ~START_SL_MASK;
			printf("STOP (start_SL=0)\n");
		}
		else if (c == 'b') {
			int v;
			if (scanf("%d", &v) == 1) {
				if (v < 0) v = 0;
				if (v > 4095) v = 4095;
				BASE_DUTY = (uint32_t)(v & 0x0FFFu);
				printf("BASE_DUTY=%d\n", v);
			}
			drain_line();
		}
		else if (c == 'n') {
			int v;
			if (scanf("%d", &v) == 1) {
				if (v < 0) v = 0;
				if (v > 255) v = 255;
				NIVEAU = (uint8_t)v;
				printf("NIVEAU=%d (0x%02X)\n", v, (unsigned)v);
			}
			drain_line();
		}
		else if (c == 'p') {
			print_status();
		}
		else if (c == 'h') {
			print_help();
		}
	}
}