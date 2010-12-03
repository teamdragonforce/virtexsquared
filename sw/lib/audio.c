/* Small audio library. */
#include "audio.h"

static volatile int *dma_start  = (int*) 0x84000000;
static volatile int *dma_length = (int*) 0x84000004;
static volatile int *dma_cmd    = (int*) 0x84000008;
static volatile int *dma_nread  = (int*) 0x84000010;

static volatile short *master_vol = (short*) 0x84000100;
static volatile short *mic_vol    = (short*) 0x84000104;
static volatile short *line_vol   = (short*) 0x84000108;
static volatile short *cd_vol     = (short*) 0x8400010c;
static volatile short *pcm_vol    = (short*) 0x84000110;
static volatile short *rec_select = (short*) 0x84000114;
static volatile short *rec_gain   = (short*) 0x84000118;

void audio_master_volume_set(char mute, char left, char right)
{
	short val = 0;
	val |= mute ? 0x8000 : 0x0000;
	val |= (((255 - left) >> 2) & 0x3F) << 8;
	val |= ((255 - right) >> 2) & 0x3F;
	*master_vol = val;
}

void audio_mic_volume_set(char mute, char volume, char boost)
{
	short val = 0;
	val |= mute ? 0x8000 : 0x0000;
	val |= boost ? 0x0040 : 0x0000;
	val |= (volume >> 3) & 0x1F;
	*mic_vol = val;
}

void audio_linein_volume_set(char mute, char left, char right)
{
	short val = 0;
	val |= mute ? 0x8000 : 0x0000;
	val |= (((255 - left) >> 3) & 0x1F) << 8;
	val |= ((255 - right) >> 3) & 0x1F;
	*line_vol = val;
}

void audio_cd_volume_set(char mute, char left, char right)
{
	short val = 0;
	val |= mute ? 0x8000 : 0x0000;
	val |= (((255 - left) >> 3) & 0x1F) << 8;
	val |= ((255 - right) >> 3) & 0x1F;
	*cd_vol = val;
}

void audio_pcm_volume_set(char mute, char left, char right)
{
	short val = 0;
	val |= mute ? 0x8000 : 0x0000;
	val |= (((255 - left) >> 3) & 0x1F) << 8;
	val |= ((255 - right) >> 3) & 0x1F;
	*pcm_vol = val;
}

void audio_rec_select_set(char leftdevice, char rightdevice)
{
	*rec_select = (leftdevice << 8) | rightdevice;
}

void audio_rec_gain_set(char mute, char left, char right)
{
	short val = 0;
	val |= mute ? 0x8000 : 0x0000;
	val |= ((left >> 4) & 0x1F) << 8;
	val |= (right >> 4) & 0x1F;
	*rec_gain = val;
}

void audio_play(void *location, int length, int mode)
{
	/* must align, or else dma falls over */
	*dma_length = length & ~0xFF;
	*dma_start = (int) location;
	*dma_cmd = mode;
}

void audio_stop()
{
	/* STOP command */
	*dma_cmd = 0;
}

int audio_samples_played()
{
	return *dma_nread/AUDIO_BYTES_PER_SAMP;
}

int is_audio_done(int len)
{
	return (*dma_nread == (len & ~0xFF));
}



