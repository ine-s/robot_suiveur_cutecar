#define switches (volatile char *) 0x0003000
#define leds (char *) 0x0003010
void main()
{ while (1)
*leds = *switches;
}