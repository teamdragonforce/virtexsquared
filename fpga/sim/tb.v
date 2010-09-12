`timescale 1 ns/1 ps

module tb();
  reg clk = 0;
  wire [8:0] odata;
  
  System system(.clk(clk), .rst(1'b0), .sys_odata(odata), .sys_idata(9'b0), .sys_tookdata(tookdata));
  glbl glbl();
  
  initial begin
    $monitor($stime,,"odata: %x = %c", odata, odata[7:0]);
    while(1)
      #30 clk <= ~clk;
  end
endmodule
