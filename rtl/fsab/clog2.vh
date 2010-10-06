function integer clog2;
	input [31:0] value;
	begin
		for (clog2=0; value>0; clog2=clog2+1)
			value = value>>1;
	end
endfunction
