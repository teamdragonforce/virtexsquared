`define COND_EQ 4'b0000	/* Z set */
`define COND_NE 4'b0001	/* Z clear */
`define COND_CS 4'b0010	/* C set */
`define COND_CC 4'b0011	/* C clear */
`define COND_MI 4'b0100	/* N set */
`define COND_PL 4'b0101	/* N clear */
`define COND_VS 4'b0110	/* V set */
`define COND_VC 4'b0111	/* V clear */
`define COND_HI 4'b1000	/* C set and Z clear */
`define COND_LS 4'b1001	/* C clear or Z set */
`define COND_GE 4'b1010	/* N equal to V */
`define COND_LT 4'b1011	/* N not equal to V */
`define COND_GT 4'b1100 /* Z clear AND (N equals V) */
`define COND_LE 4'b1101	/* Z set OR (N not equals V) */
`define COND_AL 4'b1110	/* TRUE */
`define COND_NV 4'b1111	/* FALSE */

`define COND_MATTERS(x) ((x != `COND_AL) && (x != `COND_NV))

`define ALU_AND 4'b0000
`define ALU_EOR 4'b0001
`define ALU_SUB 4'b0010
`define ALU_RSB 4'b0011
`define ALU_ADD 4'b0100
`define ALU_ADC 4'b0101
`define ALU_SBC 4'b0110
`define ALU_RSC 4'b0111
`define ALU_TST 4'b1000
`define ALU_TEQ 4'b1001
`define ALU_CMP 4'b1010
`define ALU_CMN 4'b1011
`define ALU_ORR 4'b1100
`define ALU_MOV 4'b1101
`define ALU_BIC 4'b1110
`define ALU_MVN 4'b1111

`define SHIFT_LSL 2'b00
`define SHIFT_LSR 2'b01
`define SHIFT_ASR 2'b10
`define SHIFT_ROR 2'b11

`define CPSR_N	31
`define CPSR_Z	30
`define CPSR_C	29
`define CPSR_V	28
`define CPSR_I	7
`define CPSR_F	6

`define SHIFT_LSL 2'b00
`define SHIFT_LSR 2'b01
`define SHIFT_ASR 2'b10
`define SHIFT_ROR 2'b11

`define DECODE_ALU_MULT		32'b????000000??????????????1001????	/* Multiply -- must come before ALU, because it pattern matches a specific case of ALU */
`define DECODE_ALU_MUL_LONG	32'b????00001???????????????1001????	/* Multiply long */
`define DECODE_ALU_MRS		32'b????00010?001111????000000000000	/* MRS (Transfer PSR to register) */
`define DECODE_ALU_MSR		32'b????00010?101001111100000000????	/* MSR (Transfer register to PSR) */
`define DECODE_ALU_MSR_FLAGS	32'b????00?10?1010001111????????????	/* MSR (Transfer register or immediate to PSR, flag bits only) */
`define DECODE_ALU_SWP		32'b????00010?00????????00001001????	/* Atomic swap */
`define DECODE_ALU_BX		32'b????000100101111111111110001????	/* Branch and exchange */
`define DECODE_ALU_HDATA_REG	32'b????000??0??????????00001??1????	/* Halfword transfer - register offset */
`define DECODE_ALU_HDATA_IMM	32'b????000??1??????????00001??1????	/* Halfword transfer - immediate offset */
`define DECODE_ALU		32'b????00??????????????????????????	/* ALU */
`define DECODE_LDRSTR_UNDEFINED	32'b????011????????????????????1????	/* Undefined. I hate ARM */
`define DECODE_LDRSTR		32'b????01??????????????????????????	/* Single data transfer */
`define DECODE_LDMSTM		32'b????100?????????????????????????	/* Block data transfer */
`define DECODE_BRANCH		32'b????101?????????????????????????	/* Branch */
`define DECODE_LDCSTC		32'b????110?????????????????????????	/* Coprocessor data transfer */
`define DECODE_CDP		32'b????1110???????????????????0????	/* Coprocessor data op */
`define DECODE_MRCMCR		32'b????1110???????????????????1????	/* Coprocessor register transfer */
`define DECODE_SWI		32'b????1111????????????????????????	/* SWI */
