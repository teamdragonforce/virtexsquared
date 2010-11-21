#include "sysace.h"
#include "minilib.h"
#include "fat16.h"

#define FAT16_FAT0_SECTOR(h) ((h)->start + (h)->reserved_sector_count)
#define FAT16_FAT1_SECTOR(h) ((h)->start + (h)->reserved_sector_count + (h)->sectors_per_fat)
#define FAT16_ROOT_SECTOR(h) ((h)->start + (h)->reserved_sector_count + (h)->sectors_per_fat * (h)->num_fats)
#define FAT16_FIRST_CLUSTER(h) (FAT16_ROOT_SECTOR(h) + (h)->max_root_dirents * 32 / 512)
#define FAT16_CLUSTER(h, n) (FAT16_FIRST_CLUSTER(h) + (n - 2) * (h)->sectors_per_cluster)
#define FAT16_CLUSTER_IS_EOF(c) ((c) == 0xFFF8 || (c) == 0xFFF9 || (c) == 0xFFFA || (c) == 0xFFFB || (c) == 0xFFFC || (c) == 0xFFFD || (c) == 0xFFFE || (c) == 0xFFFF)
#define FAT16_BYTES_PER_CLUSTER(h) ((h)->sectors_per_cluster * 512)

int fat16_find_partition()
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
			return table[i].lba[0] |
			       table[i].lba[1] << 8 |
			       table[i].lba[2] << 16 |
			       table[i].lba[3] << 24;
		}
	}
	
	return -1;
}

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


void fat16_ls_root(struct fat16_handle *h, void (*cbfn)(struct fat16_handle *, struct fat16_dirent *, void *), void *priv)
{
	int i;
	static unsigned char buf[512];
	struct fat16_dirent *de = (struct fat16_dirent *)buf;
	
	for (i = 0; i < h->max_root_dirents; i++)
	{
		int idx = i % (512 / 32);
		
        	if (idx == 0) 
        	{
        		if (sysace_readsec(FAT16_ROOT_SECTOR(h) + (i * 32) / 512, (unsigned int *)buf))
        		{
        			puts("failed to read FAT16 root sector!\r\n");
        			return;
        		}
        	}
        	
        	cbfn(h, &de[idx], priv);
	}
}

int fat16_get_next_cluster(struct fat16_handle *h, int cluster)
{
	static unsigned short buf[256];
	
	if (sysace_readsec(FAT16_FAT0_SECTOR(h) + cluster / 256, (unsigned int *) buf))
	{
		puts("failed to read FAT!");
		return 0xFFF7;	/* bad sector */
	}
	
	return buf[cluster % 256];
}

void fat16_open_by_de(struct fat16_handle *h, struct fat16_file *fd, struct fat16_dirent *de)
{
	fd->h = h;
	fd->pos = 0;
	fd->start_cluster = de->start_cluster[0] | ((unsigned int)de->start_cluster[1] << 8);
	fd->cluster = fd->start_cluster;
	fd->len = de->size[0] | ((unsigned int)de->size[1] << 8) |
	          ((unsigned int)de->size[2] << 16) | ((unsigned int)de->size[3] << 24);
}

struct _open_by_name_priv {
	unsigned char fnameext[12];
	struct fat16_file *fd;
	int found;
};

static void _open_by_name_callback(struct fat16_handle *h, struct fat16_dirent *de, void *_priv)
{
	struct _open_by_name_priv *priv = _priv;
	
       	if (de->name[0] == 0x00 || de->name[0] == 0x05 || de->name[0] == 0xE5 || (de->attrib & 0x48))
       		return;
	
	if (!memcmp(priv->fnameext, de->name, 11))
	{
		fat16_open_by_de(h, priv->fd, de);
		priv->found = 1;
	}
}

int fat16_open_by_name(struct fat16_handle *h, struct fat16_file *fd, char *name)
{
	struct _open_by_name_priv priv;
	
	memcpy(priv.fnameext, name, 11);	/* XXX */
	priv.fnameext[11] = 0;
	priv.found = 0;
	priv.fd = fd;
	
	fat16_ls_root(h, _open_by_name_callback, (void *)&priv);
	
	return priv.found ? 0 : -1;
}

int fat16_read(struct fat16_file *fd, unsigned char *buf, int len)
{
	int retlen = 0;
	
	len = (len > (fd->len - fd->pos)) ? (fd->len - fd->pos) : len;
	
	while (len && !FAT16_CLUSTER_IS_EOF(fd->cluster))
	{
		int cluslen;
		int rem = FAT16_BYTES_PER_CLUSTER(fd->h) - fd->pos % FAT16_BYTES_PER_CLUSTER(fd->h);
		
		cluslen = (rem > len) ? len : rem;
		
		while (cluslen)
		{
			static unsigned char secbuf[512];
			int seclen = 512 - fd->pos % 512;
			seclen = (seclen > cluslen) ? cluslen : seclen;
			
			int secnum = FAT16_CLUSTER(fd->h, fd->cluster) + (fd->pos / 512) % fd->h->sectors_per_cluster;
			
			if (sysace_readsec(secnum, (unsigned int *)secbuf))
			{
				puts("failed to read sector!");
				return retlen ? retlen : -1;
			}
			
			memcpy(buf, secbuf + fd->pos % 512, seclen);
			
			retlen += seclen;
			buf += seclen;
			fd->pos += seclen;
			cluslen -= seclen;
			len -= seclen;
		}
		
		if ((fd->pos % FAT16_BYTES_PER_CLUSTER(fd->h)) == 0)
			fd->cluster = fat16_get_next_cluster(fd->h, fd->cluster);
	}
	
	return retlen;
}
