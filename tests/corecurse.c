int b(int x);
int a(int x);

int a(int x)
{
	if (x)
		return b(x/2) + a(x - 1);
	return 1;
}

int b(int x)
{
	if (x)
		return a(x) + a(x - 1);
	return 0;
}

int corecurse()
{
	int v = a(35) + b(32) - 4450/28;
	if (v == 15411)
		puts("PASS\n");
	else
		puts("FAIL\n");
}