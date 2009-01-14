//#test return 61

int ack(int m, int n)
{
	if(m == 0) {
		return n + 1;
	}
	else if(n == 0) {
		return ack(m - 1, 1);
	}
	else {
		return ack(m - 1, ack(m, n - 1));
	}
}

void acktest()
{	int x;
	if ((x = ack(3, 3)) != 61)
	{
		puts("FAIL: Ack test did not return 61\n");
		puthex(x);
	}
	else
		puts("PASS: Ack test returned 61\n");
}
