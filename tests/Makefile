CFLAGS=-mno-thumb-interwork -march=armv4 -Os -g

all: testbench.pad.hex testbench.pad.hex64 testbench.hex

%.o: %.c
	arm-elf-gcc $(CFLAGS) -c -o $@ $<

%.o: %.S
	arm-elf-gcc $(CFLAGS) -c -o $@ $<

%.elf: %.o anulib.o script.lds
	arm-elf-ld -o $@ -T script.lds anulib.o $<

%.bin: %.elf
	arm-elf-objcopy $< -O binary $@

%.pad.bin: %.bin
	dd if=$< of=$@ bs=16384 conv=sync

%.hex: %.bin
	xxd -ps -c 4 $< | sed -e 's/\(..\)\(..\)\(..\)\(..\)/\4\3\2\1/' > $@

# lurrr qword order is backwards and I am too lazy to fix it all through the RTL!
%.hex64: %.bin
	xxd -ps -c 8 $< | sed -e 's/\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)/\8\7\6\5\4\3\2\1/' > $@
