//#test return 151

/* example tree from http://en.wikipedia.org/wiki/Huffman_coding */

int getbyte(int byte)
{
	if (byte == 0) return 106;
	if (byte == 1) return 139;
	if (byte == 2) return 120;
	if (byte == 3) return 183;
	if (byte == 4) return 69;
	if (byte == 5) return 197;
	if (byte == 6) return 147;
	if (byte == 7) return 207;
	if (byte == 8) return 35;
	if (byte == 9) return 155;
	if (byte == 10) return 122;
	if (byte == 11) return 244;
	if (byte == 12) return 125;
	if (byte == 13) return 215;
	if (byte == 14) return 69;
	if (byte == 15) return 219;
	if (byte == 16) return 2;
	if (byte == 17) return 224;
	puts("FAIL [abort]: request for byte #");
	puthex(byte);
	while(1);
	return 0;
}

int getbit(int bp)
{
	int byte;
	byte = getbyte(bp/8);
	return (byte >> (7 - (bp % 8))) & 1;
}

int h(int bitpos)
{
	if (getbit(bitpos))
		return h1(bitpos+1);
	else
		return h0(bitpos+1);
}

int h0(int bitpos)
{
	if (getbit(bitpos))
		return h01(bitpos+1);
	else
		return h00(bitpos+1);
}

int h00(int bitpos)
{
	if (getbit(bitpos))
		return h001(bitpos+1);
	else
		return 69+h(bitpos+1);
}

int h001(int bitpos)
{
	if (getbit(bitpos))
		return h0011(bitpos+1);
	else
		return 78+h(bitpos+1);
}

int h0011(int bitpos)
{
	if (getbit(bitpos))
		return 79+h(bitpos+1);
	else
		return 85+h(bitpos+1);
}

int h01(int bitpos)
{
	if (getbit(bitpos))
		return h011(bitpos+1);
	else
		return 65+h(bitpos+1);
}

int h011(int bitpos)
{
	if (getbit(bitpos))
		return 77+h(bitpos+1);
	else
		return 84+h(bitpos+1);
}

int h1(bitpos)
{
	if (getbit(bitpos))
		return h11(bitpos+1);
	else
		return h10(bitpos+1);
}

int h10(bitpos)
{
	if (getbit(bitpos))
		return h101(bitpos+1);
	else
		return h100(bitpos+1);
}

int h100(bitpos)
{
	if (getbit(bitpos))
		return h1001(bitpos+1);
	else
		return 73+h(bitpos+1);
}

int h1001(bitpos)
{
	if (getbit(bitpos))
		return 80+h(bitpos+1);
	else
		return 88+h(bitpos+1);
}

int h101(bitpos)
{
	if (getbit(bitpos))
		return h1011(bitpos+1);
	else
		return 72+h(bitpos+1);
}

int h1011(bitpos)
{
	if (getbit(bitpos))
		return -2169;
	else
		return 83+h(bitpos+1);
}

int h11(bitpos)
{
	if (getbit(bitpos))
		return 32+h(bitpos+1);
	else
		return h110(bitpos+1);
}

int h110(bitpos)
{
	if (getbit(bitpos))
		return 70+h(bitpos+1);
	else
		return h1100(bitpos+1);
}

int h1100(bitpos)
{
	if (getbit(bitpos))
		return 76+h(bitpos+1);
	else
		return 82+h(bitpos+1);
}

void j4cbo()
{
	if (h(0) != 151)
		puts("Result was not 151\r\n");
	else
		puts("Result was 151\r\n");
}
