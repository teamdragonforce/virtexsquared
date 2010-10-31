parameter MIG_CMD_WIDTH           = 3;
parameter MIG_READ                = 3'b001;
parameter MIG_WRITE               = 3'b000;

parameter BANK_WIDTH              = 2;       
// # of memory bank addr bits.
parameter CKE_WIDTH               = 1;       
// # of memory clock enable outputs.
parameter CLK_WIDTH               = 2;       
// # of clock outputs.
parameter COL_WIDTH               = 10;       
// # of memory column bits.
parameter CS_NUM                  = 1;       
// # of separate memory chip selects.
parameter CS_WIDTH                = 1;       
// # of total memory chip selects.
parameter CS_BITS                 = 0;       
// set to log2(CS_NUM) (rounded up).
parameter DM_WIDTH                = 8;       
// # of data mask bits.
parameter DQ_WIDTH                = 64;       
// # of data width.
parameter DQ_PER_DQS              = 8;       
// # of DQ data bits per strobe.
parameter DQS_WIDTH               = 8;       
// # of DQS strobes.
parameter DQ_BITS                 = 6;       
// set to log2(DQS_WIDTH*DQ_PER_DQS).
parameter DQS_BITS                = 3;       
// set to log2(DQS_WIDTH).
parameter ODT_WIDTH               = 1;       
// # of memory on-die term enables.
parameter ROW_WIDTH               = 13;       
// # of memory row and # of addr bits.
parameter ADDITIVE_LAT            = 0;       
// additive write latency.
parameter BURST_LEN               = 8;       
// burst length (in double words).
parameter BURST_TYPE              = 0;       
// burst type (=0 seq; =1 interleaved).
parameter CAS_LAT                 = 3;       
// CAS latency.
parameter ECC_ENABLE              = 0;       
// enable ECC (=1 enable).
parameter APPDATA_WIDTH           = 128;       
// # of usr read/write data bus bits.
parameter MULTI_BANK_EN           = 1;       
// Keeps multiple banks open. (= 1 enable).
parameter TWO_T_TIME_EN           = 1;       
// 2t timing for unbuffered dimms.
parameter ODT_TYPE                = 1;       
// ODT (=0(none);=1(75),=2(150),=3(50)).
parameter REDUCE_DRV              = 0;       
// reduced strength mem I/O (=1 yes).
parameter REG_ENABLE              = 0;       
// registered addr/ctrl (=1 yes).
parameter TREFI_NS                = 7800;       
// auto refresh interval (ns).
parameter TRAS                    = 40000;       
// active->precharge delay.
parameter TRCD                    = 15000;       
// active->read/write delay.
parameter TRFC                    = 75000;       
// refresh->refresh; refresh->active delay.
parameter TRP                     = 15000;       
// precharge->command delay.
parameter TRTP                    = 7500;       
// read->precharge delay.
parameter TWR                     = 15000;       
// used to determine write->precharge.
parameter TWTR                    = 7500;       
// write->read delay.
parameter HIGH_PERFORMANCE_MODE   = "TRUE";       
// # = TRUE; the IODELAY performance mode is set
// to high.
// # = FALSE; the IODELAY performance mode is set
// to low.
parameter SIM_ONLY                = 0;       
// = 1 to skip SDRAM power up delay.
parameter DEBUG_EN                = 0;       
// Enable debug signals/controls.
// When this parameter is changed from 0 to 1;
// make sure to uncomment the coregen commands
// in ise_flow.bat or create_ise.bat files in
// par folder.
parameter CLK_PERIOD              = 8000;       
// Core/Memory clock period (in ps).
parameter DLL_FREQ_MODE           = "HIGH";       
// DCM Frequency range.
parameter CLK_TYPE                = "DIFFERENTIAL";       
// # = "DIFFERENTIAL " ->; Differential input clocks ;
// # = "SINGLE_ENDED" -> Single ended input clocks.
parameter NOCLK200                = 0;       
// clk200 enable and disable.
parameter RST_ACT_LOW             = 1;       
// =1 for active low reset; =0 for active high.
