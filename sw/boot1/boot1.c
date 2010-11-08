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
			printf("(partition ");
			puthex(i);
			printf(") ");
			return table[i].lba[0] |
			       table[i].lba[1] << 8 |
			       table[i].lba[2] << 16 |
			       table[i].lba[3] << 24;
		}
	}
	
	return -1;
}

struct fat16_handle {
	unsigned int start;
	
	unsigned int bytes_per_sector;
	unsigned int sectors_per_cluster;
	unsigned int reserved_sector_count;
	unsigned int num_fats;
	unsigned int max_root_dirents;
	unsigned int sectors_per_fat;
};

struct fat16_bootsect {
	unsigned char jmp[3];
	unsigned char oemname[8];
	unsigned char bytes_per_sector[2];
	unsigned char sectors_per_cluster;
	unsigned char reserved_sector_count[2];
	unsigned char num_fats;
	unsigned char max_root_dirents[2];
	unsigned char total_sectors_old[2];
	unsigned char media_descriptor;
	unsigned char sectors_per_fat[2];
	unsigned char sectors_per_track[2];
	unsigned char number_of_heads[2];
	unsigned char hidden_sector_count[4];
	unsigned char total_sectors_new[4];
};

struct fat16_dirent {
	unsigned char name[8];
	unsigned char ext[3];
	unsigned char attrib;
	unsigned char reserved;
	unsigned char ctime[3];
	unsigned char cdate[2];
	unsigned char adate[2];
	unsigned char eaindex[2];
	unsigned char mtime[2];
	unsigned char mdate[2];
	unsigned char start_cluster[2];
	unsigned char size[4];
};

int fat16_open(struct fat16_handle *h, int start)
{
	static unsigned char buf[512];
	struct fat16_bootsect *bs = (struct fat16_bootsect *)buf;
	
	h->start = start;
	
	if (sysace_readsec(start, (unsigned int *)buf) < 0)
	{
		printf("failed to read FAT16 boot sector!\r\n");
		return -1;
	}
	
	h->bytes_per_sector = bs->bytes_per_sector[0] |
	                      (bs->bytes_per_sector[1] << 8);
	h->sectors_per_cluster = bs->sectors_per_cluster;
	h->reserved_sector_count = bs->reserved_sector_count[0] |
	                           (bs->reserved_sector_count[1] << 8);
	h->num_fats = bs->num_fats;
	h->max_root_dirents = bs->max_root_dirents[0] |
	                      (bs->max_root_dirents[1] << 8);
	h->sectors_per_fat = bs->sectors_per_fat[0] |
	                     (bs->sectors_per_fat[1] << 8);
	
	if (h->bytes_per_sector != 512)
	{
        	printf("FAT16: invalid number of bytes per sector\r\n");
        	return -1;
	}
	
	return 0;
}

#define FAT16_FAT0_SECTOR(h) ((h)->start + (h)->reserved_sector_count)
#define FAT16_FAT1_SECTOR(h) ((h)->start + (h)->reserved_sector_count + (h)->sectors_per_fat)
#define FAT16_ROOT_SECTOR(h) ((h)->start + (h)->reserved_sector_count + (h)->sectors_per_fat * (h)->num_fats)
#define FAT16_FIRST_CLUSTER(h) (FAT16_ROOT_SECTOR(h) + (h)->max_root_dirents * 32 / 512)
#define FAT16_CLUSTER(h, n) (FAT16_FIRST_CLUSTER(h) + n * (h)->sectors_per_cluster);

void main()
{
	int fat16_start;
	struct fat16_handle h;
	int i, j;
	static unsigned char buf[512];
	struct fat16_dirent *de = (struct fat16_dirent *)buf;

	puts("\r\n\r\nboot1 running\r\n\r\n");
	
	sysace_init();
	
	puts("Reading partition table... ");
	fat16_start = find_fat16();
	if (fat16_start < 0)
	{
		puts("no FAT16 partition found!\r\n");
		return;
	}
	puts("found starting at sector ");
	puthex(fat16_start);
	puts(".\r\n");
	
	puts("Opening FAT16 partition... ");
	if (fat16_open(&h, fat16_start) < 0)
	{
		puts("FAT16 boot sector read failed!\r\n");
		return;
	}
	puts("OK\r\n");
	
	puts("Listing all files in root directory...\r\n");
	for (i = 0; i < h.max_root_dirents; i++)
	{
        	if (((i * 32) & 511) == 0) 
        	{
        		if (sysace_readsec(FAT16_ROOT_SECTOR(&h) + (i * 32) / 512, (unsigned int *)buf))
        		{
        			puts("failed to read FAT16 root sector!\r\n");
        			return;
        		}
        		j = 0;
        	}
        	
        	if (de[j].name[0] == 0x00 || de[j].name[0] == 0x05 || de[j].name[0] == 0xE5 || (de[j].attrib & 0x48))
        	{
        		j++;
        		continue;
        	}
        	
        	printf("  %c%c%c%c%c%c%c%c.%c%c%c %s\r\n",
        	       de[j].name[0], de[j].name[1], de[j].name[2], de[j].name[3],
        	       de[j].name[4], de[j].name[5], de[j].name[6], de[j].name[7],
        	       de[j].ext[0], de[j].ext[1], de[j].ext[2],
        	       de[j].attrib & 0x10 ? "(dir)" : "(file)");
        	j++;
	}
	
	puts("boot1 exiting\r\n\r\n");
	
	return;
}
