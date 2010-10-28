module chipscope_ila (
  CLK, CONTROL, TRIG0
)/* synthesis syn_black_box syn_noprune=1 */;
  input CLK;
  inout [35 : 0] CONTROL;
  input [255 : 0] TRIG0;

endmodule
