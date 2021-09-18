`include "defines.v"
/**
 * Instruction Decode Stage
 * Instantiates decoder.v
 * Instantiates carry_select_adder.v (Used to calculate j/branch targets)
 **/
module id_stage (
  input Clk,
  input Reset,
  input [31:0]      Instruction,
  input [31:0]      Src_pc_i,
  input [31:0]      Src_rs1_i,
  input [31:0]      Src_rs2_i,     
  input             Stall_data_hazard,
  input [7:0]       IF_tracker,

  output reg [31:0] Src_pc_o,
  output reg [31:0] Src_imm_o,
  output reg [31:0] Src_rs1_o,
  output reg [31:0] Src_rs2_o,   
  output reg [4:0]  Src_rd_o,
  output reg        Inst_exe_src1_sel_o,
  output reg        Inst_exe_src2_sel_o,
  output reg [4:0]  Inst_exe_alu_code_o,
  output reg [1:0]  Inst_mem_out_sel_o,
  output reg [1:0]  Inst_mem_we_o,
  output reg [2:0]  Inst_mem_rd_sel_o,
  output reg        Inst_wb_we_o,
  output reg [7:0]  ID_tracker,  

  output     [31:0] Src_jump_target_o,  
  output reg [31:0] Src_branch_target_o,
  output            Inst_jump,  
  output reg [2:0]  Inst_branch    
  );

wire [6:0] opcode;
wire [2:0] func3;
wire [6:0] func7;
wire [2:0] if_branch;
wire [4:0] alu_code;
wire [1:0] mem_we;
wire [2:0] mem_rd_sel;
wire [1:0] mem_out_sel;
wire wb_en;
wire [8:0] imm_ext_sel;
wire alu_src1_sel;
wire alu_src2_sel;

wire [31:0] immediate_extended;
wire [31:0] jump_adder_src1;
wire cout; //Unused

assign opcode = Instruction[6:0];
assign func3 = Instruction [14:12];
assign func7 = Instruction [31:25];

assign jump_adder_src1 = (opcode == `OP_I_JALR) ? Src_rs1_i : Src_pc_i;


decoder u1 (opcode, func3, func7, if_branch, Inst_jump, alu_code, mem_we, mem_rd_sel, mem_out_sel,
            wb_en, imm_ext_sel, alu_src1_sel, alu_src2_sel);
carry_select_adder u2 (jump_adder_src1, immediate_extended, 1'b0, Src_jump_target_o, cout);

/* Sign Extender Block
  
*/
always @ (*) begin : Sign_Ext_Mux
  case(imm_ext_sel[1:0]) //Mux 1 : Bit 0
    2'b00: immediate_extended[0] = 1'd0;
    2'b01: immediate_extended[0] = Instruction[20];
    2'b10: immediate_extended[0] = Instruction[7];
    2'b11: immediate_extended[0] = 1'd0; //Error
  endcase // imm_ext_sel[1:0]

  case(imm_ext_sel[3:2]) //Mux 2 : Bits [4:1]
    2'b00: immediate_extended[4:1] = 4'd0;
    2'b01: immediate_extended[4:1] = Instruction[24:21];
    2'b10: immediate_extended[4:1] = Instruction[11:8];
    2'b11: immediate_extended[4:1] = 4'd0; //Error
  endcase // imm_ext_sel[3:2]

  case(imm_ext_sel[4]) //Mux 3 : Bits [10-5]
    1'b0: immediate_extended[10:5] = 6'd0;
    1'b1: immediate_extended[10:5] = Instruction[30:25];
  endcase // imm_ext_sel[4]

  case(imm_ext_sel[6:5]) //Mux 4 : Bit 11
    2'b00: immediate_extended[11] = 1'd0;
    2'b01: immediate_extended[11] = Instruction[31];
    2'b10: immediate_extended[11] = Instruction[7];
    2'b11: immediate_extended[11] = Instruction[20];
  endcase // imm_ext_sel[6:5]

  case(imm_ext_sel[7]) //Mux 5 : Bits [19:12]
    1'b0: immediate_extended[19:12] = {8{Instruction[31]}};
    1'b1: immediate_extended[19:12] = Instruction[19:12];
  endcase // imm_ext_sel[7]

  case(imm_ext_sel[8]) //Mux 6 : Bits [30:20]
    1'b0: immediate_extended[30:20] = {11{Instruction[31]}};
    1'b1: immediate_extended[30:20] = Instruction[30:20];
  endcase // imm_ext_sel[8]

  immediate_extended[31] = Instruction[31];
end

/* Latch Stage Outputs Block
  Data hazard injects NOPs into execute stage until hazard clears
*/
always @ (posedge Clk) begin
  if(Reset) begin
    Src_pc_o              <= 0;
    Src_imm_o             <= 0;
    Src_rs1_o             <= 0;
    Src_rs2_o             <= 0;    
    Src_rd_o              <= 0;
    Inst_exe_src1_sel_o   <= 0;
    Inst_exe_src2_sel_o   <= 0;
    Inst_exe_alu_code_o   <= 0;
    Inst_mem_out_sel_o    <= 0;
    Inst_mem_we_o         <= 0;
    Inst_mem_rd_sel_o     <= 0;
    Inst_wb_we_o          <= 0;
    ID_tracker            <= 0;     
    Src_branch_target_o   <= 0;
    Inst_branch           <= 0;
  end
  else begin
    if(Stall_data_hazard) begin //Taken from ADDI section in decoder.v -> inject nop into exe stage
      Src_pc_o  <= Src_pc_i;
      Src_imm_o <= immediate_extended;
      Src_rs1_o <= Src_rs1_i;
      Src_rs2_o <= Src_rs2_i;        
      Src_rd_o  <= 0;
      Inst_exe_src1_sel_o   <= 0;
      Inst_exe_src2_sel_o   <= 1'b1;
      Inst_exe_alu_code_o   <= {`SEL_SIGNED, `ADD};
      Inst_mem_out_sel_o    <= `DEFAULT;
      Inst_mem_we_o         <= `WR_OFF;
      Inst_mem_rd_sel_o     <= `DEFAULT;
      Inst_wb_we_o          <= `WB_EN;
      ID_tracker            <= ID_tracker;        
      Src_branch_target_o   <= Src_jump_target_o;
      Inst_branch           <= `DEFAULT;
    end
    else begin
      Src_pc_o  <= Src_pc_i;
      Src_imm_o <= immediate_extended;
      Src_rs1_o <= Src_rs1_i;
      Src_rs2_o <= Src_rs2_i; 
      Src_rd_o  <= Instruction[11:7];
      Inst_exe_src1_sel_o   <= alu_src1_sel;
      Inst_exe_src2_sel_o   <= alu_src2_sel;
      Inst_exe_alu_code_o   <= alu_code;
      Inst_mem_out_sel_o    <= mem_out_sel;
      Inst_mem_we_o         <= mem_we;
      Inst_mem_rd_sel_o     <= mem_rd_sel;
      Inst_wb_we_o          <= wb_en;
      ID_tracker            <= IF_tracker;
      Src_branch_target_o   <= Src_jump_target_o;
      Inst_branch           <= if_branch;
    end
  end
end

endmodule