#ifndef FAT16_H
#define FAT16_H

struct ptab {
	unsigned char flags;
	unsigned char sh, scl, sch;
	unsigned char type;
	unsigned char eh, ecl, ech;
	unsigned char lba[4];
	unsigned char size[4];
};

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

struct fat16_file {
	struct fat16_handle *h;
	int pos;
	int start_cluster;
	int cluster;
	int len;
};


extern int fat16_find_partition();
extern int fat16_open(struct fat16_handle *h, int start);
extern void fat16_ls_root(struct fat16_handle *h, void (*cbfn)(struct fat16_handle *, struct fat16_dirent *, void *), void *priv);
extern int fat16_get_next_cluster(struct fat16_handle *h, int cluster);
extern void fat16_open_by_de(struct fat16_handle *h, struct fat16_file *fd, struct fat16_dirent *de);
extern int fat16_open_by_name(struct fat16_handle *h, struct fat16_file *fd, char *name);
extern int fat16_read(struct fat16_file *fd, unsigned char *buf, int len);

#endif
