#include "serial.h"
#include "sysace.h"

#define SAMPLE_RATE 48000
#define F 1000
#define T (SAMPLE_RATE / F)

struct ptab {
	unsigned char flags;
	unsigned char sh, scl, sch;
	unsigned char type;
	unsigned char eh, ecl, ech;
	unsigned char lba[4];
	unsigned char size[4];
};

int find_fat16()
{
	static unsigned char buf[512];
	struct ptab *table;
	int i;
	
	if (sysace_readsec(0, (unsigned int *)buf) < 0)
	{
		puts("failed to read sector 0!\r\n");
		return -1;
	}
	
	table = (struct ptab *)&(buf[446]);
	for (i = 0; i < 4; i++)
	{
		if (table[i].type == 0x06 /* FAT16 */)
		{
			puts("(partition ");
			puthex(i);
			puts(") ");
			return table[i].lba[0] |
			       table[i].lba[1] << 8 |
			       table[i].lba[2] << 16 |
			       table[i].lba[3] << 24;
		}
	}
	
	return -1;
}

//#define LEN 85258656
//#define LEN 85258624
#define LEN    1000032

void startplayback()
{
	volatile int *dma_start  = (int*) 0x84000000;
	volatile int *dma_length = (int*) 0x84000004;
	volatile int *dma_cmd    = (int*) 0x84000008;
	volatile int *dma_nread  = (int*) 0x8400000c;

	*dma_start = 0x00800000;
	*dma_length = LEN & ~0xFF;
	puthex(LEN & ~0xFF);
	*dma_cmd = 2;
}

void loadaudio()
{
	int location = find_fat16();
	unsigned int *base = 0x00800000;
	int i;

	if (location < 0)
	{
		puts("no FAT16-now-audio partition?\r\n");
		return;
	}
	puts("Loading audio into memory (");
	puthex(LEN/512);
	puts(" sectors)... ");
	for (i = 0; i < (LEN / 512); i++)
	{
		sysace_readsec(location + i, base);
		base += (512/4);
		if ((i & 0x1F) == 0)
		{
			puthex(i);
			if (i == 0x20)	/* OK, we've loaded enough. */
				startplayback();
		}
		puts(".");
	}
	puts("\r\n");
}

void main()
{
	short *mem = (short*) (6 * (1<<20));

	loadaudio();

	return 0;
}
