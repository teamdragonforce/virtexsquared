parameter FSAB_REQ_HI = 0;

parameter FSAB_READ = 1'b0;
parameter FSAB_WRITE = 1'b1;

parameter FSAB_DID_HI = 3;

parameter FSAB_DID_CPU = 4'h0;
parameter FSAB_SUBDID_CPU_ICACHE = 4'h0;
parameter FSAB_SUBDID_CPU_DCACHE = 4'h1;
parameter FSAB_SUBDID_CPU_DMAC = 4'h2;

parameter FSAB_DID_FRAME = 4'h1;
parameter FSAB_SUBDID_FRAME_0 = 4'h0;

parameter FSAB_DID_AUDIO = 4'h2;
parameter FSAB_SUBDID_AUDIO = 4'h0;

parameter FSAB_ADDR_HI = 30;
parameter FSAB_ADDR_LO = 3;
parameter FSAB_LEN_HI = 3;
parameter FSAB_DATA_HI = 63;
parameter FSAB_MASK_HI = 7;

parameter FSAB_LEN_MAX = 8;

parameter FSAB_INITIAL_CREDITS = 4;
parameter FSAB_CREDITS_HI = 2;
