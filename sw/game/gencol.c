int r_int[] = { 1, 1, 0, 0, 0, 1, 0, 1, 1 };
int g_int[] = { 0, 1, 1, 1, 0, 0, 0, 1, 0 };
int b_int[] = { 0, 0, 0, 1, 1, 1, 0, 1, 0 };

unsigned char color_r(int t)
{
	int offs = (t >> 8) & 0x7;
	int c1 = r_int[offs];
	int c2 = r_int[offs+1];
	int tt = t & 0xFF;
	
	return (255-tt)*c1 + tt*c2;
}

unsigned char color_g(int t)
{
	int offs = (t >> 8) & 0x7;
	int c1 = g_int[offs];
	int c2 = g_int[offs+1];
	int tt = t & 0xFF;
	
	return (255-tt)*c1 + tt*c2;
}

unsigned char color_b(int t)
{
	int offs = (t >> 8) & 0x7;
	int c1 = b_int[offs];
	int c2 = b_int[offs+1];
	int tt = t & 0xFF;
	
	return (255-tt)*c1 + tt*c2;
}

unsigned int gencol(int t)
{
	return (color_r(t) << 24) | (color_g(t) << 16) | (color_b(t) << 8);
}