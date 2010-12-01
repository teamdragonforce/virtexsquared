CFLAGS=-mno-thumb-interwork -march=armv4 -O3 -g -I../lib
OBJS=game.o gencol.o \
	../lib/sysace.o ../lib/serial.o ../lib/doprnt.o ../lib/minilib.o \
	../lib/sprintf.o ../lib/keyhelp.o ../lib/console.o ../lib/fat16.o \
	../lib/audio.o ../lib/accel.o ../lib/qalloc.o ../lib/malloc.o \
	../lib/multibuf.o

TARGET=game.elf

all: $(TARGET)

%.o: %.c
	arm-elf-gcc $(CFLAGS) -c -o $@ $<

%.o: %.S
	arm-elf-gcc $(CFLAGS) -c -o $@ $<

$(TARGET): $(OBJS) crt0.o script.lds
	arm-elf-gcc -static -o $@ -Wl,-T script.lds $(OBJS) -nostartfiles -nodefaultlibs -lgcc

%.bin: %.elf
	arm-elf-objcopy $< -O binary $@

