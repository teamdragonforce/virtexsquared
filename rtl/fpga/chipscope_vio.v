////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2010 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: M.70d
//  \   \         Application: netgen
//  /   /         Filename: chipscope_vio.v
// /___/   /\     Timestamp: Sat Oct 23 05:04:13 2010
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -w -sim -ofmt verilog /home/joshua/virtexsquared/tmp/_cg/chipscope_vio.ngc /home/joshua/virtexsquared/tmp/_cg/chipscope_vio.v 
// Device	: xc5vlx110t-ff1136-1
// Input file	: /home/joshua/virtexsquared/tmp/_cg/chipscope_vio.ngc
// Output file	: /home/joshua/virtexsquared/tmp/_cg/chipscope_vio.v
// # of Modules	: 1
// Design Name	: chipscope_vio
// Xilinx        : /opt/Xilinx/12.3/ISE_DS/ISE/
//             
// Purpose:    
//     This verilog netlist is a verification model and uses simulation 
//     primitives which may not represent the true implementation of the 
//     device, however the netlist is functionally correct and should not 
//     be modified. This file cannot be synthesized and should only be used 
//     with supported simulation tools.
//             
// Reference:  
//     Command Line Tools User Guide, Chapter 23 and Synthesis and Simulation Design Guide, Chapter 6
//             
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/1 ps

module chipscope_vio (
  CLK, CONTROL, SYNC_IN
)/* synthesis syn_black_box syn_noprune=1 */;
  input CLK;
  inout [35 : 0] CONTROL;
  input [8 : 0] SYNC_IN;
  
  // synthesis translate_off
  
  wire N0;
  wire N1;
  wire N36;
  wire N38;
  wire \U0/I_VIO/DATA_DOUT ;
  wire \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/async_mux_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/async_mux_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/clocked ;
  wire \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/falling ;
  wire \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/falling_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/fd1_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/fd2_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/fd3_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/fd4_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/fd5_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/mux1_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/rising ;
  wire \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/rising_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ;
  wire \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_f_edge/iDOUT<1> ;
  wire \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_mux_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_mux_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ;
  wire \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_r_edge/iDOUT<1> ;
  wire \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/user_in_n ;
  wire \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/async_mux_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/async_mux_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/clocked ;
  wire \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/falling ;
  wire \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/falling_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/fd1_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/fd2_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/fd3_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/fd4_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/fd5_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/mux1_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/rising ;
  wire \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/rising_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ;
  wire \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_f_edge/iDOUT<1> ;
  wire \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_mux_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_mux_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ;
  wire \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_r_edge/iDOUT<1> ;
  wire \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/user_in_n ;
  wire \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/async_mux_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/async_mux_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/clocked ;
  wire \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/falling ;
  wire \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/falling_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/fd1_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/fd2_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/fd3_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/fd4_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/fd5_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/mux1_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/rising ;
  wire \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/rising_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ;
  wire \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_f_edge/iDOUT<1> ;
  wire \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_mux_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_mux_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ;
  wire \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_r_edge/iDOUT<1> ;
  wire \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/user_in_n ;
  wire \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/async_mux_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/async_mux_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/clocked ;
  wire \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/falling ;
  wire \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/falling_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/fd1_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/fd2_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/fd3_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/fd4_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/fd5_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/mux1_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/rising ;
  wire \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/rising_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ;
  wire \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_f_edge/iDOUT<1> ;
  wire \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_mux_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_mux_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ;
  wire \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_r_edge/iDOUT<1> ;
  wire \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/user_in_n ;
  wire \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/async_mux_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/async_mux_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/clocked ;
  wire \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/falling ;
  wire \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/falling_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/fd1_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/fd2_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/fd3_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/fd4_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/fd5_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/mux1_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/rising ;
  wire \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/rising_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ;
  wire \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_f_edge/iDOUT<1> ;
  wire \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_mux_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_mux_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ;
  wire \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_r_edge/iDOUT<1> ;
  wire \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/user_in_n ;
  wire \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/async_mux_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/async_mux_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/clocked ;
  wire \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/falling ;
  wire \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/falling_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/fd1_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/fd2_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/fd3_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/fd4_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/fd5_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/mux1_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/rising ;
  wire \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/rising_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ;
  wire \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_f_edge/iDOUT<1> ;
  wire \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_mux_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_mux_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ;
  wire \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_r_edge/iDOUT<1> ;
  wire \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/user_in_n ;
  wire \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/async_mux_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/async_mux_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/clocked ;
  wire \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/falling ;
  wire \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/falling_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/fd1_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/fd2_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/fd3_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/fd4_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/fd5_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/mux1_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/rising ;
  wire \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/rising_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ;
  wire \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_f_edge/iDOUT<1> ;
  wire \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_mux_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_mux_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ;
  wire \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_r_edge/iDOUT<1> ;
  wire \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/user_in_n ;
  wire \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/async_mux_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/async_mux_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/clocked ;
  wire \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/falling ;
  wire \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/falling_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/fd1_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/fd2_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/fd3_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/fd4_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/fd5_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/mux1_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/rising ;
  wire \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/rising_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ;
  wire \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_f_edge/iDOUT<1> ;
  wire \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_mux_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_mux_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ;
  wire \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_r_edge/iDOUT<1> ;
  wire \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/user_in_n ;
  wire \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/async_mux_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/async_mux_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/clocked ;
  wire \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/falling ;
  wire \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/falling_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/fd1_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/fd2_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/fd3_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/fd4_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/fd5_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/mux1_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/rising ;
  wire \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/rising_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ;
  wire \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_f_edge/iDOUT<1> ;
  wire \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_mux_f_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_mux_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ;
  wire \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_r_edge/iDOUT<1> ;
  wire \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_r_out ;
  wire \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/user_in_n ;
  wire \U0/I_VIO/RESET ;
  wire \U0/I_VIO/STAT_DOUT ;
  wire \U0/I_VIO/U_STATUS/CFG_CE_n ;
  wire \U0/I_VIO/U_STATUS/TDO_next ;
  wire \U0/I_VIO/U_STATUS/U_SMUX/U_CS_MUX/I4.U_MUX16/Mmux_O_6_262 ;
  wire \U0/I_VIO/U_STATUS/U_SMUX/U_CS_MUX/I4.U_MUX16/Mmux_O_7_263 ;
  wire \U0/I_VIO/U_STATUS/iSTAT_CNT<7>128_303 ;
  wire \U0/I_VIO/U_STATUS/iSTAT_CNT<7>164_304 ;
  wire \U0/I_VIO/U_STATUS/iSTAT_CNT<7>260_305 ;
  wire \U0/I_VIO/U_STATUS/iSTAT_CNT<7>35_306 ;
  wire \U0/I_VIO/U_STATUS/iSTAT_CNT<7>71_307 ;
  wire [9 : 1] \U0/I_VIO/INPUT_SHIFT ;
  wire [7 : 1] \U0/I_VIO/U_STATUS/U_STAT_CNT/CI ;
  wire [7 : 0] \U0/I_VIO/U_STATUS/U_STAT_CNT/D ;
  wire [7 : 0] \U0/I_VIO/U_STATUS/U_STAT_CNT/S ;
  wire [7 : 0] \U0/I_VIO/U_STATUS/iSTAT ;
  wire [7 : 0] \U0/I_VIO/U_STATUS/iSTAT_CNT ;
  wire [1 : 0] \U0/I_VIO/reset_f_edge/iDOUT ;
  GND   XST_GND (
    .G(N0)
  );
  VCC   XST_VCC (
    .P(N1)
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/U_STATUS/U_TDO  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/U_STATUS/TDO_next ),
    .Q(\U0/I_VIO/STAT_DOUT )
  );
  LUT6 #(
    .INIT ( 64'hF7E6B3A2D5C49180 ))
  \U0/I_VIO/U_STATUS/U_SMUX/U_CS_MUX/I4.U_MUX16/Mmux_O_7  (
    .I0(\U0/I_VIO/U_STATUS/iSTAT_CNT [5]),
    .I1(\U0/I_VIO/U_STATUS/iSTAT_CNT [4]),
    .I2(\U0/I_VIO/U_STATUS/iSTAT [3]),
    .I3(\U0/I_VIO/U_STATUS/iSTAT [0]),
    .I4(\U0/I_VIO/U_STATUS/iSTAT [1]),
    .I5(\U0/I_VIO/U_STATUS/iSTAT [2]),
    .O(\U0/I_VIO/U_STATUS/U_SMUX/U_CS_MUX/I4.U_MUX16/Mmux_O_7_263 )
  );
  LUT6 #(
    .INIT ( 64'hF7E6B3A2D5C49180 ))
  \U0/I_VIO/U_STATUS/U_SMUX/U_CS_MUX/I4.U_MUX16/Mmux_O_6  (
    .I0(\U0/I_VIO/U_STATUS/iSTAT_CNT [5]),
    .I1(\U0/I_VIO/U_STATUS/iSTAT_CNT [4]),
    .I2(\U0/I_VIO/U_STATUS/iSTAT [7]),
    .I3(\U0/I_VIO/U_STATUS/iSTAT [4]),
    .I4(\U0/I_VIO/U_STATUS/iSTAT [5]),
    .I5(\U0/I_VIO/U_STATUS/iSTAT [6]),
    .O(\U0/I_VIO/U_STATUS/U_SMUX/U_CS_MUX/I4.U_MUX16/Mmux_O_6_262 )
  );
  INV   \U0/I_VIO/U_STATUS/U_CE_n  (
    .I(CONTROL[4]),
    .O(\U0/I_VIO/U_STATUS/CFG_CE_n )
  );
  LUT4 #(
    .INIT ( 16'h0000 ))
  \U0/I_VIO/U_STATUS/F_STAT[7].I_STAT.U_STAT  (
    .I0(\U0/I_VIO/U_STATUS/iSTAT_CNT [0]),
    .I1(\U0/I_VIO/U_STATUS/iSTAT_CNT [1]),
    .I2(\U0/I_VIO/U_STATUS/iSTAT_CNT [2]),
    .I3(\U0/I_VIO/U_STATUS/iSTAT_CNT [3]),
    .O(\U0/I_VIO/U_STATUS/iSTAT [7])
  );
  LUT4 #(
    .INIT ( 16'h0000 ))
  \U0/I_VIO/U_STATUS/F_STAT[6].I_STAT.U_STAT  (
    .I0(\U0/I_VIO/U_STATUS/iSTAT_CNT [0]),
    .I1(\U0/I_VIO/U_STATUS/iSTAT_CNT [1]),
    .I2(\U0/I_VIO/U_STATUS/iSTAT_CNT [2]),
    .I3(\U0/I_VIO/U_STATUS/iSTAT_CNT [3]),
    .O(\U0/I_VIO/U_STATUS/iSTAT [6])
  );
  LUT4 #(
    .INIT ( 16'h0000 ))
  \U0/I_VIO/U_STATUS/F_STAT[5].I_STAT.U_STAT  (
    .I0(\U0/I_VIO/U_STATUS/iSTAT_CNT [0]),
    .I1(\U0/I_VIO/U_STATUS/iSTAT_CNT [1]),
    .I2(\U0/I_VIO/U_STATUS/iSTAT_CNT [2]),
    .I3(\U0/I_VIO/U_STATUS/iSTAT_CNT [3]),
    .O(\U0/I_VIO/U_STATUS/iSTAT [5])
  );
  LUT4 #(
    .INIT ( 16'h9000 ))
  \U0/I_VIO/U_STATUS/F_STAT[4].I_STAT.U_STAT  (
    .I0(\U0/I_VIO/U_STATUS/iSTAT_CNT [0]),
    .I1(\U0/I_VIO/U_STATUS/iSTAT_CNT [1]),
    .I2(\U0/I_VIO/U_STATUS/iSTAT_CNT [2]),
    .I3(\U0/I_VIO/U_STATUS/iSTAT_CNT [3]),
    .O(\U0/I_VIO/U_STATUS/iSTAT [4])
  );
  LUT4 #(
    .INIT ( 16'h0610 ))
  \U0/I_VIO/U_STATUS/F_STAT[3].I_STAT.U_STAT  (
    .I0(\U0/I_VIO/U_STATUS/iSTAT_CNT [0]),
    .I1(\U0/I_VIO/U_STATUS/iSTAT_CNT [1]),
    .I2(\U0/I_VIO/U_STATUS/iSTAT_CNT [2]),
    .I3(\U0/I_VIO/U_STATUS/iSTAT_CNT [3]),
    .O(\U0/I_VIO/U_STATUS/iSTAT [3])
  );
  LUT4 #(
    .INIT ( 16'h2100 ))
  \U0/I_VIO/U_STATUS/F_STAT[2].I_STAT.U_STAT  (
    .I0(\U0/I_VIO/U_STATUS/iSTAT_CNT [0]),
    .I1(\U0/I_VIO/U_STATUS/iSTAT_CNT [1]),
    .I2(\U0/I_VIO/U_STATUS/iSTAT_CNT [2]),
    .I3(\U0/I_VIO/U_STATUS/iSTAT_CNT [3]),
    .O(\U0/I_VIO/U_STATUS/iSTAT [2])
  );
  LUT4 #(
    .INIT ( 16'hC309 ))
  \U0/I_VIO/U_STATUS/F_STAT[1].I_STAT.U_STAT  (
    .I0(\U0/I_VIO/U_STATUS/iSTAT_CNT [0]),
    .I1(\U0/I_VIO/U_STATUS/iSTAT_CNT [1]),
    .I2(\U0/I_VIO/U_STATUS/iSTAT_CNT [2]),
    .I3(\U0/I_VIO/U_STATUS/iSTAT_CNT [3]),
    .O(\U0/I_VIO/U_STATUS/iSTAT [1])
  );
  LUT4 #(
    .INIT ( 16'h0101 ))
  \U0/I_VIO/U_STATUS/F_STAT[0].I_STAT.U_STAT  (
    .I0(\U0/I_VIO/U_STATUS/iSTAT_CNT [0]),
    .I1(\U0/I_VIO/U_STATUS/iSTAT_CNT [1]),
    .I2(\U0/I_VIO/U_STATUS/iSTAT_CNT [2]),
    .I3(\U0/I_VIO/U_STATUS/iSTAT_CNT [3]),
    .O(\U0/I_VIO/U_STATUS/iSTAT [0])
  );
  XORCY   \U0/I_VIO/U_STATUS/U_STAT_CNT/G[0].U_XORCY  (
    .CI(N1),
    .LI(\U0/I_VIO/U_STATUS/U_STAT_CNT/S [0]),
    .O(\U0/I_VIO/U_STATUS/U_STAT_CNT/D [0])
  );
  MUXCY_L   \U0/I_VIO/U_STATUS/U_STAT_CNT/G[0].GnH.U_MUXCY  (
    .CI(N1),
    .DI(N0),
    .S(\U0/I_VIO/U_STATUS/U_STAT_CNT/S [0]),
    .LO(\U0/I_VIO/U_STATUS/U_STAT_CNT/CI [1])
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \U0/I_VIO/U_STATUS/U_STAT_CNT/G[0].U_LUT  (
    .I0(\U0/I_VIO/U_STATUS/iSTAT_CNT [0]),
    .O(\U0/I_VIO/U_STATUS/U_STAT_CNT/S [0])
  );
  XORCY   \U0/I_VIO/U_STATUS/U_STAT_CNT/G[1].U_XORCY  (
    .CI(\U0/I_VIO/U_STATUS/U_STAT_CNT/CI [1]),
    .LI(\U0/I_VIO/U_STATUS/U_STAT_CNT/S [1]),
    .O(\U0/I_VIO/U_STATUS/U_STAT_CNT/D [1])
  );
  MUXCY_L   \U0/I_VIO/U_STATUS/U_STAT_CNT/G[1].GnH.U_MUXCY  (
    .CI(\U0/I_VIO/U_STATUS/U_STAT_CNT/CI [1]),
    .DI(N0),
    .S(\U0/I_VIO/U_STATUS/U_STAT_CNT/S [1]),
    .LO(\U0/I_VIO/U_STATUS/U_STAT_CNT/CI [2])
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \U0/I_VIO/U_STATUS/U_STAT_CNT/G[1].U_LUT  (
    .I0(\U0/I_VIO/U_STATUS/iSTAT_CNT [1]),
    .O(\U0/I_VIO/U_STATUS/U_STAT_CNT/S [1])
  );
  XORCY   \U0/I_VIO/U_STATUS/U_STAT_CNT/G[2].U_XORCY  (
    .CI(\U0/I_VIO/U_STATUS/U_STAT_CNT/CI [2]),
    .LI(\U0/I_VIO/U_STATUS/U_STAT_CNT/S [2]),
    .O(\U0/I_VIO/U_STATUS/U_STAT_CNT/D [2])
  );
  MUXCY_L   \U0/I_VIO/U_STATUS/U_STAT_CNT/G[2].GnH.U_MUXCY  (
    .CI(\U0/I_VIO/U_STATUS/U_STAT_CNT/CI [2]),
    .DI(N0),
    .S(\U0/I_VIO/U_STATUS/U_STAT_CNT/S [2]),
    .LO(\U0/I_VIO/U_STATUS/U_STAT_CNT/CI [3])
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \U0/I_VIO/U_STATUS/U_STAT_CNT/G[2].U_LUT  (
    .I0(\U0/I_VIO/U_STATUS/iSTAT_CNT [2]),
    .O(\U0/I_VIO/U_STATUS/U_STAT_CNT/S [2])
  );
  XORCY   \U0/I_VIO/U_STATUS/U_STAT_CNT/G[3].U_XORCY  (
    .CI(\U0/I_VIO/U_STATUS/U_STAT_CNT/CI [3]),
    .LI(\U0/I_VIO/U_STATUS/U_STAT_CNT/S [3]),
    .O(\U0/I_VIO/U_STATUS/U_STAT_CNT/D [3])
  );
  MUXCY_L   \U0/I_VIO/U_STATUS/U_STAT_CNT/G[3].GnH.U_MUXCY  (
    .CI(\U0/I_VIO/U_STATUS/U_STAT_CNT/CI [3]),
    .DI(N0),
    .S(\U0/I_VIO/U_STATUS/U_STAT_CNT/S [3]),
    .LO(\U0/I_VIO/U_STATUS/U_STAT_CNT/CI [4])
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \U0/I_VIO/U_STATUS/U_STAT_CNT/G[3].U_LUT  (
    .I0(\U0/I_VIO/U_STATUS/iSTAT_CNT [3]),
    .O(\U0/I_VIO/U_STATUS/U_STAT_CNT/S [3])
  );
  XORCY   \U0/I_VIO/U_STATUS/U_STAT_CNT/G[4].U_XORCY  (
    .CI(\U0/I_VIO/U_STATUS/U_STAT_CNT/CI [4]),
    .LI(\U0/I_VIO/U_STATUS/U_STAT_CNT/S [4]),
    .O(\U0/I_VIO/U_STATUS/U_STAT_CNT/D [4])
  );
  MUXCY_L   \U0/I_VIO/U_STATUS/U_STAT_CNT/G[4].GnH.U_MUXCY  (
    .CI(\U0/I_VIO/U_STATUS/U_STAT_CNT/CI [4]),
    .DI(N0),
    .S(\U0/I_VIO/U_STATUS/U_STAT_CNT/S [4]),
    .LO(\U0/I_VIO/U_STATUS/U_STAT_CNT/CI [5])
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \U0/I_VIO/U_STATUS/U_STAT_CNT/G[4].U_LUT  (
    .I0(\U0/I_VIO/U_STATUS/iSTAT_CNT [4]),
    .O(\U0/I_VIO/U_STATUS/U_STAT_CNT/S [4])
  );
  XORCY   \U0/I_VIO/U_STATUS/U_STAT_CNT/G[5].U_XORCY  (
    .CI(\U0/I_VIO/U_STATUS/U_STAT_CNT/CI [5]),
    .LI(\U0/I_VIO/U_STATUS/U_STAT_CNT/S [5]),
    .O(\U0/I_VIO/U_STATUS/U_STAT_CNT/D [5])
  );
  MUXCY_L   \U0/I_VIO/U_STATUS/U_STAT_CNT/G[5].GnH.U_MUXCY  (
    .CI(\U0/I_VIO/U_STATUS/U_STAT_CNT/CI [5]),
    .DI(N0),
    .S(\U0/I_VIO/U_STATUS/U_STAT_CNT/S [5]),
    .LO(\U0/I_VIO/U_STATUS/U_STAT_CNT/CI [6])
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \U0/I_VIO/U_STATUS/U_STAT_CNT/G[5].U_LUT  (
    .I0(\U0/I_VIO/U_STATUS/iSTAT_CNT [5]),
    .O(\U0/I_VIO/U_STATUS/U_STAT_CNT/S [5])
  );
  XORCY   \U0/I_VIO/U_STATUS/U_STAT_CNT/G[6].U_XORCY  (
    .CI(\U0/I_VIO/U_STATUS/U_STAT_CNT/CI [6]),
    .LI(\U0/I_VIO/U_STATUS/U_STAT_CNT/S [6]),
    .O(\U0/I_VIO/U_STATUS/U_STAT_CNT/D [6])
  );
  MUXCY_L   \U0/I_VIO/U_STATUS/U_STAT_CNT/G[6].GnH.U_MUXCY  (
    .CI(\U0/I_VIO/U_STATUS/U_STAT_CNT/CI [6]),
    .DI(N0),
    .S(\U0/I_VIO/U_STATUS/U_STAT_CNT/S [6]),
    .LO(\U0/I_VIO/U_STATUS/U_STAT_CNT/CI [7])
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \U0/I_VIO/U_STATUS/U_STAT_CNT/G[6].U_LUT  (
    .I0(\U0/I_VIO/U_STATUS/iSTAT_CNT [6]),
    .O(\U0/I_VIO/U_STATUS/U_STAT_CNT/S [6])
  );
  XORCY   \U0/I_VIO/U_STATUS/U_STAT_CNT/G[7].U_XORCY  (
    .CI(\U0/I_VIO/U_STATUS/U_STAT_CNT/CI [7]),
    .LI(\U0/I_VIO/U_STATUS/U_STAT_CNT/S [7]),
    .O(\U0/I_VIO/U_STATUS/U_STAT_CNT/D [7])
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \U0/I_VIO/U_STATUS/U_STAT_CNT/G[7].U_LUT  (
    .I0(\U0/I_VIO/U_STATUS/iSTAT_CNT [7]),
    .O(\U0/I_VIO/U_STATUS/U_STAT_CNT/S [7])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/U_STATUS/U_STAT_CNT/G[0].U_FDRE  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/U_STATUS/U_STAT_CNT/D [0]),
    .R(\U0/I_VIO/U_STATUS/CFG_CE_n ),
    .Q(\U0/I_VIO/U_STATUS/iSTAT_CNT [0])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/U_STATUS/U_STAT_CNT/G[1].U_FDRE  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/U_STATUS/U_STAT_CNT/D [1]),
    .R(\U0/I_VIO/U_STATUS/CFG_CE_n ),
    .Q(\U0/I_VIO/U_STATUS/iSTAT_CNT [1])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/U_STATUS/U_STAT_CNT/G[2].U_FDRE  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/U_STATUS/U_STAT_CNT/D [2]),
    .R(\U0/I_VIO/U_STATUS/CFG_CE_n ),
    .Q(\U0/I_VIO/U_STATUS/iSTAT_CNT [2])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/U_STATUS/U_STAT_CNT/G[3].U_FDRE  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/U_STATUS/U_STAT_CNT/D [3]),
    .R(\U0/I_VIO/U_STATUS/CFG_CE_n ),
    .Q(\U0/I_VIO/U_STATUS/iSTAT_CNT [3])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/U_STATUS/U_STAT_CNT/G[4].U_FDRE  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/U_STATUS/U_STAT_CNT/D [4]),
    .R(\U0/I_VIO/U_STATUS/CFG_CE_n ),
    .Q(\U0/I_VIO/U_STATUS/iSTAT_CNT [4])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/U_STATUS/U_STAT_CNT/G[5].U_FDRE  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/U_STATUS/U_STAT_CNT/D [5]),
    .R(\U0/I_VIO/U_STATUS/CFG_CE_n ),
    .Q(\U0/I_VIO/U_STATUS/iSTAT_CNT [5])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/U_STATUS/U_STAT_CNT/G[6].U_FDRE  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/U_STATUS/U_STAT_CNT/D [6]),
    .R(\U0/I_VIO/U_STATUS/CFG_CE_n ),
    .Q(\U0/I_VIO/U_STATUS/iSTAT_CNT [6])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/U_STATUS/U_STAT_CNT/G[7].U_FDRE  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/U_STATUS/U_STAT_CNT/D [7]),
    .R(\U0/I_VIO/U_STATUS/CFG_CE_n ),
    .Q(\U0/I_VIO/U_STATUS/iSTAT_CNT [7])
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/USER_CLK_REG  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[0]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/clocked )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/USER_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/mux1_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/fd1_out )
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/U_RISING  (
    .C(SYNC_IN[0]),
    .CE(N1),
    .CLR(\U0/I_VIO/RESET ),
    .D(N1),
    .Q(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/rising_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/S_ASYNC_R_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/async_mux_r_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/fd2_out )
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/U_FALLING  (
    .C(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/user_in_n ),
    .CE(N1),
    .CLR(\U0/I_VIO/RESET ),
    .D(N1),
    .Q(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/falling_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/S_ASYNC_F_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/async_mux_f_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/fd3_out )
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/U_SYNC_R  (
    .C(CLK),
    .CE(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/rising ),
    .D(N1),
    .R(\U0/I_VIO/RESET ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_r_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/S_SYNC_R_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_mux_r_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/fd4_out )
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/U_SYNC_F  (
    .C(CLK),
    .CE(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/falling ),
    .D(N1),
    .R(\U0/I_VIO/RESET ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_f_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/S_SYNC_F_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_mux_f_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/fd5_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/SHIFT_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/fd5_out ),
    .Q(\U0/I_VIO/INPUT_SHIFT [1])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_f_edge/I_H2L.U_DOUT  (
    .C(CLK),
    .D(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_f_edge/iDOUT<1> ),
    .R(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/falling )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_f_edge/U_DOUT1  (
    .C(CLK),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_f_edge/iDOUT<1> )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_f_edge/U_DOUT0  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[0]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_f_edge/iDOUT<0> )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_r_edge/I_L2H.U_DOUT  (
    .C(CLK),
    .D(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ),
    .R(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_r_edge/iDOUT<1> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/rising )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_r_edge/U_DOUT1  (
    .C(CLK),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_r_edge/iDOUT<1> )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_r_edge/U_DOUT0  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[0]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_r_edge/iDOUT<0> )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/USER_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/clocked ),
    .I1(N0),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/mux1_out )
  );
  INV   \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/U_STATCMD_n  (
    .I(SYNC_IN[0]),
    .O(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/user_in_n )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/ASYNC_R_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/rising_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/fd1_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/async_mux_r_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/ASYNC_F_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/falling_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/fd2_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/async_mux_f_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/SYNC_R_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_r_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/fd3_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_mux_r_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/SYNC_F_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_f_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/fd4_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[0].SYNC_IN_CELL/sync_mux_f_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/USER_CLK_REG  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[1]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/clocked )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/USER_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/mux1_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/fd1_out )
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/U_RISING  (
    .C(SYNC_IN[1]),
    .CE(N1),
    .CLR(\U0/I_VIO/RESET ),
    .D(N1),
    .Q(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/rising_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/S_ASYNC_R_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/async_mux_r_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/fd2_out )
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/U_FALLING  (
    .C(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/user_in_n ),
    .CE(N1),
    .CLR(\U0/I_VIO/RESET ),
    .D(N1),
    .Q(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/falling_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/S_ASYNC_F_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/async_mux_f_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/fd3_out )
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/U_SYNC_R  (
    .C(CLK),
    .CE(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/rising ),
    .D(N1),
    .R(\U0/I_VIO/RESET ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_r_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/S_SYNC_R_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_mux_r_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/fd4_out )
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/U_SYNC_F  (
    .C(CLK),
    .CE(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/falling ),
    .D(N1),
    .R(\U0/I_VIO/RESET ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_f_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/S_SYNC_F_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_mux_f_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/fd5_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/SHIFT_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/fd5_out ),
    .Q(\U0/I_VIO/INPUT_SHIFT [2])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_f_edge/I_H2L.U_DOUT  (
    .C(CLK),
    .D(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_f_edge/iDOUT<1> ),
    .R(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/falling )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_f_edge/U_DOUT1  (
    .C(CLK),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_f_edge/iDOUT<1> )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_f_edge/U_DOUT0  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[1]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_f_edge/iDOUT<0> )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_r_edge/I_L2H.U_DOUT  (
    .C(CLK),
    .D(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ),
    .R(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_r_edge/iDOUT<1> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/rising )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_r_edge/U_DOUT1  (
    .C(CLK),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_r_edge/iDOUT<1> )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_r_edge/U_DOUT0  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[1]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_r_edge/iDOUT<0> )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/USER_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/clocked ),
    .I1(\U0/I_VIO/INPUT_SHIFT [1]),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/mux1_out )
  );
  INV   \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/U_STATCMD_n  (
    .I(SYNC_IN[1]),
    .O(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/user_in_n )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/ASYNC_R_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/rising_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/fd1_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/async_mux_r_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/ASYNC_F_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/falling_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/fd2_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/async_mux_f_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/SYNC_R_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_r_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/fd3_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_mux_r_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/SYNC_F_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_f_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/fd4_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[1].SYNC_IN_CELL/sync_mux_f_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/USER_CLK_REG  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[2]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/clocked )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/USER_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/mux1_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/fd1_out )
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/U_RISING  (
    .C(SYNC_IN[2]),
    .CE(N1),
    .CLR(\U0/I_VIO/RESET ),
    .D(N1),
    .Q(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/rising_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/S_ASYNC_R_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/async_mux_r_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/fd2_out )
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/U_FALLING  (
    .C(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/user_in_n ),
    .CE(N1),
    .CLR(\U0/I_VIO/RESET ),
    .D(N1),
    .Q(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/falling_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/S_ASYNC_F_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/async_mux_f_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/fd3_out )
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/U_SYNC_R  (
    .C(CLK),
    .CE(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/rising ),
    .D(N1),
    .R(\U0/I_VIO/RESET ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_r_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/S_SYNC_R_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_mux_r_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/fd4_out )
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/U_SYNC_F  (
    .C(CLK),
    .CE(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/falling ),
    .D(N1),
    .R(\U0/I_VIO/RESET ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_f_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/S_SYNC_F_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_mux_f_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/fd5_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/SHIFT_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/fd5_out ),
    .Q(\U0/I_VIO/INPUT_SHIFT [3])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_f_edge/I_H2L.U_DOUT  (
    .C(CLK),
    .D(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_f_edge/iDOUT<1> ),
    .R(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/falling )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_f_edge/U_DOUT1  (
    .C(CLK),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_f_edge/iDOUT<1> )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_f_edge/U_DOUT0  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[2]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_f_edge/iDOUT<0> )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_r_edge/I_L2H.U_DOUT  (
    .C(CLK),
    .D(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ),
    .R(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_r_edge/iDOUT<1> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/rising )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_r_edge/U_DOUT1  (
    .C(CLK),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_r_edge/iDOUT<1> )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_r_edge/U_DOUT0  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[2]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_r_edge/iDOUT<0> )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/USER_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/clocked ),
    .I1(\U0/I_VIO/INPUT_SHIFT [2]),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/mux1_out )
  );
  INV   \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/U_STATCMD_n  (
    .I(SYNC_IN[2]),
    .O(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/user_in_n )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/ASYNC_R_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/rising_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/fd1_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/async_mux_r_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/ASYNC_F_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/falling_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/fd2_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/async_mux_f_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/SYNC_R_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_r_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/fd3_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_mux_r_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/SYNC_F_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_f_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/fd4_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[2].SYNC_IN_CELL/sync_mux_f_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/USER_CLK_REG  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[3]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/clocked )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/USER_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/mux1_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/fd1_out )
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/U_RISING  (
    .C(SYNC_IN[3]),
    .CE(N1),
    .CLR(\U0/I_VIO/RESET ),
    .D(N1),
    .Q(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/rising_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/S_ASYNC_R_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/async_mux_r_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/fd2_out )
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/U_FALLING  (
    .C(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/user_in_n ),
    .CE(N1),
    .CLR(\U0/I_VIO/RESET ),
    .D(N1),
    .Q(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/falling_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/S_ASYNC_F_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/async_mux_f_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/fd3_out )
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/U_SYNC_R  (
    .C(CLK),
    .CE(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/rising ),
    .D(N1),
    .R(\U0/I_VIO/RESET ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_r_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/S_SYNC_R_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_mux_r_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/fd4_out )
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/U_SYNC_F  (
    .C(CLK),
    .CE(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/falling ),
    .D(N1),
    .R(\U0/I_VIO/RESET ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_f_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/S_SYNC_F_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_mux_f_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/fd5_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/SHIFT_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/fd5_out ),
    .Q(\U0/I_VIO/INPUT_SHIFT [4])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_f_edge/I_H2L.U_DOUT  (
    .C(CLK),
    .D(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_f_edge/iDOUT<1> ),
    .R(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/falling )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_f_edge/U_DOUT1  (
    .C(CLK),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_f_edge/iDOUT<1> )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_f_edge/U_DOUT0  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[3]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_f_edge/iDOUT<0> )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_r_edge/I_L2H.U_DOUT  (
    .C(CLK),
    .D(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ),
    .R(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_r_edge/iDOUT<1> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/rising )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_r_edge/U_DOUT1  (
    .C(CLK),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_r_edge/iDOUT<1> )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_r_edge/U_DOUT0  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[3]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_r_edge/iDOUT<0> )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/USER_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/clocked ),
    .I1(\U0/I_VIO/INPUT_SHIFT [3]),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/mux1_out )
  );
  INV   \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/U_STATCMD_n  (
    .I(SYNC_IN[3]),
    .O(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/user_in_n )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/ASYNC_R_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/rising_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/fd1_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/async_mux_r_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/ASYNC_F_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/falling_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/fd2_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/async_mux_f_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/SYNC_R_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_r_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/fd3_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_mux_r_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/SYNC_F_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_f_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/fd4_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[3].SYNC_IN_CELL/sync_mux_f_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/USER_CLK_REG  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[4]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/clocked )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/USER_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/mux1_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/fd1_out )
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/U_RISING  (
    .C(SYNC_IN[4]),
    .CE(N1),
    .CLR(\U0/I_VIO/RESET ),
    .D(N1),
    .Q(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/rising_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/S_ASYNC_R_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/async_mux_r_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/fd2_out )
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/U_FALLING  (
    .C(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/user_in_n ),
    .CE(N1),
    .CLR(\U0/I_VIO/RESET ),
    .D(N1),
    .Q(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/falling_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/S_ASYNC_F_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/async_mux_f_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/fd3_out )
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/U_SYNC_R  (
    .C(CLK),
    .CE(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/rising ),
    .D(N1),
    .R(\U0/I_VIO/RESET ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_r_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/S_SYNC_R_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_mux_r_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/fd4_out )
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/U_SYNC_F  (
    .C(CLK),
    .CE(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/falling ),
    .D(N1),
    .R(\U0/I_VIO/RESET ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_f_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/S_SYNC_F_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_mux_f_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/fd5_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/SHIFT_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/fd5_out ),
    .Q(\U0/I_VIO/INPUT_SHIFT [5])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_f_edge/I_H2L.U_DOUT  (
    .C(CLK),
    .D(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_f_edge/iDOUT<1> ),
    .R(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/falling )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_f_edge/U_DOUT1  (
    .C(CLK),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_f_edge/iDOUT<1> )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_f_edge/U_DOUT0  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[4]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_f_edge/iDOUT<0> )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_r_edge/I_L2H.U_DOUT  (
    .C(CLK),
    .D(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ),
    .R(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_r_edge/iDOUT<1> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/rising )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_r_edge/U_DOUT1  (
    .C(CLK),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_r_edge/iDOUT<1> )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_r_edge/U_DOUT0  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[4]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_r_edge/iDOUT<0> )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/USER_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/clocked ),
    .I1(\U0/I_VIO/INPUT_SHIFT [4]),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/mux1_out )
  );
  INV   \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/U_STATCMD_n  (
    .I(SYNC_IN[4]),
    .O(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/user_in_n )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/ASYNC_R_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/rising_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/fd1_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/async_mux_r_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/ASYNC_F_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/falling_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/fd2_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/async_mux_f_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/SYNC_R_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_r_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/fd3_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_mux_r_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/SYNC_F_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_f_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/fd4_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[4].SYNC_IN_CELL/sync_mux_f_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/USER_CLK_REG  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[5]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/clocked )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/USER_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/mux1_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/fd1_out )
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/U_RISING  (
    .C(SYNC_IN[5]),
    .CE(N1),
    .CLR(\U0/I_VIO/RESET ),
    .D(N1),
    .Q(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/rising_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/S_ASYNC_R_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/async_mux_r_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/fd2_out )
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/U_FALLING  (
    .C(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/user_in_n ),
    .CE(N1),
    .CLR(\U0/I_VIO/RESET ),
    .D(N1),
    .Q(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/falling_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/S_ASYNC_F_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/async_mux_f_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/fd3_out )
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/U_SYNC_R  (
    .C(CLK),
    .CE(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/rising ),
    .D(N1),
    .R(\U0/I_VIO/RESET ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_r_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/S_SYNC_R_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_mux_r_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/fd4_out )
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/U_SYNC_F  (
    .C(CLK),
    .CE(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/falling ),
    .D(N1),
    .R(\U0/I_VIO/RESET ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_f_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/S_SYNC_F_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_mux_f_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/fd5_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/SHIFT_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/fd5_out ),
    .Q(\U0/I_VIO/INPUT_SHIFT [6])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_f_edge/I_H2L.U_DOUT  (
    .C(CLK),
    .D(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_f_edge/iDOUT<1> ),
    .R(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/falling )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_f_edge/U_DOUT1  (
    .C(CLK),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_f_edge/iDOUT<1> )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_f_edge/U_DOUT0  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[5]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_f_edge/iDOUT<0> )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_r_edge/I_L2H.U_DOUT  (
    .C(CLK),
    .D(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ),
    .R(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_r_edge/iDOUT<1> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/rising )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_r_edge/U_DOUT1  (
    .C(CLK),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_r_edge/iDOUT<1> )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_r_edge/U_DOUT0  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[5]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_r_edge/iDOUT<0> )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/USER_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/clocked ),
    .I1(\U0/I_VIO/INPUT_SHIFT [5]),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/mux1_out )
  );
  INV   \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/U_STATCMD_n  (
    .I(SYNC_IN[5]),
    .O(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/user_in_n )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/ASYNC_R_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/rising_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/fd1_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/async_mux_r_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/ASYNC_F_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/falling_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/fd2_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/async_mux_f_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/SYNC_R_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_r_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/fd3_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_mux_r_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/SYNC_F_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_f_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/fd4_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[5].SYNC_IN_CELL/sync_mux_f_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/USER_CLK_REG  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[6]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/clocked )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/USER_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/mux1_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/fd1_out )
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/U_RISING  (
    .C(SYNC_IN[6]),
    .CE(N1),
    .CLR(\U0/I_VIO/RESET ),
    .D(N1),
    .Q(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/rising_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/S_ASYNC_R_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/async_mux_r_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/fd2_out )
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/U_FALLING  (
    .C(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/user_in_n ),
    .CE(N1),
    .CLR(\U0/I_VIO/RESET ),
    .D(N1),
    .Q(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/falling_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/S_ASYNC_F_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/async_mux_f_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/fd3_out )
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/U_SYNC_R  (
    .C(CLK),
    .CE(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/rising ),
    .D(N1),
    .R(\U0/I_VIO/RESET ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_r_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/S_SYNC_R_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_mux_r_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/fd4_out )
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/U_SYNC_F  (
    .C(CLK),
    .CE(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/falling ),
    .D(N1),
    .R(\U0/I_VIO/RESET ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_f_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/S_SYNC_F_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_mux_f_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/fd5_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/SHIFT_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/fd5_out ),
    .Q(\U0/I_VIO/INPUT_SHIFT [7])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_f_edge/I_H2L.U_DOUT  (
    .C(CLK),
    .D(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_f_edge/iDOUT<1> ),
    .R(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/falling )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_f_edge/U_DOUT1  (
    .C(CLK),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_f_edge/iDOUT<1> )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_f_edge/U_DOUT0  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[6]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_f_edge/iDOUT<0> )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_r_edge/I_L2H.U_DOUT  (
    .C(CLK),
    .D(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ),
    .R(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_r_edge/iDOUT<1> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/rising )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_r_edge/U_DOUT1  (
    .C(CLK),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_r_edge/iDOUT<1> )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_r_edge/U_DOUT0  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[6]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_r_edge/iDOUT<0> )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/USER_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/clocked ),
    .I1(\U0/I_VIO/INPUT_SHIFT [6]),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/mux1_out )
  );
  INV   \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/U_STATCMD_n  (
    .I(SYNC_IN[6]),
    .O(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/user_in_n )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/ASYNC_R_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/rising_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/fd1_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/async_mux_r_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/ASYNC_F_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/falling_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/fd2_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/async_mux_f_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/SYNC_R_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_r_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/fd3_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_mux_r_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/SYNC_F_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_f_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/fd4_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[6].SYNC_IN_CELL/sync_mux_f_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/USER_CLK_REG  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[7]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/clocked )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/USER_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/mux1_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/fd1_out )
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/U_RISING  (
    .C(SYNC_IN[7]),
    .CE(N1),
    .CLR(\U0/I_VIO/RESET ),
    .D(N1),
    .Q(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/rising_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/S_ASYNC_R_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/async_mux_r_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/fd2_out )
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/U_FALLING  (
    .C(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/user_in_n ),
    .CE(N1),
    .CLR(\U0/I_VIO/RESET ),
    .D(N1),
    .Q(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/falling_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/S_ASYNC_F_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/async_mux_f_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/fd3_out )
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/U_SYNC_R  (
    .C(CLK),
    .CE(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/rising ),
    .D(N1),
    .R(\U0/I_VIO/RESET ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_r_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/S_SYNC_R_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_mux_r_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/fd4_out )
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/U_SYNC_F  (
    .C(CLK),
    .CE(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/falling ),
    .D(N1),
    .R(\U0/I_VIO/RESET ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_f_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/S_SYNC_F_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_mux_f_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/fd5_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/SHIFT_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/fd5_out ),
    .Q(\U0/I_VIO/INPUT_SHIFT [8])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_f_edge/I_H2L.U_DOUT  (
    .C(CLK),
    .D(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_f_edge/iDOUT<1> ),
    .R(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/falling )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_f_edge/U_DOUT1  (
    .C(CLK),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_f_edge/iDOUT<1> )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_f_edge/U_DOUT0  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[7]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_f_edge/iDOUT<0> )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_r_edge/I_L2H.U_DOUT  (
    .C(CLK),
    .D(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ),
    .R(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_r_edge/iDOUT<1> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/rising )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_r_edge/U_DOUT1  (
    .C(CLK),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_r_edge/iDOUT<1> )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_r_edge/U_DOUT0  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[7]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_r_edge/iDOUT<0> )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/USER_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/clocked ),
    .I1(\U0/I_VIO/INPUT_SHIFT [7]),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/mux1_out )
  );
  INV   \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/U_STATCMD_n  (
    .I(SYNC_IN[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/user_in_n )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/ASYNC_R_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/rising_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/fd1_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/async_mux_r_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/ASYNC_F_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/falling_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/fd2_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/async_mux_f_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/SYNC_R_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_r_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/fd3_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_mux_r_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/SYNC_F_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_f_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/fd4_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[7].SYNC_IN_CELL/sync_mux_f_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/USER_CLK_REG  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[8]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/clocked )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/USER_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/mux1_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/fd1_out )
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/U_RISING  (
    .C(SYNC_IN[8]),
    .CE(N1),
    .CLR(\U0/I_VIO/RESET ),
    .D(N1),
    .Q(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/rising_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/S_ASYNC_R_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/async_mux_r_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/fd2_out )
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/U_FALLING  (
    .C(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/user_in_n ),
    .CE(N1),
    .CLR(\U0/I_VIO/RESET ),
    .D(N1),
    .Q(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/falling_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/S_ASYNC_F_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/async_mux_f_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/fd3_out )
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/U_SYNC_R  (
    .C(CLK),
    .CE(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/rising ),
    .D(N1),
    .R(\U0/I_VIO/RESET ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_r_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/S_SYNC_R_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_mux_r_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/fd4_out )
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/U_SYNC_F  (
    .C(CLK),
    .CE(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/falling ),
    .D(N1),
    .R(\U0/I_VIO/RESET ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_f_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/S_SYNC_F_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_mux_f_out ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/fd5_out )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/SHIFT_REG  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/fd5_out ),
    .Q(\U0/I_VIO/INPUT_SHIFT [9])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_f_edge/I_H2L.U_DOUT  (
    .C(CLK),
    .D(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_f_edge/iDOUT<1> ),
    .R(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/falling )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_f_edge/U_DOUT1  (
    .C(CLK),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_f_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_f_edge/iDOUT<1> )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_f_edge/U_DOUT0  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[8]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_f_edge/iDOUT<0> )
  );
  FDR #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_r_edge/I_L2H.U_DOUT  (
    .C(CLK),
    .D(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ),
    .R(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_r_edge/iDOUT<1> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/rising )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_r_edge/U_DOUT1  (
    .C(CLK),
    .CE(N1),
    .D(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_r_edge/iDOUT<0> ),
    .Q(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_r_edge/iDOUT<1> )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_r_edge/U_DOUT0  (
    .C(CLK),
    .CE(N1),
    .D(SYNC_IN[8]),
    .Q(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_r_edge/iDOUT<0> )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/USER_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/clocked ),
    .I1(\U0/I_VIO/INPUT_SHIFT [8]),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/mux1_out )
  );
  INV   \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/U_STATCMD_n  (
    .I(SYNC_IN[8]),
    .O(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/user_in_n )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/ASYNC_R_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/rising_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/fd1_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/async_mux_r_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/ASYNC_F_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/falling_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/fd2_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/async_mux_f_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/SYNC_R_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_r_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/fd3_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_mux_r_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/SYNC_F_MUX  (
    .I0(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_f_out ),
    .I1(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/fd4_out ),
    .I2(CONTROL[7]),
    .O(\U0/I_VIO/GEN_SYNC_IN[8].SYNC_IN_CELL/sync_mux_f_out )
  );
  LUT3 #(
    .INIT ( 8'hCA ))
  \U0/I_VIO/U_DOUT  (
    .I0(\U0/I_VIO/STAT_DOUT ),
    .I1(\U0/I_VIO/DATA_DOUT ),
    .I2(CONTROL[7]),
    .O(CONTROL[3])
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/reset_f_edge/U_DOUT0  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(CONTROL[7]),
    .Q(\U0/I_VIO/reset_f_edge/iDOUT [0])
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/reset_f_edge/U_DOUT1  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/reset_f_edge/iDOUT [0]),
    .Q(\U0/I_VIO/reset_f_edge/iDOUT [1])
  );
  FDR #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/reset_f_edge/I_H2L.U_DOUT  (
    .C(CONTROL[0]),
    .D(\U0/I_VIO/reset_f_edge/iDOUT [1]),
    .R(\U0/I_VIO/reset_f_edge/iDOUT [0]),
    .Q(\U0/I_VIO/RESET )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \U0/I_VIO/U_DATA_OUT  (
    .C(CONTROL[0]),
    .CE(N1),
    .D(\U0/I_VIO/INPUT_SHIFT [9]),
    .Q(\U0/I_VIO/DATA_DOUT )
  );
  LUT6 #(
    .INIT ( 64'h7FFFFFFFFFFFFFFF ))
  \U0/I_VIO/U_STATUS/iSTAT_CNT<7>35  (
    .I0(CONTROL[22]),
    .I1(CONTROL[23]),
    .I2(CONTROL[21]),
    .I3(CONTROL[20]),
    .I4(CONTROL[19]),
    .I5(CONTROL[18]),
    .O(\U0/I_VIO/U_STATUS/iSTAT_CNT<7>35_306 )
  );
  LUT6 #(
    .INIT ( 64'h7FFFFFFFFFFFFFFF ))
  \U0/I_VIO/U_STATUS/iSTAT_CNT<7>71  (
    .I0(CONTROL[16]),
    .I1(CONTROL[17]),
    .I2(CONTROL[15]),
    .I3(CONTROL[14]),
    .I4(CONTROL[13]),
    .I5(CONTROL[12]),
    .O(\U0/I_VIO/U_STATUS/iSTAT_CNT<7>71_307 )
  );
  LUT6 #(
    .INIT ( 64'h7FFFFFFFFFFFFFFF ))
  \U0/I_VIO/U_STATUS/iSTAT_CNT<7>128  (
    .I0(CONTROL[34]),
    .I1(CONTROL[35]),
    .I2(CONTROL[33]),
    .I3(CONTROL[32]),
    .I4(CONTROL[31]),
    .I5(CONTROL[30]),
    .O(\U0/I_VIO/U_STATUS/iSTAT_CNT<7>128_303 )
  );
  LUT6 #(
    .INIT ( 64'h7FFFFFFFFFFFFFFF ))
  \U0/I_VIO/U_STATUS/iSTAT_CNT<7>164  (
    .I0(CONTROL[28]),
    .I1(CONTROL[29]),
    .I2(CONTROL[27]),
    .I3(CONTROL[26]),
    .I4(CONTROL[25]),
    .I5(CONTROL[24]),
    .O(\U0/I_VIO/U_STATUS/iSTAT_CNT<7>164_304 )
  );
  LUT6 #(
    .INIT ( 64'hEEFFEE0FEEF0EE00 ))
  \U0/I_VIO/U_STATUS/iSTAT_CNT<7>316  (
    .I0(N36),
    .I1(\U0/I_VIO/U_STATUS/iSTAT_CNT<7>71_307 ),
    .I2(\U0/I_VIO/U_STATUS/iSTAT_CNT [6]),
    .I3(\U0/I_VIO/U_STATUS/iSTAT_CNT [7]),
    .I4(\U0/I_VIO/U_STATUS/U_SMUX/U_CS_MUX/I4.U_MUX16/Mmux_O_6_262 ),
    .I5(\U0/I_VIO/U_STATUS/U_SMUX/U_CS_MUX/I4.U_MUX16/Mmux_O_7_263 ),
    .O(\U0/I_VIO/U_STATUS/TDO_next )
  );
  LUT5 #(
    .INIT ( 32'h80000000 ))
  \U0/I_VIO/U_STATUS/iSTAT_CNT<7>260_SW0  (
    .I0(CONTROL[5]),
    .I1(CONTROL[6]),
    .I2(CONTROL[7]),
    .I3(CONTROL[8]),
    .I4(CONTROL[9]),
    .O(N38)
  );
  LUT6 #(
    .INIT ( 64'h7FFFFFFFFFFFFFFF ))
  \U0/I_VIO/U_STATUS/iSTAT_CNT<7>260  (
    .I0(CONTROL[10]),
    .I1(CONTROL[11]),
    .I2(CONTROL[1]),
    .I3(CONTROL[2]),
    .I4(CONTROL[4]),
    .I5(N38),
    .O(\U0/I_VIO/U_STATUS/iSTAT_CNT<7>260_305 )
  );
  LUT4 #(
    .INIT ( 16'hFFFE ))
  \U0/I_VIO/U_STATUS/U_SMUX/U_CS_MUX/I4.U_MUX16/Mmux_O_5_f7_SW0  (
    .I0(\U0/I_VIO/U_STATUS/iSTAT_CNT<7>35_306 ),
    .I1(\U0/I_VIO/U_STATUS/iSTAT_CNT<7>260_305 ),
    .I2(\U0/I_VIO/U_STATUS/iSTAT_CNT<7>128_303 ),
    .I3(\U0/I_VIO/U_STATUS/iSTAT_CNT<7>164_304 ),
    .O(N36)
  );

// synthesis translate_on

endmodule

// synthesis translate_off

`ifndef GLBL
`define GLBL

`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (weak1, weak0) GSR = GSR_int;
    assign (weak1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule

`endif

// synthesis translate_on
