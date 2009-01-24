//#test return -293203597

struct cpustate {
	int r0, r1, r2, r3, fr, pc, sp;
};

int abort()
{
	puts("FAIL [abort]\n");
	return 0;
}

int *ROM()
{
	static int a[] = {
		0x0E30,	/* 0 */
		0x0009,	/* 1 */
		0x0E00,	/* 2 */
		0x0039,	/* 3 */
		0x0E10,	/* 4 */
		0x4000,	/* 5 */
		0x0E20,	/* 6 */
		0xFFFF,	/* 7 */
		0x2E10,	/* 8 */
		0x4E32,	/* 9 */
		0x4E02,	/* A */
		0x5E32,	/* B */
		0x0250,	/* C */
		0x0008,	/* D */
		0x0E00,	/* E */
		0x000A,	/* F */
		0x2E10,	/* 10 */
		0xFFFF};	/* 11 */
	return a;
}

int crc32_update(int crc, int byte)
{
	int i, j;
	
	crc ^= byte;
	for (i = 0; i < 8; i += 1)
	{
		if (crc & 1)
			j = 3988292384;
		else
			j = 0;
		crc = (crc >> 1) ^ j;
	}
	return crc;
}

int muxreg(int reg, struct cpustate * s)
{
	if (reg == 0) return s->r0;
	if (reg == 1) return s->r1;
	if (reg == 2) return s->r2;
	if (reg == 3) return s->r3;
	if (reg == 4) return s->fr;
	if (reg == 5) return s->pc;
	if (reg == 6) return s->sp;
	return abort();
}

int setreg(int reg, int d, struct cpustate *s)
{
	if (reg == 0) s->r0 = d;
	if (reg == 1) s->r1 = d;
	if (reg == 2) s->r2 = d;
	if (reg == 3) s->r3 = d;
	if (reg == 4) s->fr = d;
	if (reg == 5) s->pc = d;
	if (reg == 6) s->sp = d;
	return 0;
}

int predcheck(int pred, struct cpustate *s)
{
	if (pred == 0)	return 0;
	if (pred == 1)	return !(s->fr & 4);
	if (pred == 2)	return (s->fr & 4);
	if (pred == 3)	return (s->fr & 1);
	if (pred == 4)	return (s->fr & 2);
	if (pred == 7)	return 1;
	return abort();
}

void testmain()
{
	struct cpustate cs, *s;
	int crc, iv, insn, pred, rt, rs, d;
	int* rom;
	
	s = &cs;
	crc = 0;
	iv = 0;
	insn = 0;
	s->pc = 0;
	s->r0 = 0;
	s->r1 = 0;
	s->r2 = 0;
	s->r3 = 0;
	s->fr = 0;
	s->sp = 0;
	rom = ROM();
	
	while (insn != 15)
	{
		iv = rom[s->pc];
		insn = iv >> 12;
		pred = (iv >> 9) & 7;
		rt = (iv >> 4) & 15;
		rs = iv & 15;
		crc = crc32_update(crc, s->r0);
		crc = crc32_update(crc, s->r1);
		crc = crc32_update(crc, s->r2);
		crc = crc32_update(crc, s->r3);
		crc = crc32_update(crc, s->fr);
		crc = crc32_update(crc, s->sp);
		crc = crc32_update(crc, s->pc);
		
		if (insn == 0)
		{
			s->pc += 1;
			if (!predcheck(pred, s))
			{
				s->pc += 1;
				continue;
			}
			d = rom[s->pc];
			s->pc += 1;
			setreg(rt, d, s);
		} else if (insn == 1) {
			s->pc += 1;
			if (!predcheck(pred, s))
				continue;
			d = rom[muxreg(rs, s)];
			setreg(rt, d, s);
		} else if (insn == 2) {
			s->pc += 1;
			if (!predcheck(pred, s))
				continue;
			d = muxreg(rs, s);
			if (muxreg(rt, s) != 16384)
				return abort();
			putchar(d);
		} else if (insn == 3) {
			s->pc += 1;
			if (!predcheck(pred, s))
				continue;
			d = muxreg(rs, s);
			setreg(rt, d, s);
		} else if (insn == 4) {
			s->pc += 1;
			if (!predcheck(pred, s))
				continue;
			d = muxreg(rs, s);
			d += muxreg(rt, s);
			d &= 65535;
			setreg(rt, d, s);
		} else if (insn == 5) {
			s->pc += 1;
			if (!predcheck(pred, s))
				continue;
			d = muxreg(rs, s);
			d -= muxreg(rt, s);
			s->fr = 0;
			if (d == 0) s->fr |= 4;
			if (d > 0) s->fr |= 1;
			if (d < 0) s->fr |= 2;
		} else if (insn == 6) {
			s->pc += 1;
			if (!predcheck(pred, s))
				continue;
			d = muxreg(rs, s);
			d &= muxreg(rt, s);
			setreg(rt, d, s);
		} else if (insn == 7) {
			s->pc += 1;
			if (!predcheck(pred, s))
				continue;
			d = muxreg(rt, s);
			d = ~d;
			d &= 65535;
			setreg(rt, d, s);
		}
	}
	
	if (crc != -293203597)
	{
		puthex(crc);
		puts(": FAIL\n");
	} else
		puts("PASS\n");
	return;
}
