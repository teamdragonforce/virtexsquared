/* Small audio library. */
#include "audio.h"

static volatile int *dma_start  = (int*) 0x84000000;
static volatile int *dma_length = (int*) 0x84000004;
static volatile int *dma_cmd    = (int*) 0x84000008;
static volatile int *dma_nread  = (int*) 0x8400000c;

static volatile short *master_vol = (short*) 0x84000100;
static volatile short *mic_vol    = (short*) 0x84000104;
static volatile short *line_vol   = (short*) 0x84000108;
static volatile short *cd_vol     = (short*) 0x8400010c;
static volatile short *pcm_vol    = (short*) 0x84000110;
static volatile short *rec_select = (short*) 0x84000114;
static volatile short *rec_gain   = (short*) 0x84000118;

void set_master_vol(char mute, char left, char right)
{
	short val = 0;
	val |= mute ? 0x8000 : 0x0000;
	val |= (((255 - left) >> 2) & 0x3F) << 8;
	val |= ((255 - right) >> 2) & 0x3F;
	*master_vol = val;
}

void set_mic_vol(char mute, char volume, char boost)
{
	short val = 0;
	val |= mute ? 0x8000 : 0x0000;
	val |= boost ? 0x0040 : 0x0000;
	val |= (volume >> 3) & 0x1F;
	*mic_vol = val;
}

void set_line_in_vol(char mute, char left, char right)
{
	short val = 0;
	val |= mute ? 0x8000 : 0x0000;
	val |= (((255 - left) >> 3) & 0x1F) << 8;
	val |= ((255 - right) >> 3) & 0x1F;
	*line_vol = val;
}

void set_cd_vol(char mute, char left, char right)
{
	short val = 0;
	val |= mute ? 0x8000 : 0x0000;
	val |= (((255 - left) >> 3) & 0x1F) << 8;
	val |= ((255 - right) >> 3) & 0x1F;
	*cd_vol = val;
}

void set_pcm_vol(char mute, char left, char right)
{
	short val = 0;
	val |= mute ? 0x8000 : 0x0000;
	val |= (((255 - left) >> 3) & 0x1F) << 8;
	val |= ((255 - right) >> 3) & 0x1F;
	*pcm_vol = val;
}

void set_record_select(char leftdevice, char rightdevice)
{
	*rec_select = (leftdevice << 8) | rightdevice;
}

void set_record_gain(char mute, char left, char right)
{
	short val = 0;
	val |= mute ? 0x8000 : 0x0000;
	val |= ((left >> 4) & 0x1F) << 8;
	val |= (right >> 4) & 0x1F;
	*rec_gain = val;
}

void start_playback(void *location, int length, int mode)
{
	/* must align, or else dma falls over */
	*dma_length = length & ~0xFF;
	*dma_start = (int) location;
	*dma_cmd = mode;
}

void stop_playback()
{
	/* STOP command */
	*dma_cmd = 0;
}

int get_samples_played()
{
	return *dma_nread;
}

