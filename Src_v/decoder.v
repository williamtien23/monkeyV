`include "defines.v"

module decoder (
  input [6:0] Opcode,
  input [2:0] Func3,
  input [6:0] Func7,
  output reg [2:0] Branch_sel,
  output reg       Jump_sel,
  output reg [4:0] Alu_code,
  output reg [1:0] Mem_we,
  output reg [2:0] Mem_rd_sel,
  output reg [1:0] Mem_out_sel,
  output reg       Wb_en,
  output reg [8:0] Imm_ext_sel,
  output Alu_src1_sel,
  output Alu_src2_sel
);

//Source Operand 1 Selection : Mux0->PC Mux1->Rs1
assign Alu_src1_sel = (Opcode==`OP_U_AUIPC) ? 0 : 1;

//Source Operand 2 Selection : Mux1->Rs2 Mux1->Immediate
assign Alu_src2_sel = (Opcode==`OP_R || Opcode==`OP_B) ? 0 : 1;  

//Sign Extension Encoding
always @ (*) begin
  case(Opcode)
    `OP_I_JALR, 
    `OP_I_LD, 
    `OP_I_ARITH : Imm_ext_sel = `FORMAT_I;
    `OP_S       : Imm_ext_sel = `FORMAT_S;
    `OP_B       : Imm_ext_sel = `FORMAT_B;
    `OP_U_LUI,
    `OP_U_AUIPC : Imm_ext_sel = `FORMAT_U;
    `OP_J       : Imm_ext_sel = `FORMAT_J;
    default     : Imm_ext_sel = `DEFAULT;
  endcase
end

//Instruction Decoding
always @ (*) begin
  if ((Opcode == `OP_R) && (Func3 == 3'b000) && (Func7 == 7'b0000000))begin //ADD
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_R) && (Func3 == 3'b000) && (Func7 == 7'b0100000)) begin //SUB
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_NEG_B, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_ARITH) && (Func3 == 3'b000)) begin //ADDI
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_U_AUIPC)) begin //AUIPC
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_S) && (Func3 == 3'b010)) begin //SW
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_WORD;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `DEFAULT;
    Wb_en       = `WB_DISABLE;
  end
  else if ((Opcode == `OP_S) && (Func3 == 3'b001)) begin //SH
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_HWORD;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `DEFAULT;
    Wb_en       = `WB_DISABLE;
  end
  else if ((Opcode == `OP_S) && (Func3 == 3'b000)) begin //SB
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_BYTE;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `DEFAULT;
    Wb_en       = `WB_DISABLE;
  end
  else if ((Opcode == `OP_I_LD) && (Func3 == 3'b101)) begin //LHU
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `RD_HWORD_U;
    Mem_out_sel = `MEM_LD;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_LD) && (Func3 == 3'b100)) begin //LBU
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `RD_BYTE_U;
    Mem_out_sel = `MEM_LD;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_LD) && (Func3 == 3'b010)) begin //LW
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_LD;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_LD) && (Func3 == 3'b001)) begin //LH
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `RD_HWORD;
    Mem_out_sel = `MEM_LD;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_LD) && (Func3 == 3'b000)) begin //LB
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `RD_BYTE;
    Mem_out_sel = `MEM_LD;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_R) && (Func3 == 3'b111) && (Func7 == 7'b0000000)) begin //AND
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `AND};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_ARITH) && (Func3 == 3'b111)) begin //ANDI
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `AND};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_R) && (Func3 == 3'b110) && (Func7 == 7'b0000000)) begin //OR
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `OR};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_ARITH) && (Func3 == 3'b110)) begin //ORI
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `OR};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end   
  else if ((Opcode == `OP_R) && (Func3 == 3'b100) && (Func7 == 7'b0000000)) begin //XOR
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `XOR};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_ARITH) && (Func3 == 3'b100)) begin //XORI
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `XOR};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end   
  else if ((Opcode == `OP_R) && (Func3 == 3'b101) && (Func7 == 7'b0100000)) begin // SRA
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `SHIFT_R};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_R) && (Func3 == 3'b101) && (Func7 == 7'b0000000)) begin //SRL
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_UNSIGNED, `SHIFT_R};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_ARITH) && (Func3 == 3'b101) && (Func7 == 7'b0100000)) begin // SRAI
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `SHIFT_R};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_ARITH) && (Func3 == 3'b101) && (Func7 == 7'b0000000)) begin //SRLI
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_UNSIGNED, `SHIFT_R};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_R) && (Func3 == 3'b001) && (Func7 == 7'b0000000)) begin //SLL
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `SHIFT_L};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_ARITH) && (Func3 == 3'b001) && (Func7 == 7'b0000000)) begin //SLLI
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `SHIFT_L};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_R) && (Func3 == 3'b010) && (Func7 == 7'b0000000)) begin //SLT
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `COMP};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_ARITH) && (Func3 == 3'b010)) begin //SLTI
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `COMP};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_B) && (Func3 == 3'b000)) begin //BEQ
    Branch_sel   = `BEQ;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `COMP};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `DEFAULT;
    Wb_en       = `WB_DISABLE;
  end
  else if ((Opcode == `OP_B) && (Func3 == 3'b001)) begin //BNE
    Branch_sel   = `BNE;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `COMP};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `DEFAULT;
    Wb_en       = `WB_DISABLE;
  end
  else if ((Opcode == `OP_B) && (Func3 == 3'b100)) begin //BLT
    Branch_sel   = `BLT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `COMP};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `DEFAULT;
    Wb_en       = `WB_DISABLE;
  end
  else if ((Opcode == `OP_B) && (Func3 == 3'b101)) begin //BGE
    Branch_sel   = `BGE;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `COMP};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `DEFAULT;
    Wb_en       = `WB_DISABLE;
  end
  else if ((Opcode == `OP_R) && (Func3 == 3'b011) && (Func7 == 7'b0000000)) begin //SLTU
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_UNSIGNED, `COMP};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_ARITH) && (Func3 == 3'b011)) begin //SLTIU
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_UNSIGNED, `COMP};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_B) && (Func3 == 3'b110)) begin //BLTU
    Branch_sel   = `BLT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_UNSIGNED, `COMP};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `DEFAULT;
    Wb_en       = `WB_DISABLE;
  end
  else if ((Opcode == `OP_B) && (Func3 == 3'b111)) begin //BGEU
    Branch_sel   = `BGE;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_UNSIGNED, `COMP};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `DEFAULT;
    Wb_en       = `WB_DISABLE;
  end
  else if ((Opcode == `OP_U_LUI)) begin //LUI
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_IMM;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_J)) begin //JAL
    Branch_sel   = `DEFAULT;
    Jump_sel     = 1'b1;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_PC;
    Wb_en       = `WB_EN;
  end
  else if ((Opcode == `OP_I_JALR)) begin //JALR
    Branch_sel   = `DEFAULT;
    Jump_sel     = 1'b1;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_PC;
    Wb_en       = `WB_EN;
  end
  else begin //Default
    Branch_sel   = `DEFAULT;
    Jump_sel     = `DEFAULT;
    Alu_code    = {`SEL_SIGNED, `ADD};
    Mem_we      = `WR_OFF;
    Mem_rd_sel  = `DEFAULT;
    Mem_out_sel = `MEM_ALU;
    Wb_en       = `WB_DISABLE;
  end
end
endmodule


