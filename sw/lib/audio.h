/* 
 * Small audio library.
 *
 * All volumes are 0-255 (where 255 is the highest). 255 levels of granularity
 * not guaranteed.
 *
 * Mute: 1 to mute, 0 to unmute.
 */

#ifndef AUDIO_H
#define AUDIO_H

#define AUDIO_BYTES_PER_SAMP 4

#define AUDIO_MODE_ONCE 1
#define AUDIO_MODE_LOOP 2

/* options for record select */

#define REC_SEL_MIC    0
#define REC_SEL_CD     1
#define REC_SEL_VIDEO  2
#define REC_SEL_AUX    3
#define REC_SEL_LINE   4
#define REC_SEL_STEREO 5
#define REC_SEL_MONO   6
#define REC_SEL_PHONE  7

void audio_master_volume_set(char mute, char left, char right);
/* Note that the arguments to set_mic_vol are different. */
void audio_mic_volume_set(char mute, char volume, char boost);
void audio_linein_volume_set(char mute, char left, char right);
void audio_cd_volume_set(char mute, char left, char right);
void audio_pcm_volume_set(char mute, char left, char right);
void audio_rec_select_set(char leftdevice, char rightdevice);
void audio_rec_gain_set(char mute, char left, char right);
void audio_play(void *location, int length, int mode);
void audio_stop();
int audio_samples_played();

#endif
