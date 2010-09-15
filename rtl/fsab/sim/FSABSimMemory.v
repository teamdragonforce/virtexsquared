module FSABSimMemory(
	input clk,
	input Nrst,
	
	input                        fsabo_valid,
	input       [FSAB_REQ_HI:0]  fsabo_mode,
	input       [FSAB_DID_HI:0]  fsabo_did,
	input       [FSAB_DID_HI:0]  fsabo_subdid,
	input       [FSAB_ADDR_HI:0] fsabo_addr,
	input       [FSAB_LEN_HI:0]  fsabo_len,
	input       [FSAB_DATA_HI:0] fsabo_data,
	input       [FSAB_MASK_HI:0] fsabo_mask,

	output wire                  fsabi_credit,
	output wire                  fsabi_valid,
	output wire [FSAB_DID_HI:0]  fsabi_did,
	output wire [FSAB_DID_HI:0]  fsabi_subdid,
	output wire [FSAB_DATA_HI:0] fsabi_data
	);

`include "fsab_defines.vh"

endmodule
