/*
---------------------------------------
inst   opcode      func3   func7
---------------------------------------

adder / arithmetic
 ADD = 7'b0110011, 3'b000, 7'b0000000 [OP_R]
 SUB = 7'b0110011, 3'b000, 7'b0100000 [OP_R]
ADDI = 7'b0010011, 3'b000, 7'bxxxxxxx [OP_I_ARITH]
AUIPC= 7'b0010111, 3'bxxx, 7'bxxxxxxx [OP_U_AUIPC]
  SW = 7'b0100011, 3'b010, 7'bxxxxxxx [OP_S]
  SH = 7'b0100011, 3'b001, 7'bxxxxxxx [OP_S]
  SB = 7'b0100011, 3'b000, 7'bxxxxxxx [OP_S]
 LHU = 7'b0000011, 3'b101, 7'bxxxxxxx [OP_I_LD]
 LBU = 7'b0000011, 3'b100, 7'bxxxxxxx [OP_I_LD]
  LW = 7'b0000011, 3'b010, 7'bxxxxxxx [OP_I_LD]
  LH = 7'b0000011, 3'b001, 7'bxxxxxxx [OP_I_LD]
  LB = 7'b0000011, 3'b000, 7'bxxxxxxx [OP_I_LD]

and / logical
 AND = 7'b0110011, 3'b111, 7'b0000000 [OP_R]
ANDI = 7'b0010011, 3'b111, 7'bxxxxxxx [OP_I_ARITH]

or / logical
 OR  = 7'b0110011, 3'b110, 7'b0000000 [OP_R]
 ORI = 7'b0010011, 3'b110, 7'bxxxxxxx [OP_I_ARITH]

not / logical
 XOR = 7'b0110011, 3'b100, 7'b0000000 [OP_R]
XORI = 7'b0010011, 3'b100, 7'bxxxxxxx [OP_I_ARITH]

shift - use barrel shifter right
 SRA = 7'b0110011, 3'b101, 7'b0100000 [OP_R]
 SRL = 7'b0110011, 3'b101, 7'b0000000 [OP_R]
SRAI = 7'b0010011, 3'b101, 7'b0100000 [OP_I_ARITH]
SRLI = 7'b0010011, 3'b101, 7'b0000000 [OP_I_ARITH]

shift - use barrel shifter left
 SLL = 7'b0110011, 3'b001, 7'b0000000 [OP_R]
SLLI = 7'b0010011, 3'b001, 7'b0000000 [OP_I_ARITH]

comparator - use cascaded magnitude comparator
 SLT = 7'b0110011, 3'b010, 7'b0000000 [OP_R]
SLTI = 7'b0010011, 3'b010, 7'bxxxxxxx [OP_I_ARITH]
 BEQ = 7'b1100011, 3'b000, 7'xxxxxxxx [OP_B] 
 BNE = 7'b1100011, 3'b001, 7'xxxxxxxx [OP_B] 
 BLT = 7'b1100011, 3'b100, 7'xxxxxxxx [OP_B] 
 BGE = 7'b1100011, 3'b101, 7'xxxxxxxx [OP_B] 

//use adder for unsigned comparison
SLTU = 7'b0110011, 3'b011, 7'b0000000 [OP_R]
SLTIU= 7'b0010011, 3'b011, 7'bxxxxxxx [OP_I_ARITH]
BLTU = 7'b1100011, 3'b110, 7'xxxxxxxx [OP_B]  
BGEU = 7'b1100011, 3'b111, 7'xxxxxxxx [OP_B] 

no ALU
 LUI = 7'b0110111, 3'bxxx, 7'bxxxxxxx [OP_U_LUI]
 JAL = 7'b1101111, 3'bxxx, 7'bxxxxxxx [OP_J] 
JALR = 7'b1100111, 3'bxxx, 7'bxxxxxxx [OP_I_JALR]

todo: ecall ebreak
*/
`ifndef DEFINES
`define DEFINES

//INSTRUCTION FETCH DEFINES
  //0 reserved for default : no branch
  `define BEQ   3'b001
  `define BNE   3'b010
  `define BGE   3'b011
  `define BLT   3'b100

//INSTRUCTION DECODE DEFINES
  //OPCODES
  `define OP_R        7'b0110011
  `define OP_I_JALR   7'b1100111
  `define OP_I_LD     7'b0000011
  `define OP_I_ARITH  7'b0010011
  `define OP_S        7'b0100011
  `define OP_B        7'b1100011
  `define OP_U_LUI    7'b0110111
  `define OP_U_AUIPC  7'b0010111
  `define OP_J        7'b1101111
  //Missing Fence 0001111 - I type
  //Missing CSR/ebreak/ecall 1110011 - I type
  //IMMEDIATE SIGN EXT CODE
  `define FORMAT_I {1'd0, 1'd0, 2'd1, 1'd1, 2'd1, 2'd1}
  `define FORMAT_S {1'd0, 1'd0, 2'd1, 1'd1, 2'd2, 2'd2}
  `define FORMAT_B {1'd0, 1'd0, 2'd2, 1'd1, 2'd2, 2'd0}
  `define FORMAT_U {1'd1, 1'd1, 2'd0, 1'd0, 2'd0, 2'd0}
  `define FORMAT_J {1'd0, 1'd1, 2'd3, 1'd1, 2'd1, 2'd0}

//EXEUTE DEFINES  
  //ALU CODES
  `define ADD      4'd0
  `define SHIFT_L  4'd1
  `define SHIFT_R  4'd2
  `define XOR      4'd3
  `define OR       4'd4
  `define AND      4'd5
  `define COMP     4'd6
  //ALU SELECTS
  `define SEL_SIGNED    1'd0
  `define SEL_UNSIGNED  1'd1
  `define SEL_NEG_B     1'd1

//MEMORY DEFINES
  //WRITES
  `define WR_OFF      2'b00
  `define WR_WORD     2'b01
  `define WR_HWORD    2'b10
  `define WR_BYTE     2'b11
  //READS
  `define RD_HWORD    3'b001
  `define RD_BYTE     3'b010
  `define RD_HWORD_U  3'b011
  `define RD_BYTE_U   3'b100
  //OUTPUT
  `define MEM_PC   2'b00
  `define MEM_ALU  2'b01
  `define MEM_LD   2'b10
  `define MEM_IMM  2'b11
//WRITE BACK DEFINES
  `define WB_DISABLE 1'b0
  `define WB_EN      1'b1

  `define DEFAULT 0
  `define NOP 32'h00000013
`endif