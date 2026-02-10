#define switches (volatile char *) 0x02003000
#define leds (char *) 0x02003010
void main()
{ 		while (1)
		*leds = *switches;
}