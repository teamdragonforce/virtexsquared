CFLAGS=-mno-thumb-interwork -march=armv4 -Os -g -I../lib
OBJS=boot1.o ../lib/sysace.o ../lib/serial.o ../lib/keyhelp.o

all: boot1.bin

%.o: %.c
	arm-elf-gcc $(CFLAGS) -c -o $@ $<

%.o: %.S
	arm-elf-gcc $(CFLAGS) -c -o $@ $<

boot1.elf: $(OBJS) crt0.o script.lds
	arm-elf-ld -o $@ -T script.lds $(OBJS)

%.bin: %.elf
	arm-elf-objcopy $< -O binary $@

