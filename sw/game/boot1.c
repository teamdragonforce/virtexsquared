#include "keyhelp.h"
#include "audio.h"
#include "fat16.h"
#include "minilib.h"

#define MAX_QBEATS 50000

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

void draw_blah(unsigned int *buf, unsigned int x0, unsigned int y0, unsigned int color) {
	int x, y;
	for (x = x0; x < x0 + 100; x++) {
		for (y = y0; y < y0 + 100; y++) {
			buf[640*y+x] = color;
		}
	}
}

static struct stepfile song;

void main()
{
	int i, j;
	unsigned int *start_d = 0x00100000;
	unsigned int *d;
	unsigned int *num_clock_cycles = 0x86000000;
	int length;
	int rv;

	unsigned int *audio_mem_base = 0x00800000;

	int audio_len;

	int fat16_start;
	struct fat16_handle h;

	printf("BLAH BLAH BLAH POOP POOP BLAH\r\n");
	
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

	while (1) {
		signed int qbeat;
		char datum;

		qbeat = (audio_samples_played()-song.delay_samps-1600)/song.samps_per_qbeat;
		if (qbeat < 0)
			continue;

		datum = song.qsteps[qbeat];
		draw_blah(start_d, 50, 50, (datum >> 3) & 1 ? 0xffffffff : 0x00000000);
		draw_blah(start_d, 200, 50, (datum >> 2) & 1 ? 0xffffffff : 0x00000000);
		draw_blah(start_d, 350, 50, (datum >> 1) & 1 ? 0xffffffff : 0x00000000);
		draw_blah(start_d, 500, 50, (datum >> 0) & 1 ? 0xffffffff : 0x00000000);
		/*
		printf("qbeat: %4d steps: %d%d%d%d\r\n", qbeat, (datum >> 3) & 1, (datum >> 2) & 1, (datum >> 1) & 1, datum & 1);
		*/
	}

#if 0
	printf("kicked off play\r\n");

	while (1) {};

	/*
	while(1) {
		for (y = 0; y < 300; y++) {
			index = 0;
			d = start_d + y*640+x;
			for (i = 0; i < gimp_image.height; i++){
				for (j = 0; j < gimp_image.width; j+=4) {
					pixel_data = ((int*)gimp_image.pixel_data)[index];
					if ((gimp_image.pixel_data[index*4+3]) == 0xFF)
						*(d) = pixel_data; 
					d++;
					index++;
					pixel_data = ((int*)gimp_image.pixel_data)[index];
					if ((gimp_image.pixel_data[index*4+3]) == 0xFF)
						*(d) = pixel_data; 
					d++;
					index++;
					pixel_data = ((int*)gimp_image.pixel_data)[index];
					if ((gimp_image.pixel_data[index*4+3]) == 0xFF)
						*(d) = pixel_data; 
					d++;
					index++;
					pixel_data = ((int*)gimp_image.pixel_data)[index];
					if ((gimp_image.pixel_data[index*4+3]) == 0xFF)
						*(d) = pixel_data; 
					d++;
					index++;
				}
				d += (640-gimp_image.width);
			}
			d = start_d + y*640+x;
			for (i = 0; i < gimp_image.height; i++){
				for (j = 0; j < gimp_image.width; j+=4) {
					*(d++) = 0x00000000; 
					*(d++) = 0x00000000; 
					*(d++) = 0x00000000; 
					*(d++) = 0x00000000; 
				}
				d += (640-gimp_image.width);
			}
		}
		printf("Number of clock cycles: %x\r\n", *num_clock_cycles);
	}
	*/
#endif
}

