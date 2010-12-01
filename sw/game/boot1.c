#include "keyhelp.h"
#include "audio.h"
#include "fat16.h"
#include "minilib.h"
#include "accel.h"
#include "malloc.h"

#define MAX_QBEATS 50000
#define SCREEN_WIDTH 640
#define SCREEN_HEIGHT 480

static unsigned char chars[] = {
#include "chars.inc"
};

int offset;

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


/*
 * Triple buffering
 */
struct dbuf {
	unsigned int *bufs[3];
	unsigned int *bufs_orig[3];
	int which;
};

unsigned int getnext_mod3(unsigned int x){
	if (x == 0)
		return 1;
	if (x == 1)
		return 2;
	if (x == 2)
		return 0;
}

unsigned int *dbuf_flip(struct dbuf *dbuf)
{
	volatile unsigned int *frame_start = 0x82000000;
	volatile unsigned int *frame_nread = 0x8200000c;
	volatile unsigned int *frame_currread = 0x82000014;
	int* buffer_curr_reading = (int*)(*frame_currread);
	*frame_start = dbuf->bufs[dbuf->which];
	unsigned int read_last = *frame_nread;
	unsigned int read;

	/*printf("previous dbuf->which: %x ", dbuf->which);*/

	unsigned int next_which = getnext_mod3(dbuf->which);

	
	if (dbuf->bufs[next_which] != buffer_curr_reading)
		dbuf->which = next_which;
	else
		dbuf->which = getnext_mod3(next_which);
	/*printf("next dbuf->which: %x \r\n", dbuf->which);*/
	
	return dbuf->bufs[dbuf->which];
}

unsigned int *dbuf_init(struct dbuf *dbuf)
{
	dbuf->bufs_orig[0] = malloc(SCREEN_WIDTH*SCREEN_HEIGHT*4 + 64);
	dbuf->bufs_orig[1] = malloc(SCREEN_WIDTH*SCREEN_HEIGHT*4 + 64);
	dbuf->bufs_orig[2] = malloc(SCREEN_WIDTH*SCREEN_HEIGHT*4 + 64);
	dbuf->bufs[0] = (unsigned int *) (((unsigned int) dbuf->bufs_orig[0] + 64) & ~63U);
	dbuf->bufs[1] = (unsigned int *) (((unsigned int) dbuf->bufs_orig[1] + 64) & ~63U);
	dbuf->bufs[2] = (unsigned int *) (((unsigned int) dbuf->bufs_orig[2] + 64) & ~63U);
	accel_fill(dbuf->bufs[0], 0x00000000, SCREEN_WIDTH*SCREEN_HEIGHT);
	accel_fill(dbuf->bufs[1], 0x00000000, SCREEN_WIDTH*SCREEN_HEIGHT);
	accel_fill(dbuf->bufs[2], 0x00000000, SCREEN_WIDTH*SCREEN_HEIGHT);
	printf("dbuf: origs %08x %08x %08x, bufs %08x %08x %08x\r\n", dbuf->bufs_orig[0], dbuf->bufs_orig[1], dbuf->bufs_orig[2], dbuf->bufs[0], dbuf->bufs[1], dbuf->bufs[2]);
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

void bitblt(unsigned int *fb, unsigned int x0, unsigned int y0, struct img_resource *r) {
	int x, y;
	unsigned int *buf;
	
	if (((x0 + r->w) > 640) || ((y0 + r->h) > 480))
	{
		/*printf("BOUNDS CHECK!\r\n");*/
		return;
	}
	
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

void cons_drawchar_with_scale_3(unsigned int *buf, int c, int x, int y, int fg, int bg)
{
	int xx, yy;
	int i, j;
	buf = buf + (y*SCREEN_WIDTH+x);
	
	for (yy = 0; yy < 8; yy++) 
		for (xx = 0; xx < 8; xx++) 
			for (i = 0; i < 3; i++)
				for (j = 0; j < 3; j++)
					buf[(yy*3+j) * SCREEN_WIDTH + (7 - (xx*3+i))] = ((chars[c*8 + yy] >> xx) & 1) ? fg : bg;
}

struct img_resource *left_arrows[4];
struct img_resource *down_arrows[4];
struct img_resource *up_arrows[4];
struct img_resource *right_arrows[4];

struct dbuf *dbuf;

void splat_loading()
{
	int i;
	static unsigned int *buf = NULL;
	static int c = 0;
	
	if (!buf)
	{
		buf = dbuf_flip(dbuf);
	}
	
	printf(".");
	
//	for (i = 0; i < 4; i++)
//	{
//		bitblt(buf,  25, 50+50*i, left_arrows[i]);
//		bitblt(buf, 100, 50+50*i, down_arrows[i]);
//		bitblt(buf, 175, 50+50*i, up_arrows[i]);
//		bitblt(buf, 250, 50+50*i, right_arrows[i]);
//	}

	cons_drawchar_with_scale_3(buf, (int)'L', 200+24*0, 300, gencol(c+10), 0x000000);
	cons_drawchar_with_scale_3(buf, (int)'o', 200+24*1, 300, gencol(c+20), 0x000000);
	cons_drawchar_with_scale_3(buf, (int)'a', 200+24*2, 300, gencol(c+30), 0x000000);
	cons_drawchar_with_scale_3(buf, (int)'d', 200+24*3, 300, gencol(c+40), 0x000000);
	cons_drawchar_with_scale_3(buf, (int)'i', 200+24*4, 300, gencol(c+50), 0x000000);
	cons_drawchar_with_scale_3(buf, (int)'n', 200+24*5, 300, gencol(c+60), 0x000000);
	cons_drawchar_with_scale_3(buf, (int)'g', 200+24*6, 300, gencol(c+70), 0x000000);
	cons_drawchar_with_scale_3(buf, (int)'.', 200+24*7, 300, gencol(c+80), 0x000000);
	c += 10;

	buf = dbuf_flip(dbuf);

}

unsigned int *load_audio(struct fat16_handle *h, int *length)
{
	int rv;
	int len, tlen;
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
	
	len = fd.len;
	tlen = 0;
	while (len)
	{
		int thislen = (len > 16384) ? 16384 : len;
		rv = fat16_read(&fd, ((void*)p) + tlen, thislen);
		if (rv != thislen)
		{
			printf("short read?\r\n");
			return NULL;
		}
		splat_loading();
		tlen += rv;
		len -= rv;
	}
	printf("loaded! (%d bytes)\r\n", tlen);
	
	if (length)
		*length = tlen;
	
	return p;
}


static struct stepfile song;

/* left up down right for the game */
int l, u, d, r;

int check_hit(){
	volatile unsigned int* scancodeaddr = 0x85000000;
	unsigned int scancode;
	int lnow = l;
	int unow = u;
	int dnow = d;
	int rnow = r;
	kh_type k;
	char new_char;
	int hit = -1;
	int samples_played = audio_samples_played();
	signed int qbeat_round = (samples_played-song.delay_samps-1600+song.samps_per_qbeat/2)/song.samps_per_qbeat;
	signed int rem = (samples_played-song.delay_samps-1600)%song.samps_per_qbeat;

	while ((scancode = *scancodeaddr) != 0xffffffff) {
		k = process_scancode(scancode);
		if (KH_HAS_CHAR(k)) {
			new_char = KH_GET_CHAR(k);
			switch (new_char) {
				case 'j': lnow = !KH_IS_RELEASING(k); break;
				case 'i': unow = !KH_IS_RELEASING(k); break;
				case 'k': dnow = !KH_IS_RELEASING(k); break;
				case 'l': rnow = !KH_IS_RELEASING(k); break;
				case '7': 
					if (!KH_IS_RELEASING(k)) {
						offset -= 1000; 
						printf("Offset: %d\r\n", offset);
					}
					break;
				case '8': 
					if (!KH_IS_RELEASING(k)) {
						offset -= 100; 
						printf("Offset: %d\r\n", offset);
					}
					break;
				case '9': 
					if (!KH_IS_RELEASING(k)) {
						offset += 100; 
						printf("Offset: %d\r\n", offset);
					}
					break;
				case '0':
					if (!KH_IS_RELEASING(k)) {
						offset += 1000; 
						printf("Offset: %d\r\n", offset);
					}
					break;
			}
		}
	}
	
	if (lnow && !l) {
		if ((song.qsteps[qbeat_round] >> 3) & 1) {
			hit = 1;
			if (rem < song.samps_per_qbeat - rem)
				printf("Off by %d\r\n", rem);
			else 
				printf("Off by -%d\r\n", song.samps_per_qbeat-rem);
		}
		else if ((song.qsteps[qbeat_round-1] >> 3) & 1) {
			if (rem < song.samps_per_qbeat - rem) {
				hit = 2;		
				printf("Off by -%d\r\n", song.samps_per_qbeat-rem);
			}
			else
				hit = 0;
		}
		else if ((song.qsteps[qbeat_round+1] >> 3) & 1) {
			if (rem < song.samps_per_qbeat - rem)
				hit = 0;
			else { 
				hit = 2;		
				printf("Off by %d\r\n", rem);
			}
		}
		else {
			hit = 0;
		}
	}
	if (dnow && !d) {
		if ((song.qsteps[qbeat_round] >> 2) & 1) {
			hit = 1;
			if (rem < song.samps_per_qbeat - rem)
				printf("Off by %d\r\n", rem);
			else 
				printf("Off by -%d\r\n", song.samps_per_qbeat-rem);
		}
		else if ((song.qsteps[qbeat_round-1] >> 2) & 1) {
			if (rem < song.samps_per_qbeat - rem) {
				hit = 2;		
				printf("Off by -%d\r\n", song.samps_per_qbeat-rem);
			}
			else
				hit = 0;
		}
		else if ((song.qsteps[qbeat_round+1] >> 2) & 1) {
			if (rem < song.samps_per_qbeat - rem)
				hit = 0;
			else { 
				hit = 2;		
				printf("Off by %d\r\n", rem);
			}
		}
		else {
			hit = 0;
		}
	}
	if (unow && !u) {
		if ((song.qsteps[qbeat_round] >> 1) & 1) {
			hit = 1;
			if (rem < song.samps_per_qbeat - rem)
				printf("Off by %d\r\n", rem);
			else 
				printf("Off by -%d\r\n", song.samps_per_qbeat-rem);
		}
		else if ((song.qsteps[qbeat_round-1] >> 1) & 1) {
			if (rem < song.samps_per_qbeat - rem) {
				hit = 2;		
				printf("Off by -%d\r\n", song.samps_per_qbeat-rem);
			}
			else
				hit = 0;
		}
		else if ((song.qsteps[qbeat_round+1] >> 1) & 1) {
			if (rem < song.samps_per_qbeat - rem)
				hit = 0;
			else { 
				hit = 2;		
				printf("Off by %d\r\n", rem);
			}
		}
		else {
			hit = 0;
		}
	}
	if (rnow && !r) {
		if ((song.qsteps[qbeat_round] >> 0) & 1) {
			hit = 1;
			if (rem < song.samps_per_qbeat - rem)
				printf("Off by %d\r\n", rem);
			else 
				printf("Off by -%d\r\n", song.samps_per_qbeat-rem);
		}
		else if ((song.qsteps[qbeat_round-1] >> 0) & 1) {
			if (rem < song.samps_per_qbeat - rem) {
				hit = 2;		
				printf("Off by -%d\r\n", song.samps_per_qbeat-rem);
			}
			else
				hit = 0;
		}
		else if ((song.qsteps[qbeat_round+1] >> 0) & 1) {
			if (rem < song.samps_per_qbeat - rem)
				hit = 0;
			else { 
				hit = 2;		
				printf("Off by %d\r\n", rem);
			}
		}
		else {
			hit = 0;
		}
	}
	l = lnow;
	u = unow;
	d = dnow;
	r = rnow;
	return hit;

}

void main()
{
	int i, j;
	int length;
	int rv;
	volatile int* cycles = 0x86000000;

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
	
	/* Set up graphics. */
	struct dbuf double_buffer;
	unsigned int *buf;

	buf = dbuf_init(&double_buffer);
	
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
	
	/* Load music. */
	
	dbuf = &double_buffer;
	splat_loading();


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

	volatile unsigned int * scancodeaddr = 0x85000000;
	unsigned int scancode;
	volatile unsigned int* cycleaddr = 0x86000000;
	kh_type k;
	char new_char;

	l = 0;
	u = 0;
	d = 0;
	r = 0;

	int hit = -1;
	int last_hit = -1;
	int prev_cycle = *cycleaddr;
	int curr_cycle = *cycleaddr;
	buf = dbuf_flip(dbuf);
	offset = 5600;

	while (1) {
		signed int qbeat, rem, qbeat_round;
		char datum;
		int i;
		int lnow = l;
		int unow = u;
		int dnow = d;
		int rnow = r;
		int samples_played;
		
		curr_cycle = *cycleaddr;
		/*printf("Cycles: %d\r\n", curr_cycle-prev_cycle);*/
		prev_cycle = curr_cycle;

		if (qbeat < 0)
			continue;

		if (hit == -1)	
			hit = check_hit(qbeat_round, rem);

		accel_fill(buf, 0x00000000, SCREEN_WIDTH*SCREEN_HEIGHT);

		bitblt(buf,  25, 50, left_spot);
		bitblt(buf, 100, 50, down_spot);
		if (hit == -1)
			hit = check_hit();
		bitblt(buf, 175, 50, up_spot);
		bitblt(buf, 250, 50, right_spot);
		if (hit == -1)
			hit = check_hit();

		samples_played = audio_samples_played()+offset;
		qbeat = (samples_played-song.delay_samps-1600)/song.samps_per_qbeat;
		rem = (samples_played-song.delay_samps-1600)%song.samps_per_qbeat;
		qbeat_round = (samples_played-song.delay_samps-1600+song.samps_per_qbeat/2)/song.samps_per_qbeat;

		for (i = 7; i >= -1; i--) {
			int y = 50 + 50 * i + 50 * (song.samps_per_qbeat - rem) / song.samps_per_qbeat;
			int spot_in_beat = (qbeat + i) % 4;
			datum = song.qsteps[qbeat+i];
			if ((datum >> 3) & 1)
				bitblt(buf, 25, y, left_arrows[spot_in_beat]);
			if ((datum >> 2) & 1)
				bitblt(buf, 100, y, down_arrows[spot_in_beat]);
			if (hit == -1)
				hit = check_hit();
			if ((datum >> 1) & 1)
				bitblt(buf, 175, y, up_arrows[spot_in_beat]);
			if ((datum >> 0) & 1)
				bitblt(buf, 250, y, right_arrows[spot_in_beat]);
			if (hit == -1)
				hit = check_hit();
		}
		if (hit == -1)
			hit = last_hit;
		else
			last_hit = hit;
		if (hit == 0) {
			cons_drawchar_with_scale_3(buf, (int)'M', 100, 200, 0xffffffff, 0x00000000);			
			cons_drawchar_with_scale_3(buf, (int)'I', 100+24*1, 200, 0xffffffff, 0x00000000);
			hit = check_hit();
			cons_drawchar_with_scale_3(buf, (int)'S', 100+24*2, 200, 0xffffffff, 0x00000000);			
			cons_drawchar_with_scale_3(buf, (int)'S', 100+24*3, 200, 0xffffffff, 0x00000000);			
		}
		if (hit == 1) {
			cons_drawchar_with_scale_3(buf, (int)'G', 100, 200, 0xffffffff, 0x00000000);
			cons_drawchar_with_scale_3(buf, (int)'R', 100+24*1, 200, 0xffffffff, 0x00000000);	
			hit = check_hit();
			cons_drawchar_with_scale_3(buf, (int)'E', 100+24*2, 200, 0xffffffff, 0x00000000);			
			cons_drawchar_with_scale_3(buf, (int)'A', 100+24*3, 200, 0xffffffff, 0x00000000);			
			cons_drawchar_with_scale_3(buf, (int)'T', 100+24*4, 200, 0xffffffff, 0x00000000);			
		}
		if (hit == 2) {
			cons_drawchar_with_scale_3(buf, (int)'G', 100, 200, 0xffffffff, 0x00000000);
			cons_drawchar_with_scale_3(buf, (int)'O', 100+24*1, 200, 0xffffffff, 0x00000000);	
			hit = check_hit();
			cons_drawchar_with_scale_3(buf, (int)'O', 100+24*2, 200, 0xffffffff, 0x00000000);			
			cons_drawchar_with_scale_3(buf, (int)'D', 100+24*3, 200, 0xffffffff, 0x00000000);
		}	
		
		buf = dbuf_flip(&double_buffer);
	}
}

