

module FSABArbiter(
	input clk,
	input Nrst,
	input [FSAB_DEVICES_MAX-1:0] fsabo_valids,
	input [FSAB_DEVICES_MAX*(FSAB_REQ_HI+1)-1:0] fsabo_modes,
	input [FSAB_DEVICES_MAX*(FSAB_DID_HI+1)-1:0] fsabo_dids,
	input [FSAB_DEVICES_MAX*(FSAB_DID_HI+1)-1:0] fsabo_subdids,
	input [FSAB_DEVICES_MAX*(FSAB_ADDR_HI+1)-1:0] fsabo_addrs,
	input [FSAB_DEVICES_MAX*(FSAB_LEN_HI+1)-1:0] fsabo_lens,
	input [FSAB_DEVICES_MAX*(FSAB_DATA_HI+1)-1:0] fsabo_datas,
	input [FSAB_DEVICES_MAX*(FSAB_MASK_HI+1)-1:0] fsabo_masks,
	
	output wire                  fsabo_valid,
	output wire [FSAB_REQ_HI:0]  fsabo_mode,
	output wire [FSAB_DID_HI:0]  fsabo_did,
	output wire [FSAB_DID_HI:0]  fsabo_subdid,
	output wire [FSAB_ADDR_HI:0] fsabo_addr,
	output wire [FSAB_LEN_HI:0]  fsabo_len,
	output wire [FSAB_DATA_HI:0] fsabo_data,
	output wire [FSAB_MASK_HI:0] fsabo_mask,
	input                       fsabo_credit);
`include "fsab_defines.vh"
	
	FSABFifo fifo (.clk(clk),
			.Nrst(Nrst),
			.fifo_read(fsabo_credit),
			.fsabo_valid(fsabo_valids[0]),
			.fsabo_mode (fsabo_modes[FSAB_REQ_HI:0]),
			.fsabo_did (fsabo_dids[FSAB_DID_HI:0]),
			.fsabo_subdid (fsabo_subdids[FSAB_DID_HI:0]),
			.fsabo_addr (fsabo_addrs[FSAB_ADDR_HI:0]),
			.fsabo_len (fsabo_lens[FSAB_LEN_HI:0]),
			.fsabo_data (fsabo_datas[FSAB_DATA_HI:0]),
			.fsabo_mask (fsabo_masks[FSAB_MASK_HI:0]),
			.fsab_req_out({fsabo_valid, fsabo_mode, fsabo_did, fsabo_subdid,fsabo_addr, fsabo_len}),
			.fsabi_data(fsabo_data),
			.fsabi_mask(fsabo_mask));
	
endmodule
