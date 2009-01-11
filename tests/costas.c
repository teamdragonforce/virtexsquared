extern void putc(unsigned char c);

int main()
{
	unsigned char *costas = "Costas likes ass";
	
	putc('A');
	putc('n');
	putc('u');
	putc('s');
	putc('?');
	
	while (*costas)
	{
		putc(*costas);
		costas++;
	}
	
	return 0;
}
