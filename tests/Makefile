all: costas.hex

%.o: %.c
	arm-elf-gcc -c -o $@ $<

%.o: %.S
	arm-elf-gcc -c -o $@ $<

%.elf: %.o anulib.o script.lds
	arm-elf-ld -o $@ -T script.lds anulib.o $<

%.bin: %.elf
	arm-elf-objcopy $< -O binary $@

%.hex: %.bin
	xxd -ps -c 4 $< | sed -e 's/\(..\)\(..\)\(..\)\(..\)/\4\3\2\1/' > $@
