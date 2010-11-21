/* 
 * Small audio library.
 *
 * All volumes are 0-255 (where 255 is the highest). 255 levels of granularity
 * not guaranteed.
 *
 * Mute: 1 to mute, 0 to unmute.
 */

/* options for record select */

#define AUDIO_MODE_ONCE 1
#define AUDIO_MODE_LOOP 2

#define REC_SEL_MIC    0
#define REC_SEL_CD     1
#define REC_SEL_VIDEO  2
#define REC_SEL_AUX    3
#define REC_SEL_LINE   4
#define REC_SEL_STEREO 5
#define REC_SEL_MONO   6
#define REC_SEL_PHONE  7

void set_master_vol(char mute, char left, char right);
/* Note that the arguments to set_mic_vol are different. */
void set_mic_vol(char mute, char volume, char boost);
void set_line_in_vol(char mute, char left, char right);
void set_cd_vol(char mute, char left, char right);
void set_pcm_vol(char mute, char left, char right);
void set_record_select(char leftdevice, char rightdevice);
void set_record_gain(char mute, char left, char right);
void start_playback(void *location, int length, int mode);
void stop_playback();
int get_samples_played();
