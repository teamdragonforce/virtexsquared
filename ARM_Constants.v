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
`define COND_GT 4'b1010	/* N equal to V */
`define COND_LT 4'b1011	/* N not equal to V */
`define COND_GT 4'b1100 /* Z clear AND (N equals V) */
`define COND_LE 4'b1101	/* Z set OR (N not equals V) */
`define COND_AL 4'b1110	/* TRUE */
`define COND_NV 4'b1111	/* FALSE */
