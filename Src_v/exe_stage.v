module exe_stage (
  input Clk,
  input Reset,
  input [31:0]      Src_pc_i,
  input [31:0]      Src_rs1_i,
  input [31:0]      Src_rs2_i,
  input [31:0]      Src_imm_i,
  input [4:0]       Src_rd_i,
  input             Inst_exe_src1_sel_i,
  input             Inst_exe_src2_sel_i,
  input [4:0]       Inst_exe_alu_code_i, //[3:0] Code + Sel
  input [1:0]       Inst_mem_out_sel_i,
  input [1:0]       Inst_mem_we_i,
  input [2:0]       Inst_mem_rd_sel_i,
  input             Inst_wb_we_i,
  input [7:0]       ID_tracker,

  output reg [31:0] Src_pc_o,
  output reg [31:0] Src_alu_o,
  output reg [31:0] Src_rs2_o,
  output reg [31:0] Src_imm_o,
  output reg [4:0]  Src_rd_o,
  output reg [1:0]  Inst_mem_out_sel_o,
  output reg [1:0]  Inst_mem_we_o,
  output reg [2:0]  Inst_mem_rd_sel_o,
  output reg        Inst_wb_we_o,
  output reg [7:0]  Exe_tracker,

  output Inst_branch_less_o,
  output Inst_branch_equal_o,
  output Inst_branch_greater_o
  );

wire [31:0] src1, src2, alu_out;

assign src1 = (Inst_exe_src1_sel_i) ? Src_rs1_i : Src_pc_i;
assign src2 = (Inst_exe_src2_sel_i) ? Src_imm_i : Src_rs2_i;


//Netlist: A, B, Code, Sel, C, Less, Equal, Greater
alu_i u1 (src1, src2, Inst_exe_alu_code_i[3:0], Inst_exe_alu_code_i[4], alu_out, 
          Inst_branch_less_o, Inst_branch_equal_o, Inst_branch_greater_o); 

always @ (posedge Clk) begin //Registering outputs
  if(Reset) begin
    Src_pc_o  <= 0;
    Src_alu_o <= 0;
    Src_rs2_o <= 0;
    Src_imm_o <= 0;
    Src_rd_o  <= 0;
    Inst_mem_out_sel_o <= 0;
    Inst_mem_we_o      <= 0;
    Inst_mem_rd_sel_o  <= 0;
    Inst_wb_we_o       <= 0;
    Exe_tracker        <= 0;
  end
  else begin
    Src_pc_o  <= Src_pc_i;
    Src_alu_o <= alu_out;
    Src_rs2_o <= Src_rs2_i;
    Src_imm_o <= Src_imm_i;
    Src_rd_o  <= Src_rd_i;
    Inst_mem_out_sel_o <= Inst_mem_out_sel_i;
    Inst_mem_we_o      <= Inst_mem_we_i;
    Inst_mem_rd_sel_o  <= Inst_mem_rd_sel_i;
    Inst_wb_we_o       <= Inst_wb_we_i;
    Exe_tracker        <= ID_tracker;    
  end
end

endmodule