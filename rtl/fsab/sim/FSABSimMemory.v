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

`define SIMMEM_RFIF_WIDTH (FSAB_REQ_HI+1 + FSAB_DID_HI+1 + FSAB_DID_HI+1 + FSAB_ADDR_HI+1 + FSAB_LEN_HI+1 + FSAB_DATA_HI+1 + FSAB_MASK_HI)
	/* Inbound request FIFO */
	reg [FSAB_CREDITS_HI:0] rfif_wpos_0a = 'h0;
	reg [FSAB_CREDITS_HI:0] rfif_rpos_0a = 'h0;
	reg [`SIMMEM_RFIF_WIDTH:0] rfif_fifo [(FSAB_INITIAL_CREDITS-1):0];
	
	/* Inbound data FIFO */
`define SIMMEM_DFIF_MAX (((FSAB_CREDITS_HI+1) * FSAB_LEN_MAX) - 1)
`define SIMMEM_DFIF_HI (FSAB_CREDITS_HI+1+FSAB_LEN_MAX)
	reg [`SIMMEM_DFIF_HI:0] dfif_wpos_0a = 'h0;
	reg [`SIMMEM_DFIF_HI:0] dfif_rpos_0a = 'h0;
	reg [FSAB_DATA_HI+1 + FSAB_MASK_HI:0] dfif_fifo [`SIMMEM_DFIF_MAX:0];
	

endmodule
