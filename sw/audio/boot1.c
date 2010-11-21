#include "serial.h"
#include "sysace.h"
#include "audio.h"
#include "keyhelp.h"

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
		puts("failed to read sector 0!");
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

void loadaudio()
{
	int location = find_fat16();
	unsigned int *base = (int*) 0x00800000;
	int i;

	if (location < 0)
	{
		puts("no FAT16-now-audio partition?");
		return;
	}
	printf("Loading audio into memory (%d sectors)...", LEN/512);
	for (i = 0; i < (LEN / 512); i++)
	{
		sysace_readsec(location + i, base);
		base += (512/4);
		if ((i & 0x1F) == 0)
		{
			puthex(i);
			if (i == 0x20)	/* OK, we've loaded enough. */
				audio_play((void*) 0x00800000, LEN, AUDIO_MODE_LOOP);
		}
		putchar('.');
	}
	puts("\r\n");
}

int main()
{
	loadaudio();

	char ch;
	volatile unsigned int *scancode_addr = (unsigned int *) 0x85000000;
	unsigned int scancode;
	kh_type k;

	int volume = 255;
	int mute = 0;

	while (1) {
		scancode = *scancode_addr;
		if (scancode == 0xffffffff)
			continue;
		k = process_scancode(scancode);
		if (KH_HAS_CHAR(k) && !KH_IS_RELEASING(k)) {
			ch = KH_GET_CHAR(k);
			if (ch == 'q' && volume < 255) volume++;
			if (ch == 'a' && volume > 0) volume--;
			if (ch == 'm' && volume > 0) mute = !mute;
			printf("%c %d %d\r\n", ch, mute, volume);
			audio_master_volume_set(mute, volume, volume);
		}
	}

	return 0;
}
