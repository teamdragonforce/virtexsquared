`include "ARM_Constants.v"

`define SWP_READING	2'b01
`define SWP_WRITING	2'b10

`define LSRH_MEMIO	3'b001
`define LSRH_BASEWB	3'b010
`define LSRH_WBFLUSH	3'b100

`define LSR_MEMIO	4'b0001
`define LSR_STRB_WR	4'b0010
`define LSR_BASEWB	4'b0100
`define LSR_WBFLUSH	4'b1000

`define LSM_SETUP	4'b0001
`define LSM_MEMIO	4'b0010
`define LSM_BASEWB	4'b0100
`define LSM_WBFLUSH	4'b1000

`define WRD_ACTUAL            3'b000
`define WRD_OLD_READ          3'b010
`define WRD_OLD_READ_BYTE     3'b011
`define WRD_ALIGN_RDDATA_BYTE 3'b100
`define WRD_ALIGN_RDDATA      3'b101
`define WRD_LSRH_RDDATA       3'b110


module Memory(
	input clk,
	input rst_b,

	input flush,

	/* bus interface */
	output reg [31:0] dc__addr_3a,
	output reg dc__rd_req_3a,
	output reg dc__wr_req_3a,
	input dc__rw_wait_3a,
	output reg [31:0] dc__wr_data_3a,
	input [31:0] dc__rd_data_4a,
	output reg [2:0] dc__data_size_3a,

	/* regfile interface */
	output reg [3:0] rf__read_3_3a,
	input [31:0] rf__rdata_3_3a,
	
	/* Coprocessor interface */
	output reg cp_req,
	input cp_ack,
	input cp_busy,
	output reg cp_rnw,	/* 1 = read from CP, 0 = write to CP */
	input [31:0] cp_read,
	output reg [31:0] cp_write,
	
	/* stage inputs */
	input bubble_3a,
	input [31:0] pc_3a,
	input [31:0] insn_3a,
	input [31:0] op0_3a,
	input [31:0] op1_3a,
	input [31:0] op2_3a,
	input [31:0] spsr_3a,
	input [31:0] cpsr_3a,
	input cpsrup_3a,
	input write_reg_3a,
	input [3:0] write_num_3a,
	input [31:0] write_data_3a,

	/* outputs */
	output reg stall_3a,
	output reg bubble_4a,
	output reg [31:0] pc_4a,
	output reg [31:0] insn_4a,
	output reg write_reg_4a = 1'b0,
	output reg [3:0] write_num_4a = 4'bxxxx,
	output reg [31:0] write_data_4a = 32'hxxxxxxxx,
	output reg [31:0] spsr_4a = 32'hxxxxxxxx,
	output reg [31:0] cpsr_4a = 32'hxxxxxxxx,
	output reg cpsrup_4a = 1'hx
	);

	reg [31:0] addr, raddr, prev_raddr, next_regdata, next_cpsr_3a;
	reg next_cpsrup_3a;
	reg [31:0] prevaddr;
	reg [3:0] next_regsel, cur_reg, prev_reg;
	reg next_writeback;

	reg bubble_4a_next;	
	reg next_write_reg_3a;
	reg [3:0] next_write_num_3a;
	reg [31:0] next_write_data_3a, next_write_data_4a;
	reg [2:0] next_write_data_mode_3a, next_write_data_mode_4a;

	reg [3:0] lsr_state = 4'b0001, next_lsr_state;
	reg [31:0] align_s1, align_s2, align_rddata;

	reg [2:0] lsrh_state = 3'b001, next_lsrh_state;
	reg [31:0] lsrh_rddata;
	reg [15:0] lsrh_rddata_s1;
	reg [7:0] lsrh_rddata_s2;

	reg [15:0] regs, next_regs;
	reg [3:0] lsm_state = 4'b0001, next_lsm_state;
	reg [5:0] offset, prev_offset, offset_sel;

	reg [1:0] swp_state = 2'b01, next_swp_state;
	
	always @(posedge clk or negedge rst_b)
	begin
		if (!rst_b) begin
			pc_4a <= 0;
			insn_4a <= 0;
			bubble_4a <= 0;
			write_reg_4a <= 0;
			write_num_4a <= 0;
			next_write_data_4a <= 0;
			next_write_data_mode_4a <= next_write_data_mode_3a;
			prev_offset <= 0;
			prev_raddr <= 0;
			cpsr_4a <= 0;
			spsr_4a <= 0;
			cpsrup_4a <= 0;
			swp_state <= 2'b01;
			lsm_state <= 4'b0001;
			lsr_state <= 4'b0001;
			lsrh_state <= 3'b001;
			prevaddr <= 0;
		end else begin
			pc_4a <= pc_3a;
			insn_4a <= insn_3a;
			bubble_4a <= bubble_4a_next;
			write_reg_4a <= next_write_reg_3a;
			write_num_4a <= next_write_num_3a;
			next_write_data_4a <= next_write_data_3a;
			next_write_data_mode_4a <= next_write_data_mode_3a;
			if (!dc__rw_wait_3a)
				prev_offset <= offset;
			prev_raddr <= raddr;
			cpsr_4a <= next_cpsr_3a;
			spsr_4a <= spsr_3a;
			cpsrup_4a <= next_cpsrup_3a;
			swp_state <= next_swp_state;
			lsm_state <= next_lsm_state;
			lsr_state <= next_lsr_state;
			lsrh_state <= next_lsrh_state;
			prevaddr <= addr;
		end
	end
	
	/*** Clean up from left over write data messes, since this pipeline is asstarded ***/ 
	reg [1:0] raddr_4a;
	always @(posedge clk or negedge rst_b)
		if (!rst_b)
			raddr_4a <= 2'b00;
		else
			raddr_4a <= raddr[1:0];
	
	wire [31:0] align_s1_4a = raddr_4a[1] ? {last_rd_data_4a[15:0], last_rd_data_4a[31:16]} : last_rd_data_4a;
	wire [31:0] align_s2_4a = raddr_4a[0] ? {align_s1_4a[7:0], align_s1_4a[31:8]} : align_s1_4a;
	
	reg [31:0] lsrh_rddata_4a;
	
	always @(*)
		case (insn_4a[6:5]) /* Decode is for wimps. */
		2'b01: /* unsigned half */
			lsrh_rddata_4a = {16'b0, align_s1_4a[15:0]};
		2'b10: /* signed byte */
			lsrh_rddata_4a = {{24{align_s2_4a[7]}}, align_s2_4a[7:0]};
		2'b11: /* signed half */
			lsrh_rddata_4a = {{16{align_s1_4a[15]}}, align_s1_4a[15:0]};
		default:
			lsrh_rddata_4a = 32'hxxxxxxxx;
		endcase
	
	always @(*) begin
		write_data_4a = 32'hxxxxxxxx;
		case (next_write_data_mode_4a)
		`WRD_ACTUAL: write_data_4a = next_write_data_4a;
		`WRD_OLD_READ: write_data_4a = last_rd_data_4a;
		`WRD_OLD_READ_BYTE: write_data_4a = {24'h0, last_rd_data_4a[7:0]};
		`WRD_ALIGN_RDDATA: write_data_4a = align_s2_4a;
		`WRD_ALIGN_RDDATA_BYTE: write_data_4a = {24'h0, align_s2_4a[7:0]};
		`WRD_LSRH_RDDATA: write_data_4a = lsrh_rddata_4a;
		default: write_data_4a = 32'hxxxxxxxx;
		endcase
	end
	
	/*** Make sure to flush at some point, even if we were wedged ***/
	reg delayedflush = 0;
	always @(posedge clk or negedge rst_b)
		if (!rst_b)
			delayedflush <= 0;
		else if (flush && stall_3a /* halp! I can't do it now, maybe later? */)
			delayedflush <= 1;
		else if (!stall_3a /* anything has been handled this time around */)
			delayedflush <= 0;
	
	/*** Latch previously read data for R-M-W instructions ***/
	reg dc__rd_req_4a = 0;
	reg dc__rw_wait_4a = 0;
	
	reg [31:0] last_dc__rd_data_4a = 0;
	always @(posedge clk or negedge rst_b)
		if (!rst_b) begin
			dc__rd_req_4a <= 0;
			dc__rw_wait_4a <= 0;
			last_dc__rd_data_4a <= 0;
		end else begin
			dc__rd_req_4a <= dc__rd_req_3a;
			dc__rw_wait_4a <= dc__rw_wait_3a;
			
			if (dc__rd_req_4a && !dc__rw_wait_4a)
				last_dc__rd_data_4a <= dc__rd_data_4a;
		end
	
	wire [31:0] last_rd_data_4a = (dc__rd_req_4a && !dc__rw_wait_4a) ? dc__rd_data_4a : last_dc__rd_data_4a;
	
	/* Drive the state machines and stall. */
	always @(*)
	begin
		stall_3a = 1'b0;
		next_lsm_state = lsm_state;
		next_lsr_state = lsr_state;
		next_lsrh_state = lsrh_state;
		next_swp_state = swp_state;
		casez(insn_3a)
		`DECODE_ALU_SWP: if(!bubble_3a) begin
			case(swp_state)
			`SWP_READING: begin
				stall_3a = 1'b1;
				if (!dc__rw_wait_3a)
					next_swp_state = `SWP_WRITING;
				$display("SWP: read stage");
			end
			`SWP_WRITING: begin
				stall_3a = dc__rw_wait_3a;
				if(!dc__rw_wait_3a)
					next_swp_state = `SWP_READING;
				$display("SWP: write stage");
			end
			default: begin
				stall_3a = 1'bx;
				next_swp_state = 2'bxx;
			end
			endcase
		end
		`DECODE_ALU_MULT: begin
			stall_3a = 1'b0;	/* XXX work around for Xilinx bug */
			next_lsrh_state = lsrh_state;
		end
		`DECODE_ALU_HDATA_REG,
		`DECODE_ALU_HDATA_IMM: if(!bubble_3a) begin
			case(lsrh_state)
			`LSRH_MEMIO: begin
				stall_3a = dc__rw_wait_3a;
				if(insn_3a[21] | !insn_3a[24]) begin
					stall_3a = 1'b1;
					if(!dc__rw_wait_3a)
						next_lsrh_state = `LSRH_BASEWB;
				end
				
				if (flush) /* special case! */ begin
					stall_3a = 1'b0;
					next_lsrh_state = `LSRH_MEMIO;
				end
				
				$display("ALU_LDRSTRH: rd_req %d, wr_req %d", dc__rd_req_3a, dc__wr_req_3a);
			end
			`LSRH_BASEWB: begin
				stall_3a = 1'b1;
				next_lsrh_state = `LSRH_WBFLUSH;
			end
			`LSRH_WBFLUSH: begin
				stall_3a = 1'b0;
				next_lsrh_state = `LSRH_MEMIO;
			end
			default: begin
				stall_3a = 1'bx;
				next_lsrh_state = 3'bxxx;
			end
			endcase
		end
		`DECODE_LDRSTR_UNDEFINED: begin end
		`DECODE_LDRSTR: if(!bubble_3a) begin
			stall_3a = dc__rw_wait_3a;
			case(lsr_state)
			`LSR_MEMIO: begin
				stall_3a = dc__rw_wait_3a;
				next_lsr_state = `LSR_MEMIO;
				if (insn_3a[22] /* B */ && !insn_3a[20] /* L */) begin	/* i.e., strb */
					stall_3a = 1'b1;
					if (!dc__rw_wait_3a)
						next_lsr_state = `LSR_STRB_WR;
				end else if (insn_3a[21] /* W */ || !insn_3a[24] /* P */) begin	/* writeback needed */
					stall_3a = 1'b1;
					if (!dc__rw_wait_3a)
						next_lsr_state = `LSR_BASEWB;
				end
				
				if (flush) begin
					stall_3a = 1'b0;
					next_lsr_state = `LSR_MEMIO;
				end
				$display("LDRSTR: rd_req %d, wr_req %d, raddr %08x, wait %d", dc__rd_req_3a, dc__wr_req_3a, raddr, dc__rw_wait_3a);
			end
			`LSR_STRB_WR: begin
				stall_3a = 1;
				if(insn_3a[21] /* W */ | !insn_3a[24] /* P */) begin
					if(!dc__rw_wait_3a)
						next_lsr_state = `LSR_BASEWB;
				end else if (!dc__rw_wait_3a)
					next_lsr_state = `LSR_WBFLUSH;
				$display("LDRSTR: Handling STRB");
			end
			`LSR_BASEWB: begin
				stall_3a = 1;
				next_lsr_state = `LSR_WBFLUSH;
			end
			`LSR_WBFLUSH: begin
				stall_3a = 0;
				next_lsr_state = `LSR_MEMIO;
			end
			default: begin
				stall_3a = 1'bx;
				next_lsr_state = 4'bxxxx;
			end
			endcase
			$display("LDRSTR: Decoded, bubble %d, insn %08x, lsm state %b -> %b, stall %d", bubble_3a, insn_3a, lsr_state, next_lsr_state, stall_3a);
		end
		`DECODE_LDMSTM: if(!bubble_3a) begin
			stall_3a = dc__rw_wait_3a;
			case(lsm_state)
			`LSM_SETUP: begin
				stall_3a = 1'b1;
				next_lsm_state = `LSM_MEMIO;
				if (flush) begin
					stall_3a = 1'b0;
					next_lsm_state = `LSM_SETUP;
				end
				$display("LDMSTM: Round 1: base register: %08x, reg list %b", op0_3a, op1_3a[15:0]);
			end
			`LSM_MEMIO: begin
				stall_3a = 1'b1;
				if(next_regs == 16'b0 && !dc__rw_wait_3a) begin
					next_lsm_state = `LSM_BASEWB;
				end
				
				$display("LDMSTM: Stage 2: Writing: regs %b, next_regs %b, reg %d, wr_data %08x, addr %08x", regs, next_regs, cur_reg, rf__rdata_3_3a, dc__addr_3a);
			end
			`LSM_BASEWB: begin
				stall_3a = 1;
				next_lsm_state = `LSM_WBFLUSH;
				$display("LDMSTM: Stage 3: Writing back");
			end
			`LSM_WBFLUSH: begin
				stall_3a = 0;
				next_lsm_state = `LSM_SETUP;
			end
			default: begin
				stall_3a = 1'bx;
				next_lsm_state = 4'bxxxx;
			end
			endcase
			$display("LDMSTM: Decoded, bubble %d, insn %08x, lsm state %b -> %b, stall %d", bubble_3a, insn_3a, lsm_state, next_lsm_state, stall_3a);
		end
		`DECODE_LDCSTC: if(!bubble_3a) begin
			$display("WARNING: Unimplemented LDCSTC");
		end
		`DECODE_CDP: if (!bubble_3a) begin
			if (cp_busy) begin
				stall_3a = 1;
			end
			if (!cp_ack) begin
				/* XXX undefined instruction trap */
				$display("WARNING: Possible CDP undefined instruction");
			end
		end
		`DECODE_MRCMCR: if (!bubble_3a) begin
			if (cp_busy) begin
				stall_3a = 1;
			end
			if (!cp_ack) begin
				$display("WARNING: Possible MRCMCR undefined instruction: cp_ack %d, cp_busy %d",cp_ack, cp_busy);
			end
			$display("MRCMCR: ack %d, busy %d", cp_ack, cp_busy);
		end
		default: begin end
		endcase
	end
	
	/* Coprocessor input. */
	always @(*)
	begin
		cp_req = 0;
		cp_rnw = 1'bx;
		cp_write = 32'hxxxxxxxx;
		casez (insn_3a)
		`DECODE_CDP: if(!bubble_3a) begin
			cp_req = 1;
		end
		`DECODE_MRCMCR: if(!bubble_3a) begin
			cp_req = 1;
			cp_rnw = insn_3a[20] /* L */;
			if (insn_3a[20] == 0 /* store to coprocessor */)
				cp_write = op0_3a;
		end
		endcase
	end
	
	/* Register output logic. */
	always @(*)
	begin
		next_write_reg_3a = write_reg_3a;
		next_write_num_3a = write_num_3a;
		next_write_data_3a = write_data_3a;
		next_write_data_mode_3a = `WRD_ACTUAL;
		next_cpsr_3a = (lsm_state == `LSM_MEMIO) ? cpsr_4a : cpsr_3a;
		next_cpsrup_3a = cpsrup_3a;
		
		casez(insn_3a)
		`DECODE_ALU_SWP: if (!bubble_3a) begin
			next_write_reg_3a = 1'bx;
			next_write_num_3a = 4'bxxxx;
			next_write_data_3a = 32'hxxxxxxxx;
			case(swp_state)
			`SWP_READING:
				next_write_reg_3a = 1'b0;
			`SWP_WRITING: begin
				next_write_reg_3a = 1'b1;
				next_write_num_3a = insn_3a[15:12];
				next_write_data_mode_3a = insn_3a[22] /* B */ ? `WRD_OLD_READ_BYTE : `WRD_OLD_READ;
			end
			default: begin end
			endcase
		end
		`DECODE_ALU_MULT: begin
			next_write_reg_3a = write_reg_3a;	/* XXX workaround for ISE 10.1 bug */
			next_write_num_3a = write_num_3a;
			next_write_data_3a = write_data_3a;
			next_cpsr_3a = lsm_state == 4'b0010 ? cpsr_4a : cpsr_3a;
			next_cpsrup_3a = cpsrup_3a;
		end
		`DECODE_ALU_HDATA_REG,
		`DECODE_ALU_HDATA_IMM: if(!bubble_3a) begin
			next_write_reg_3a = 1'bx;
			next_write_num_3a = 4'bxxxx;
			next_write_data_3a = 32'hxxxxxxxx;
			case(lsrh_state)
			`LSRH_MEMIO: begin
				next_write_num_3a = insn_3a[15:12];
				next_write_data_mode_3a = `WRD_LSRH_RDDATA;
				if(insn_3a[20]) begin
					next_write_reg_3a = 1'b1;
				end
			end
			`LSRH_BASEWB: begin
				next_write_reg_3a = 1'b1;
				next_write_num_3a = insn_3a[19:16];
				next_write_data_3a = addr;
			end
			`LSRH_WBFLUSH:
				next_write_reg_3a = 1'b0;
			default: begin end
			endcase
		end
		`DECODE_LDRSTR_UNDEFINED: begin end
		`DECODE_LDRSTR: if(!bubble_3a) begin
			next_write_reg_3a = 1'bx;
			next_write_num_3a = 4'bxxxx;
			next_write_data_3a = 32'hxxxxxxxx;
			case(lsr_state)
			`LSR_MEMIO: begin
				next_write_reg_3a = insn_3a[20] /* L */;
				next_write_num_3a = insn_3a[15:12];
				if(insn_3a[20] /* L */) begin
					next_write_data_mode_3a = insn_3a[22] /* B */ ? `WRD_ALIGN_RDDATA_BYTE : `WRD_ALIGN_RDDATA;
				end
			end
			`LSR_STRB_WR:
				next_write_reg_3a = 1'b0;
			`LSR_BASEWB: begin
				next_write_reg_3a = 1'b1;
				next_write_num_3a = insn_3a[19:16];
				next_write_data_3a = addr;
			end
			`LSR_WBFLUSH:
				next_write_reg_3a = 1'b0;
			default: begin end
			endcase
		end
		`DECODE_LDMSTM: if(!bubble_3a) begin
			next_write_reg_3a = 1'bx;
			next_write_num_3a = 4'bxxxx;
			next_write_data_3a = 32'hxxxxxxxx;
			case(lsm_state)
			`LSM_SETUP:
				next_write_reg_3a = 1'b0;
			`LSM_MEMIO: begin
				if(insn_3a[20] /* L */) begin
					next_write_reg_3a = !dc__rw_wait_3a;
					next_write_num_3a = cur_reg;
					next_write_data_mode_3a = `WRD_OLD_READ;
				end else
					next_write_reg_3a = 1'b0;
			end
			`LSM_BASEWB: begin
				next_write_reg_3a = insn_3a[21] /* writeback */;
				next_write_num_3a = insn_3a[19:16];
				next_write_data_3a = insn_3a[23] ? op0_3a + {26'b0, prev_offset} : op0_3a - {26'b0, prev_offset};
				if(cur_reg == 4'hF && insn_3a[22]) begin
					next_cpsr_3a = spsr_3a;
					next_cpsrup_3a = 1;
				end
			end
			`LSM_WBFLUSH:
				next_write_reg_3a = 1'b0;
			default: begin end
			endcase
		end
		`DECODE_MRCMCR: if(!bubble_3a) begin
			next_write_reg_3a = 1'bx;
			next_write_num_3a = 4'bxxxx;
			next_write_data_3a = 32'hxxxxxxxx;
			next_cpsr_3a = 32'hxxxxxxxx;
			next_cpsrup_3a = 1'bx;
			if (insn_3a[20] == 1 /* load from coprocessor */)
				if (insn_3a[15:12] != 4'hF /* Fuck you ARM */) begin
					next_write_reg_3a = 1'b1;
					next_write_num_3a = insn_3a[15:12];
					next_write_data_3a = cp_read;
				end else begin
					next_cpsr_3a = {cp_read[31:28], cpsr_3a[27:0]};
					next_cpsrup_3a = 1;
				end
		end
		endcase
	end
	
	/* Bus/address control logic. */
	always @(*)
	begin
		dc__rd_req_3a = 1'b0;
		dc__wr_req_3a = 1'b0;
		offset = prev_offset;
		addr = prevaddr;
		raddr = 32'hxxxxxxxx;
		dc__addr_3a = 32'hxxxxxxxx;
		dc__data_size_3a = 3'bxxx;
		
		casez(insn_3a)
		`DECODE_ALU_SWP: if(!bubble_3a) begin
			dc__addr_3a = {op0_3a[31:2], 2'b0};
			dc__data_size_3a = insn_3a[22] ? 3'b001 : 3'b100;
			case(swp_state)
			`SWP_READING:
				dc__rd_req_3a = 1'b1;
			`SWP_WRITING:
				dc__wr_req_3a = 1'b1;
			default: begin end
			endcase
		end
		`DECODE_ALU_MULT: begin
			dc__rd_req_3a = 1'b0;	/* XXX workaround for Xilinx bug */
			dc__wr_req_3a = 1'b0;
			offset = prev_offset;
			addr = prevaddr;
		end
		`DECODE_ALU_HDATA_REG,
		`DECODE_ALU_HDATA_IMM: if(!bubble_3a) begin
			addr = insn_3a[23] ? op0_3a + op1_3a : op0_3a - op1_3a; /* up/down select */
			raddr = insn_3a[24] ? op0_3a : addr; /* pre/post increment */
			dc__addr_3a = raddr;
			/* rotate to correct position */
			case(insn_3a[6:5])
			2'b01: /* unsigned half */
				dc__data_size_3a = 3'b010;
			2'b10: /* signed byte */
				dc__data_size_3a = 3'b001;
			2'b11: /* signed half */
				dc__data_size_3a = 3'b010;
			default: begin
				dc__data_size_3a = 3'bxxx;
			end
			endcase
			
			case(lsrh_state)
			`LSRH_MEMIO: begin
				dc__rd_req_3a = insn_3a[20];
				dc__wr_req_3a = ~insn_3a[20];
			end
			`LSRH_BASEWB: begin end
			`LSRH_WBFLUSH: begin end
			default: begin end
			endcase
		end
		`DECODE_LDRSTR_UNDEFINED: begin end
		`DECODE_LDRSTR: if(!bubble_3a) begin
			addr = insn_3a[23] ? op0_3a + op1_3a : op0_3a - op1_3a; /* up/down select */
			raddr = insn_3a[24] ? addr : op0_3a; /* pre/post increment */
			dc__addr_3a = raddr;
			dc__data_size_3a = insn_3a[22] ? 3'b001 : 3'b100;
			case (lsr_state)
			`LSR_MEMIO: begin
				dc__rd_req_3a = insn_3a[20] /* L */ || insn_3a[22] /* B */;
				dc__wr_req_3a = !insn_3a[20] /* L */ && !insn_3a[22]/* B */;
			end
			`LSR_STRB_WR:
				dc__wr_req_3a = 1;
			`LSR_BASEWB: begin end
			`LSR_WBFLUSH: begin end
			default: begin end
			endcase
		end
		`DECODE_LDMSTM: if (!bubble_3a) begin
			dc__data_size_3a = 3'b100;
			case (lsm_state)
			`LSM_SETUP:
				offset = 6'b0;
			`LSM_MEMIO: begin
				dc__rd_req_3a = insn_3a[20];
				dc__wr_req_3a = ~insn_3a[20];
				offset = prev_offset + 6'h4;
				offset_sel = insn_3a[24] ? offset : prev_offset;
				raddr = insn_3a[23] ? op0_3a + {26'b0, offset_sel} : op0_3a - {26'b0, offset_sel};
				dc__addr_3a = raddr;
			end
			`LSM_BASEWB: begin end
			`LSM_WBFLUSH: begin end
			default: begin end
			endcase
		end
		`DECODE_LDCSTC: begin end
		`DECODE_CDP: begin end
		`DECODE_MRCMCR: begin end
		default: begin end
		endcase
	end
	
	/* Bus data control logic. */
	always @(*)
	begin
		dc__wr_data_3a = 32'hxxxxxxxx;
		
		casez(insn_3a)
		`DECODE_ALU_SWP: if(!bubble_3a)
			if (swp_state == `SWP_WRITING)
				dc__wr_data_3a = insn_3a[22] ? {4{op1_3a[7:0]}} : op1_3a;
		`DECODE_ALU_MULT: begin end
		`DECODE_ALU_HDATA_REG,
		`DECODE_ALU_HDATA_IMM: if(!bubble_3a)
			case(insn_3a[6:5])
			2'b01: /* unsigned half */
				dc__wr_data_3a = {2{op2_3a[15:0]}}; /* XXX need to store halfword */
			2'b10: /* signed byte */
				dc__wr_data_3a = {4{op2_3a[7:0]}};
			2'b11: /* signed half */
				dc__wr_data_3a = {2{op2_3a[15:0]}};
			default: begin end
			endcase
		`DECODE_LDRSTR_UNDEFINED: begin end
		`DECODE_LDRSTR: if(!bubble_3a) begin
			dc__wr_data_3a = insn_3a[22] ? {24'h0, {op2_3a[7:0]}} : op2_3a;
			if (lsr_state == `LSR_STRB_WR)
				case (dc__addr_3a[1:0])
				2'b00: dc__wr_data_3a = {last_rd_data_4a[31:8], op2_3a[7:0]};
				2'b01: dc__wr_data_3a = {last_rd_data_4a[31:16], op2_3a[7:0], last_rd_data_4a[7:0]};
				2'b10: dc__wr_data_3a = {last_rd_data_4a[31:24], op2_3a[7:0], last_rd_data_4a[15:0]};
				2'b11: dc__wr_data_3a = {op2_3a[7:0], last_rd_data_4a[23:0]};
				endcase
		end
		`DECODE_LDMSTM: if (!bubble_3a)
			if (lsm_state == `LSM_MEMIO)
				dc__wr_data_3a = (cur_reg == 4'hF) ? (pc_3a + 12) : rf__rdata_3_3a;
		`DECODE_LDCSTC: begin end
		`DECODE_CDP: begin end
		`DECODE_MRCMCR: begin end
		default: begin end
		endcase
	end
	
	/* LDM/STM register control logic. */
	always @(posedge clk or negedge rst_b)
		if (!rst_b) begin
			prev_reg <= 0;
			regs <= 0;
		end else if (!dc__rw_wait_3a || lsm_state != `LSM_MEMIO) begin
			prev_reg <= cur_reg;
			regs <= next_regs;
		end
	
	always @(*)
	begin
		rf__read_3_3a = 4'hx;
		cur_reg = prev_reg;
		next_regs = regs;
		
		casez(insn_3a)
		`DECODE_LDMSTM: if(!bubble_3a) begin
			case(lsm_state)
			`LSM_SETUP:
				next_regs = insn_3a[23] /* U */ ? op1_3a[15:0] : {op1_3a[0], op1_3a[1], op1_3a[2], op1_3a[3], op1_3a[4], op1_3a[5], op1_3a[6], op1_3a[7],
				                                               op1_3a[8], op1_3a[9], op1_3a[10], op1_3a[11], op1_3a[12], op1_3a[13], op1_3a[14], op1_3a[15]};
			`LSM_MEMIO: begin
				casez(regs)
				16'b???????????????1: begin
					cur_reg = 4'h0;
					next_regs = {regs[15:1], 1'b0};
				end
				16'b??????????????10: begin
					cur_reg = 4'h1;
					next_regs = {regs[15:2], 2'b0};
				end
				16'b?????????????100: begin
					cur_reg = 4'h2;
					next_regs = {regs[15:3], 3'b0};
				end
				16'b????????????1000: begin
					cur_reg = 4'h3;
					next_regs = {regs[15:4], 4'b0};
				end
				16'b???????????10000: begin
					cur_reg = 4'h4;
					next_regs = {regs[15:5], 5'b0};
				end
				16'b??????????100000: begin
					cur_reg = 4'h5;
					next_regs = {regs[15:6], 6'b0};
				end
				16'b?????????1000000: begin
					cur_reg = 4'h6;
					next_regs = {regs[15:7], 7'b0};
				end
				16'b????????10000000: begin
					cur_reg = 4'h7;
					next_regs = {regs[15:8], 8'b0};
				end
				16'b???????100000000: begin
					cur_reg = 4'h8;
					next_regs = {regs[15:9], 9'b0};
				end
				16'b??????1000000000: begin
					cur_reg = 4'h9;
					next_regs = {regs[15:10], 10'b0};
				end
				16'b?????10000000000: begin
					cur_reg = 4'hA;
					next_regs = {regs[15:11], 11'b0};
				end
				16'b????100000000000: begin
					cur_reg = 4'hB;
					next_regs = {regs[15:12], 12'b0};
				end
				16'b???1000000000000: begin
					cur_reg = 4'hC;
					next_regs = {regs[15:13], 13'b0};
				end
				16'b??10000000000000: begin
					cur_reg = 4'hD;
					next_regs = {regs[15:14], 14'b0};
				end
				16'b?100000000000000: begin
					cur_reg = 4'hE;
					next_regs = {regs[15], 15'b0};
				end
				16'b1000000000000000: begin
					cur_reg = 4'hF;
					next_regs = 16'b0;
				end
				default: begin
					cur_reg = 4'hx;
					next_regs = 16'b0;
				end
				endcase
				cur_reg = insn_3a[23] ? cur_reg : 4'hF - cur_reg;
				
				rf__read_3_3a = cur_reg;
			end
			`LSM_BASEWB: begin end
			`LSM_WBFLUSH: begin end
			default: begin end
			endcase
		end
		endcase
	end
	
	always @(*)
	begin
		bubble_4a_next = bubble_3a;
		
		lsrh_rddata = 32'hxxxxxxxx;
		lsrh_rddata_s1 = 16'hxxxx;
		lsrh_rddata_s2 = 8'hxx;
		
		align_s1 = 32'hxxxxxxxx;
		align_s2 = 32'hxxxxxxxx;
		align_rddata = 32'hxxxxxxxx;

		/* XXX shit not given about endianness */
		casez(insn_3a)
		`DECODE_ALU_SWP: if(!bubble_3a) begin
			bubble_4a_next = dc__rw_wait_3a;
			case(swp_state)	/* swp_oldval no longer needed */
			`SWP_READING: begin end
			`SWP_WRITING: begin end
			default: begin end
			endcase
		end
		`DECODE_ALU_MULT: begin
			bubble_4a_next = bubble_3a;	/* XXX workaround for Xilinx bug */
		end
		`DECODE_ALU_HDATA_REG,
		`DECODE_ALU_HDATA_IMM: if(!bubble_3a) begin
			bubble_4a_next = dc__rw_wait_3a;

			case(lsrh_state)
			`LSRH_MEMIO: begin end
			`LSRH_BASEWB:
				bubble_4a_next = 1'b0;
			`LSRH_WBFLUSH: begin end
			default: begin end
			endcase
		end
		`DECODE_LDRSTR_UNDEFINED: begin end
		`DECODE_LDRSTR: if(!bubble_3a) begin
			bubble_4a_next = dc__rw_wait_3a;
			case(lsr_state)
			`LSR_MEMIO: begin end /* previously had do_rd_data_latch -- now implicit */
			`LSR_STRB_WR: begin end
			`LSR_BASEWB:
				bubble_4a_next = 0;
			`LSR_WBFLUSH: begin end
			default: begin end
			endcase
		end
		/* XXX ldm/stm incorrect in that stupid case where one of the listed regs is the base reg */
		`DECODE_LDMSTM: if(!bubble_3a) begin
			bubble_4a_next = dc__rw_wait_3a;
			case(lsm_state)
			`LSM_SETUP: begin end
			`LSM_MEMIO: begin end
			`LSM_BASEWB:
				bubble_4a_next = 0;
			`LSM_WBFLUSH: begin end
			default: $stop;
			endcase
		end
		`DECODE_LDCSTC: begin end
		`DECODE_CDP: if(!bubble_3a) begin
			if (cp_busy) begin
				bubble_4a_next = 1;
			end
		end
		`DECODE_MRCMCR: if(!bubble_3a) begin
			if (cp_busy) begin
				bubble_4a_next = 1;
			end
		end
		default: begin end
		endcase
		
		if ((flush || delayedflush) && !stall_3a)
			bubble_4a_next = 1'b1;
	end
endmodule
