#include "serial.h"
#include "sysace.h"
#include "minilib.h"

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
			printf("(partition %d) ", i);
			return table[i].lba[0] |
			       table[i].lba[1] << 8 |
			       table[i].lba[2] << 16 |
			       table[i].lba[2] << 24;
		}
	}
	
	return -1;
}

void main()
{
	puts("boot1 running\r\n\r\n");
	int fat16_start;
	
	sysace_init();
	
	puts("Reading partition table... ");
	fat16_start = find_fat16();
	if (fat16_start < 0)
	{
		printf("no FAT16 partition found!\r\n");
		return;
	}
	printf("found starting at sector %d\r\n", fat16_start);
	
	return;
}