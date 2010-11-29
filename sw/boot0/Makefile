CFLAGS=-mno-thumb-interwork -march=armv4 -Os -g -I../lib
OBJS=boot0.o ../lib/sysace.o ../lib/serial.o ../lib/minilib.o

all: boot0.pad.hex boot0.pad.hex64 boot0.hex

%.o: %.c
	arm-elf-gcc $(CFLAGS) -c -o $@ $<

%.o: %.S
	arm-elf-gcc $(CFLAGS) -c -o $@ $<

boot0.elf: $(OBJS) crt0.o script.lds
	arm-elf-gcc -static -o $@ -Wl,-T script.lds $(OBJS) -nostartfiles -nodefaultlibs -lgcc

%.bin: %.elf
	arm-elf-objcopy $< -O binary $@

%.pad.bin: %.bin
	dd if=$< of=$@ bs=16384 conv=sync

%.hex: %.bin
	xxd -ps -c 4 $< | sed -e 's/\(..\)\(..\)\(..\)\(..\)/\4\3\2\1/' > $@

# lurrr qword order is backwards and I am too lazy to fix it all through the RTL!
%.hex64: %.bin
	xxd -ps -c 8 $< | sed -e 's/\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)/\8\7\6\5\4\3\2\1/' > $@
