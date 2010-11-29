parameter DMA_SPAM_ADDR_HI = 23;
parameter NEXT_START_REG_ADDR = 24'h000;
parameter NEXT_LEN_REG_ADDR = 24'h004;
parameter COMMAND_REG_ADDR = 24'h008;
parameter FIFO_BYTES_READ_REG_ADDR = 24'h00c;
parameter TOTAL_BYTES_DELIVERED_REG_ADDR = 24'h010;  

parameter COMMAND_REGISTER_HI = 1;
parameter DMA_STOP = 2'b00;
parameter DMA_TRIGGER_ONCE = 2'b01;
parameter DMA_AUTOTRIGGER = 2'b10;

