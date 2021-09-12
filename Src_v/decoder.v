`include "defines.v"


module decoder (
  input [6:0] Opcode,
  input [2:0] Func3,
  input [6:0] Func7,
  output reg [2:0] If_branch,
  output reg       If_jump,
  output reg [4:0] Alu_code,
  output reg [1:0] Mem_we,
  output reg [2:0] Mem_rd_sel,
  output reg [1:0] Mem_out_sel,
  output reg Wb_en,
  output reg [8:0] Imm_ext_sel,
  output Alu_src1_sel,
  output Alu_src2_sel
);

//SOURCE OPERAND 1 SELECTION
assign Alu_src1_sel = (Opcode==`OP_U_AUIPC) ? 0 : 1;

//SOURCE OPERAND 2 SELECTION
assign Alu_src2_sel = (Opcode==`OP_R) ? 0 : 1;  

//SOURCE OPERAND 2 IMMEDIATE SIGN EXTENDER MUX ENCODING
always @ (*) begin
  case(Opcode)
    `OP_I_JALR, `OP_I_LD, `OP_I_ARITH: Imm_ext_sel = `FORMAT_I;
    `OP_S: Imm_ext_sel = `FORMAT_S;
    `OP_B: Imm_ext_sel = `FORMAT_B;
    `OP_U_LUI, `OP_U_AUIPC: Imm_ext_sel = `FORMAT_U;
    `OP_J: Imm_ext_sel = `FORMAT_J;
    default: Imm_ext_sel = `DEFAULT;
  endcase
end

//Instruction Decoding
always @ (*) begin
  if ((Opcode == `OP_R) && (Func3 == 3'b000) && (Func7 == 7'b0000000))begin //ADD
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_R) && (Func3 == 3'b000) && (Func7 == 7'b0000000)) begin //SUB
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_NEG_B, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_ARITH) && (Func3 == 3'b000)) begin //ADDI
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_U_AUIPC)) begin //AUIPC
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_S) && (Func3 == 3'b010)) begin //SW
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_WORD;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `DEFAULT;
    Wb_en       = `WB_DISABLE;
  end
  else if ((Opcode == `OP_S) && (Func3 == 3'b001)) begin //SH
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_HWORD;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `DEFAULT;
    Wb_en       = `WB_DISABLE;
  end
  else if ((Opcode == `OP_S) && (Func3 == 3'b000)) begin //SB
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_BYTE;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `DEFAULT;
    Wb_en       = `WB_DISABLE;
  end
  else if ((Opcode == `OP_I_LD) && (Func3 == 3'b101)) begin //LHU
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `RD_HWORD_U;
    Mem_out_sel = `MEM_LD;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_LD) && (Func3 == 3'b100)) begin //LBU
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `RD_BYTE_U;
    Mem_out_sel = `MEM_LD;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_LD) && (Func3 == 3'b010)) begin //LW
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_LD;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_LD) && (Func3 == 3'b001)) begin //LH
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `RD_HWORD;
    Mem_out_sel = `MEM_LD;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_LD) && (Func3 == 3'b000)) begin //LB
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `RD_BYTE;
    Mem_out_sel = `MEM_LD;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_R) && (Func3 == 3'b111) && (Func7 == 7'b0000000)) begin //AND
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `AND};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_ARITH) && (Func3 == 3'b111)) begin //ANDI
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `AND};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_R) && (Func3 == 3'b110) && (Func7 == 7'b0000000)) begin //OR
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `OR};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_ARITH) && (Func3 == 3'b110)) begin //ORI
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `OR};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end   
  else if ((Opcode == `OP_R) && (Func3 == 3'b100) && (Func7 == 7'b0000000)) begin //XOR
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `XOR};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_ARITH) && (Func3 == 3'b100)) begin //XORI
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `XOR};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end   
  else if ((Opcode == `OP_R) && (Func3 == 3'b101) && (Func7 == 7'b0100000)) begin // SRA
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `SHIFT_R};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_R) && (Func3 == 3'b101) && (Func7 == 7'b0000000)) begin //SRL
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_UNSIGNED, `SHIFT_R};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_ARITH) && (Func3 == 3'b101) && (Func7 == 7'b0100000)) begin // SRAI
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `SHIFT_R};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_ARITH) && (Func3 == 3'b101) && (Func7 == 7'b0000000)) begin //SRLI
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_UNSIGNED, `SHIFT_R};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_R) && (Func3 == 3'b001) && (Func7 == 7'b0000000)) begin //SLL
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `SHIFT_L};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_ARITH) && (Func3 == 3'b001) && (Func7 == 7'b0000000)) begin //SLLI
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `SHIFT_L};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_R) && (Func3 == 3'b010) && (Func7 == 7'b0000000)) begin //SLT
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `COMP};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_ARITH) && (Func3 == 3'b010)) begin //SLTI
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `COMP};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_B) && (Func3 == 3'b000)) begin //BEQ
    If_branch   = `BEQ;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `COMP};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `DEFAULT;
    Wb_en       = `WB_DISABLE;
  end
  else if ((Opcode == `OP_B) && (Func3 == 3'b001)) begin //BNE
    If_branch   = `BNE;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `COMP};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `DEFAULT;
    Wb_en       = `WB_DISABLE;
  end
  else if ((Opcode == `OP_B) && (Func3 == 3'b100)) begin //BLT
    If_branch   = `BLT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `COMP};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `DEFAULT;
    Wb_en       = `WB_DISABLE;
  end
  else if ((Opcode == `OP_B) && (Func3 == 3'b101)) begin //BGE
    If_branch   = `BGE;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `COMP};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `DEFAULT;
    Wb_en       = `WB_DISABLE;
  end
  else if ((Opcode == `OP_R) && (Func3 == 3'b011) && (Func7 == 7'b0000000)) begin //SLTU
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_UNSIGNED, `COMP};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_ARITH) && (Func3 == 3'b011)) begin //SLTIU
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `COMP};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_B) && (Func3 == 3'b101)) begin //BLTU
    If_branch   = `BLT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_UNSIGNED, `COMP};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `DEFAULT;
    Wb_en       = `WB_DISABLE;
  end
  else if ((Opcode == `OP_B) && (Func3 == 3'b111)) begin //BGEU
    If_branch   = `BGE;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_UNSIGNED, `COMP};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `DEFAULT;
    Wb_en       = `WB_DISABLE;
  end
  else if ((Opcode == `OP_U_LUI)) begin //LUI
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_IMM;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_J)) begin //JAL
    If_branch   = `DEFAULT;
    If_jump     = 1'b1;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_PC;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_JALR)) begin //JALR
    If_branch   = `DEFAULT;
    If_jump     = 1'b1;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_PC;
    Wb_en       = `WB_EN;
  end
  else begin //Default
    If_branch   = `DEFAULT;
    If_jump     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_DISABLE;
  end
end
endmodule


