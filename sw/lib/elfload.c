/* loader.c
 * ELF loading subroutines
 * NetWatch multiboot loader
 *
 * Copyright (c) 2008 Jacob Potter and Joshua Wise.  All rights reserved.
 * This program is free software; you can redistribute and/or modify it under
 * the terms found in the file LICENSE in the root of this source tree. 
 *
 */

#include "elf.h"
#include "minilib.h"

static const unsigned char elf_ident[4] = { 0x7F, 'E', 'L', 'F' }; 

void *elf_load (char * buf, int size) {

	Elf32_Ehdr * elf_hdr = (Elf32_Ehdr *) buf;
	Elf32_Shdr * elf_sec_hdrs = (Elf32_Shdr *) (buf + elf_hdr->e_shoff);

	/* Sanity check on ELF file */
	if (memcmp((void *)elf_hdr->e_ident, (void *)elf_ident, sizeof(elf_ident))) {
		printf("ELF: header identification incorrect\r\n");
		return NULL;
	}
	if (elf_hdr->e_type != ET_EXEC) {
		printf("ELF: not executable\r\n");
		return NULL;
	}
	if (elf_hdr->e_machine != EM_ARM) {
		printf("ELF: not ARM\r\n");
		return NULL;
	}
	if (elf_hdr->e_version != EV_CURRENT) {
		printf("ELF: wrong version\r\n");
		return NULL;
	}
	if (size < sizeof(Elf32_Ehdr)) {
		printf("ELF: too small\r\n");
		return NULL;
	}
	if (((char *)&elf_sec_hdrs[elf_hdr->e_shnum]) > (buf + size)) {
		printf("ELF: section headers too far out\r\n");
		return NULL;
	}

	char * string_table = buf + elf_sec_hdrs[elf_hdr->e_shstrndx].sh_offset;

	if (string_table > (buf + size)) {
		printf("ELF: string table too far out\r\n");
		return NULL;
	}

	int i;
	for (i = 0; i < elf_hdr->e_shnum; i++) {

		if (elf_sec_hdrs[i].sh_name == SHN_UNDEF) {
			continue;
		}

		char * section_name = string_table + elf_sec_hdrs[i].sh_name;

		if ((elf_sec_hdrs[i].sh_type != SHT_PROGBITS) || !(elf_sec_hdrs[i].sh_flags & SHF_ALLOC)) {
			printf("ELF: skipping %s\r\n", section_name);
			continue;
		}

		printf("ELF: loading %s at %08x\r\n", section_name, elf_sec_hdrs[i].sh_addr);

		memcpy((void *)elf_sec_hdrs[i].sh_addr,
		       buf + elf_sec_hdrs[i].sh_offset,
		       elf_sec_hdrs[i].sh_size);
	}

	return (void *)elf_hdr->e_entry;
}
