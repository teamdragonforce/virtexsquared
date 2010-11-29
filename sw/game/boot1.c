#include "keyhelp.h"
#include "audio.h"
#include "fat16.h"
#include "minilib.h"
#include "accel.h"
#include "malloc.h"

#define MAX_QBEATS 50000
#define SCREEN_WIDTH 640
#define SCREEN_HEIGHT 480

struct stepfile {
	unsigned int len_qbeats;
	signed int samps_per_qbeat;
	signed int delay_samps;
	unsigned char qsteps[MAX_QBEATS];
};

int load_steps(struct fat16_handle * h, struct stepfile * song)
{
	int rv;
	struct fat16_file fd;
	
	printf("Opening STEPS.FM... ");
	if (fat16_open_by_name(h, &fd, "STEPS   FM ") == -1)
	{
		printf("not found?\r\n");
		return -1;
	} 
	
	rv = fat16_read(&fd, song, 3*sizeof(int));
	if (rv < 0) {
		printf("error reading initial song data (%d)\r\n", rv);
		return -1;
	}

	printf("%u %x, %u %x; length read %u %x\r\n", song->len_qbeats, song->len_qbeats, song->samps_per_qbeat, song->samps_per_qbeat, rv, rv);
	
	if (song->len_qbeats > MAX_QBEATS) {
		printf("song too long (%x qbeats)\r\n", song->len_qbeats);
		return -1;
	}
	
	rv = fat16_read(&fd, (void*)(&song->qsteps), song->len_qbeats*sizeof(char));
	if (rv < 0) {
		printf("error reading initial step data (%d)\r\n", rv);
		return -1;
	}

	printf("loaded! (%d bytes)\r\n", rv);
	return 0;
}

unsigned int *load_audio(struct fat16_handle * h, int *length)
{
	int rv;
	struct fat16_file fd;
	unsigned int *p;
	
	printf("Opening AUDIO.RAW... ");
	if (fat16_open_by_name(h, &fd, "AUDIO   RAW") == -1)
	{
		printf("not found?\r\n");
		return NULL;
	} 
	
	p = malloc(fd.len + 64);
	if (!p)
	{
		printf("malloc(%d) failed!\n", fd.len + 64);
		return NULL;
	}
	
	p = (unsigned int *)(((unsigned int)p + 64) & ~63);
	
	rv = fat16_read(&fd, (void*)p, fd.len);
	printf("loaded! (%d bytes)\r\n", rv);
	
	if (length)
		*length = rv;
	
	return p;
}

/*
 * Double buffering
 */
struct dbuf {
	unsigned int *bufs[2];
	unsigned int *bufs_orig[2];
	int which;
};

unsigned int *dbuf_flip(struct dbuf *dbuf)
{
	volatile unsigned int *frame_start = 0x82000000;
	volatile unsigned int *frame_nread = 0x8200000c;
	*frame_start = dbuf->bufs[dbuf->which];
	unsigned int read_last = *frame_nread;
	unsigned int read;
	while ((read = *frame_nread) >= read_last)
		read_last = read;
	dbuf->which = !dbuf->which;
	
	return dbuf->bufs[dbuf->which];
}

unsigned int *dbuf_init(struct dbuf *dbuf)
{
	dbuf->bufs_orig[0] = malloc(SCREEN_WIDTH*SCREEN_HEIGHT*4 + 64);
	dbuf->bufs_orig[1] = malloc(SCREEN_WIDTH*SCREEN_HEIGHT*4 + 64);
	dbuf->bufs[0] = (unsigned int *) (((unsigned int) dbuf->bufs_orig[0] + 64) & ~63U);
	dbuf->bufs[1] = (unsigned int *) (((unsigned int) dbuf->bufs_orig[1] + 64) & ~63U);
	printf("dbuf: origs %08x %08x, bufs %08x %08x\r\n", dbuf->bufs_orig[0], dbuf->bufs_orig[1], dbuf->bufs[0], dbuf->bufs[1]);
	dbuf->which = 0;
	
	return dbuf_flip(dbuf);
}

struct img_resource
{
	unsigned int w;
	unsigned int h;
	unsigned int pixels[];
};

#define SPRITE_DIM 64
#define OTHER_ENDIANNESS(x) (((x>>24) & 0xff) | ((x >> 8) & 0xff00) | ((x << 8) & 0xff0000) | ((x << 24) & 0xff000000))
#define DRAW_PIX(buf, img, x0, y0, y, x) if ((img)[SPRITE_DIM*(y)+(x)]&0xff000000) (buf)[SCREEN_WIDTH*(y0+y)+(x0+x)] = OTHER_ENDIANNESS((img)[SPRITE_DIM*(y)+(x)]);

struct img_resource *img_load(struct fat16_handle *h, char *name)
{
	int rv;
	struct fat16_file fd;
	struct img_resource *r;
	
	printf("Loading image resource %s... ", name);
	if (fat16_open_by_name(h, &fd, name) == -1)
	{
		printf("not found?\r\n");
		return NULL;
	} 
	
	r = malloc(fd.len);
	if (!r)
	{
		printf("out of memory?\r\n");
		return NULL;
	}
	
	rv = fat16_read(&fd, (void *)r, fd.len);
	if (rv != fd.len) {
		printf("short read (%d)\r\n", rv);
		free(r);
		return NULL;
	}

	printf("%dx%d image\r\n", r->w, r->h);
	
	return r;
}

void draw_note(unsigned int *fb, unsigned int x0, unsigned int y0, struct img_resource *r) {
	int x, y;
	unsigned int *buf;
	
	buf = r->pixels;
	for (y = 0; y < r->h; y++) {
		for (x = 0; x < r->w; x+=8) {
			if (*buf & 0x000000FF)
				fb[SCREEN_WIDTH*(y0+y)+(x0+x+0)] = *buf;
			buf++;
			
			if (*buf & 0x000000FF)
				fb[SCREEN_WIDTH*(y0+y)+(x0+x+1)] = *buf;
			buf++;
			
			if (*buf & 0x000000FF)
				fb[SCREEN_WIDTH*(y0+y)+(x0+x+2)] = *buf;
			buf++;
			
			if (*buf & 0x000000FF)
				fb[SCREEN_WIDTH*(y0+y)+(x0+x+3)] = *buf;
			buf++;
			
			if (*buf & 0x000000FF)
				fb[SCREEN_WIDTH*(y0+y)+(x0+x+4)] = *buf;
			buf++;
			
			if (*buf & 0x000000FF)
				fb[SCREEN_WIDTH*(y0+y)+(x0+x+5)] = *buf;
			buf++;
			
			if (*buf & 0x000000FF)
				fb[SCREEN_WIDTH*(y0+y)+(x0+x+6)] = *buf;
			buf++;
			
			if (*buf & 0x000000FF)
				fb[SCREEN_WIDTH*(y0+y)+(x0+x+7)] = *buf;
			buf++;
		}
	}
}

static struct stepfile song;

void main()
{
	int i, j;
	int length;
	int rv;

	unsigned int *audio_mem_base;

	int fat16_start;
	struct fat16_handle h;

	printf("Reading partition table... ");
	fat16_start = fat16_find_partition();
	if (fat16_start < 0)
	{
		puts("no FAT16 partition found!");
		return;
	}
	printf("found starting at sector %d.\r\n", fat16_start);
	
	printf("Opening FAT16 partition... ");
	if (fat16_open(&h, fat16_start) < 0)
	{
		puts("FAT16 boot sector read failed!");
		return;
	}
	puts("OK");

	rv = load_steps(&h, &song);
	if (rv < 0) {
		printf("Failure loading steps! (%d)\r\n", rv);
		return;
	}

	audio_mem_base = load_audio(&h, &length);
	if (!audio_mem_base) {
		printf("Failure loading audio! (%d)\r\n", rv);
		return;
	}

	printf("qbeats: %d; samps_per_qbeat: %d; playing...\r\n", song.len_qbeats, song.samps_per_qbeat);

	audio_play(audio_mem_base, length, AUDIO_MODE_ONCE);

	struct dbuf double_buffer;
	unsigned int *buf;

	volatile unsigned int * scancodeaddr = 0x85000000;
	unsigned int scancode;
	kh_type k;
	char new_char;

	int l, u, d, r;
	l = 0;
	u = 0;
	d = 0;
	r = 0;

	int hit_l, hit_u, hit_d, hit_r;
	hit_l = -1;
	hit_u = -1;
	hit_d = -1;
	hit_r = -1;

	int hits = 0;
	signed int qbeat_last;

	buf = dbuf_init(&double_buffer);

	struct img_resource *left_arrows[4];
	struct img_resource *down_arrows[4];
	struct img_resource *up_arrows[4];
	struct img_resource *right_arrows[4];
	
	left_arrows[0] = img_load(&h, "LEFT_4  RES");
	left_arrows[1] = img_load(&h, "LEFT_16 RES");
	left_arrows[2] = img_load(&h, "LEFT_8  RES");
	left_arrows[3] = left_arrows[1];
	
	right_arrows[0] = img_load(&h, "RIGHT_4 RES");
	right_arrows[1] = img_load(&h, "RIGHT_16RES");
	right_arrows[2] = img_load(&h, "RIGHT_8 RES");
	right_arrows[3] = right_arrows[1];
	
	up_arrows[0] = img_load(&h, "UP_4    RES");
	up_arrows[1] = img_load(&h, "UP_16   RES");
	up_arrows[2] = img_load(&h, "UP_8    RES");
	up_arrows[3] = up_arrows[1];
	
	down_arrows[0] = img_load(&h, "DOWN_4  RES");
	down_arrows[1] = img_load(&h, "DOWN_16 RES");
	down_arrows[2] = img_load(&h, "DOWN_8  RES");
	down_arrows[3] = down_arrows[1];
	
	struct img_resource *left_spot = img_load(&h, "LEFTSPOTRES");
	struct img_resource *right_spot = img_load(&h, "RIGHSPOTRES");
	struct img_resource *up_spot = img_load(&h, "UP_SPOT RES");
	struct img_resource *down_spot = img_load(&h, "DOWNSPOTRES");

	while (1) {
		signed int qbeat, rem, qbeat_round, meas_qbeat;
		char datum;
		int i;
		int lnow = l;
		int unow = u;
		int dnow = d;
		int rnow = r;
		while ((scancode = *scancodeaddr) != 0xffffffff) {
			k = process_scancode(scancode);
			if (KH_HAS_CHAR(k)) {
				new_char = KH_GET_CHAR(k);
				switch (new_char) {
					case 'j': lnow = !KH_IS_RELEASING(k); break;
					case 'i': unow = !KH_IS_RELEASING(k); break;
					case 'k': dnow = !KH_IS_RELEASING(k); break;
					case 'l': rnow = !KH_IS_RELEASING(k); break;
				}
			}
		}

		qbeat = (audio_samples_played()-song.delay_samps-1600)/song.samps_per_qbeat;
		rem = (audio_samples_played()-song.delay_samps-1600)%song.samps_per_qbeat;
		qbeat_round = (audio_samples_played()-song.delay_samps-1600+song.samps_per_qbeat/2)/song.samps_per_qbeat;

		if (qbeat < 0)
			continue;

		if (lnow && !l) {
			if ((song.qsteps[qbeat_round] >> 3) & 1) hits++;
			printf("%d %d %d %d\r\n", rem, song.samps_per_qbeat - rem, *((unsigned int*)0x8400000c), *((unsigned int*)0x84000010));
			hit_l = qbeat_round;
		}
		if (unow && !u) {
			if ((song.qsteps[qbeat_round] >> 2) & 1) hits++;
			printf("%d %d %d %d\r\n", rem, song.samps_per_qbeat - rem, *((unsigned int*)0x8400000c), *((unsigned int*)0x84000010));
			hit_u = qbeat_round;
		}
		if (dnow && !d) {
			if ((song.qsteps[qbeat_round] >> 1) & 1) hits++;
			printf("%d %d %d %d\r\n", rem, song.samps_per_qbeat - rem, *((unsigned int*)0x8400000c), *((unsigned int*)0x84000010));
			hit_d = qbeat_round;
		}
		if (rnow && !r) {
			if ((song.qsteps[qbeat_round] >> 0) & 1) hits++;
			printf("%d %d %d %d\r\n", rem, song.samps_per_qbeat - rem, *((unsigned int*)0x8400000c), *((unsigned int*)0x84000010));
			hit_r = qbeat_round;
		}

		if (qbeat_last != qbeat) {
			//printf("%d\r\n", hits);
			qbeat_last = qbeat;
		}

		l = lnow;
		u = unow;
		d = dnow;
		r = rnow;

		accel_fill(buf, 0x00000000, SCREEN_WIDTH*SCREEN_HEIGHT);

		draw_note(buf,  25, 50, left_spot);
		draw_note(buf, 100, 50, down_spot);
		draw_note(buf, 175, 50, up_spot);
		draw_note(buf, 250, 50, right_spot);
		for (i = 7; i >= -1; i--) {
			int y = 50 + 50 * i + 50 * (song.samps_per_qbeat - rem) / song.samps_per_qbeat;
			int spot_in_beat = (qbeat + i) % 4;
			datum = song.qsteps[qbeat+i];
			if ((datum >> 3) & 1)
				draw_note(buf, 25, y, left_arrows[spot_in_beat]);
			if ((datum >> 2) & 1)
				draw_note(buf, 100, y, down_arrows[spot_in_beat]);
			if ((datum >> 1) & 1)
				draw_note(buf, 175, y, up_arrows[spot_in_beat]);
			if ((datum >> 0) & 1)
				draw_note(buf, 250, y, right_arrows[spot_in_beat]);
		}

		buf = dbuf_flip(&double_buffer);
	}
}

