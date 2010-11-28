#include "keyhelp.h"
#include "audio.h"
#include "fat16.h"
#include "minilib.h"

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

int load_audio(struct fat16_handle * h, unsigned int * mem_location)
{
	int rv;
	struct fat16_file fd;
	
	printf("Opening AUDIO.RAW... ");
	if (fat16_open_by_name(h, &fd, "AUDIO   RAW") == -1)
	{
		printf("not found?\r\n");
		return -1;
	} 
	
	rv = fat16_read(&fd, (void*)mem_location, 100000000);
	printf("loaded! (%d bytes)\r\n", rv);
	
	return rv;
}

void draw_blah(unsigned int *buf0, unsigned int *buf1, unsigned int x0, unsigned int y0, unsigned int color, unsigned int* reading_from) {
	int x, y;
	unsigned int *reading_buf;
	unsigned int *other_buf;
	unsigned int *frame_start = 0x82000000;
	if (reading_from == 0)
	{
		reading_buf = buf0;
		other_buf = buf1;
		
	}
	else
	{
		other_buf = buf0;
		reading_buf = buf1;
	}
	for (y = y0; y < y0 + 5; y++) {
		for (x = x0; x < x0 + 100; x+=10) {
			other_buf[640*y+x+0] = color;
			other_buf[640*y+x+1] = color;
			other_buf[640*y+x+2] = color;
			other_buf[640*y+x+3] = color;
			other_buf[640*y+x+4] = color;
			other_buf[640*y+x+5] = color;
			other_buf[640*y+x+6] = color;
			other_buf[640*y+x+7] = color;
			other_buf[640*y+x+8] = color;
			other_buf[640*y+x+9] = color;
		}
	}
	for (y = y0 + 5; y < y0 + 15; y++) {
		for (x = x0; x < x0 + 100; x+=10) {
			other_buf[640*y+x+0] = 0x00000000;
			other_buf[640*y+x+1] = 0x00000000;
			other_buf[640*y+x+2] = 0x00000000;
			other_buf[640*y+x+3] = 0x00000000;
			other_buf[640*y+x+4] = 0x00000000;
			other_buf[640*y+x+5] = 0x00000000;
			other_buf[640*y+x+6] = 0x00000000;
			other_buf[640*y+x+7] = 0x00000000;
			other_buf[640*y+x+8] = 0x00000000;
			other_buf[640*y+x+9] = 0x00000000;
		}
	}
	*frame_start = (int)other_buf;
	for (y = y0; y < y0 + 5; y++) {
		for (x = x0; x < x0 + 100; x+=10) {
			reading_buf[640*y+x+0] = color;
			reading_buf[640*y+x+1] = color;
			reading_buf[640*y+x+2] = color;
			reading_buf[640*y+x+3] = color;
			reading_buf[640*y+x+4] = color;
			reading_buf[640*y+x+5] = color;
			reading_buf[640*y+x+6] = color;
			reading_buf[640*y+x+7] = color;
			reading_buf[640*y+x+8] = color;
			reading_buf[640*y+x+9] = color;
		}
	}
	for (y = y0 + 5; y < y0 + 15; y++) {
		for (x = x0; x < x0 + 100; x+=10) {
			reading_buf[640*y+x+0] = 0x00000000;
			reading_buf[640*y+x+1] = 0x00000000;
			reading_buf[640*y+x+2] = 0x00000000;
			reading_buf[640*y+x+3] = 0x00000000;
			reading_buf[640*y+x+4] = 0x00000000;
			reading_buf[640*y+x+5] = 0x00000000;
			reading_buf[640*y+x+6] = 0x00000000;
			reading_buf[640*y+x+7] = 0x00000000;
			reading_buf[640*y+x+8] = 0x00000000;
			reading_buf[640*y+x+9] = 0x00000000;
		}
	}
	*reading_from = !(*reading_from);	
}

static struct stepfile song;

void main()
{
	int i, j;
	unsigned int *start_d0 = 0x02300000;
	unsigned int *start_d1 = 0x02500000; /* two buffers needed for double buffering */
	for (i = 0; i < SCREEN_HEIGHT; i++) {
		for (j = 0; j < SCREEN_WIDTH; j+=10) {
			start_d0[i*SCREEN_WIDTH+j+0] = 0x0000ffff;
			start_d0[i*SCREEN_WIDTH+j+1] = 0x0000ffff;
			start_d0[i*SCREEN_WIDTH+j+2] = 0x0000ffff;
			start_d0[i*SCREEN_WIDTH+j+3] = 0x0000ffff;
			start_d0[i*SCREEN_WIDTH+j+4] = 0x0000ffff;
			start_d0[i*SCREEN_WIDTH+j+5] = 0x0000ffff;
			start_d0[i*SCREEN_WIDTH+j+6] = 0x0000ffff;
			start_d0[i*SCREEN_WIDTH+j+7] = 0x0000ffff;
			start_d0[i*SCREEN_WIDTH+j+8] = 0x0000ffff;
			start_d0[i*SCREEN_WIDTH+j+9] = 0x0000ffff;
		}
	}
	for (i = 0; i < SCREEN_HEIGHT; i++) {
		for (j = 0; j < SCREEN_WIDTH; j+=10) {
			start_d1[i*SCREEN_WIDTH+j+0] = 0x0000ffff;
			start_d1[i*SCREEN_WIDTH+j+1] = 0x0000ffff;
			start_d1[i*SCREEN_WIDTH+j+2] = 0x0000ffff;
			start_d1[i*SCREEN_WIDTH+j+3] = 0x0000ffff;
			start_d1[i*SCREEN_WIDTH+j+4] = 0x0000ffff;
			start_d1[i*SCREEN_WIDTH+j+5] = 0x0000ffff;
			start_d1[i*SCREEN_WIDTH+j+6] = 0x0000ffff;
			start_d1[i*SCREEN_WIDTH+j+7] = 0x0000ffff;
			start_d1[i*SCREEN_WIDTH+j+8] = 0x0000ffff;
			start_d1[i*SCREEN_WIDTH+j+9] = 0x0000ffff;
		}
	}
	unsigned int *reading_from = 0x01700000;
	unsigned int *num_clock_cycles = 0x86000000;
	*reading_from = 0;
	int length;
	int rv;

	unsigned int *audio_mem_base = 0x00800000;

	int audio_len;

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

	length = load_audio(&h, audio_mem_base);
	if (rv < 0) {
		printf("Failure loading audio! (%d)\r\n", rv);
		return;
	}

	printf("qbeats: %d; samps_per_qbeat: %d; playing...\r\n", song.len_qbeats, song.samps_per_qbeat);

	audio_play(audio_mem_base, length, AUDIO_MODE_ONCE);

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

	while (1) {
		signed int qbeat, rem, qbeat_round;
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
			hit_l = qbeat_round;
		}
		if (unow && !u) {
			if ((song.qsteps[qbeat_round] >> 2) & 1) hits++;
			hit_u = qbeat_round;
		}
		if (dnow && !d) {
			if ((song.qsteps[qbeat_round] >> 1) & 1) hits++;
			hit_d = qbeat_round;
		}
		if (rnow && !r) {
			if ((song.qsteps[qbeat_round] >> 0) & 1) hits++;
			hit_r = qbeat_round;
		}

		if (qbeat_last != qbeat) {
			printf("%d\r\n", hits);
			qbeat_last = qbeat;
		}

		l = lnow;
		u = unow;
		d = dnow;
		r = rnow;

		for (i = 7; i > 0; i--) {
			int y = 50 + 50 * i + 50 * (song.samps_per_qbeat - rem) / song.samps_per_qbeat;
			datum = song.qsteps[qbeat+i];
			if ((datum >> 3) & 1)
				draw_blah(start_d0, start_d1, 50, y, 0xffffffff, reading_from);
			if ((datum >> 2) & 1)
				draw_blah(start_d0, start_d1, 200, y, 0xffffffff, reading_from);
			if ((datum >> 1) & 1)
				draw_blah(start_d0, start_d1, 350, y, 0xffffffff, reading_from);
			if ((datum >> 0) & 1)
				draw_blah(start_d0, start_d1, 500, y, 0xffffffff, reading_from);
		}
		int y = 50 + 50 * (song.samps_per_qbeat - rem) / song.samps_per_qbeat;
		if ((datum >> 3) & 1) {
			int color = 0xffffffff;
			if (hit_l == qbeat_round) {
				color = 0xff0000ff;
			}
			draw_blah(start_d0, start_d1, 50, y, color, reading_from);
		}
		if ((datum >> 2) & 1) {
			int color = 0xffffffff;
			if (hit_u == qbeat_round) {
				color = 0xff0000ff;
			}
			draw_blah(start_d0, start_d1, 200, y, color, reading_from);
		}
		if ((datum >> 1) & 1) {
			int color = 0xffffffff;
			if (hit_d == qbeat_round) {
				color = 0xff0000ff;
			}
			draw_blah(start_d0, start_d1, 350, y, color, reading_from);
		}
		if ((datum >> 0) & 1) {
			int color = 0xffffffff;
			if (hit_r == qbeat_round) {
				color = 0xff0000ff;
			}
			draw_blah(start_d0, start_d1, 500, y, color, reading_from);
		}
	}
}

