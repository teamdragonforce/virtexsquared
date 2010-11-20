CFLAGS=-mno-thumb-interwork -march=armv4 -Os -g -I../lib
OBJS=boot1.o ../lib/sysace.o ../lib/serial.o ../lib/doprnt.o ../lib/minilib.o ../lib/sprintf.o ../lib/keyhelp.o ../lib/console.o

all: boot1.bin

%.o: %.c
	arm-elf-gcc $(CFLAGS) -c -o $@ $<

%.o: %.S
	arm-elf-gcc $(CFLAGS) -c -o $@ $<

boot1.elf: $(OBJS) crt0.o script.lds
	arm-elf-gcc -static -o $@ -Wl,-T script.lds $(OBJS) -nostartfiles -nodefaultlibs -lgcc

%.bin: %.elf
	arm-elf-objcopy $< -O binary $@

