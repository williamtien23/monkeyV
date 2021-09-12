/**
 * RV32i verilog implementation
 * 5-stage pipeline: IF-ID-EXE-MEM-WB
 * Requires external Imem, Dmem
 * Assumes ideal single cycle R/W memory
 **/
module top_core (
  input Clk,
  input Reset,
  input [31:0]  Imem_data_read_cpp,
  input [31:0]  Dmem_data_read_cpp,
  output [31:0] Imem_addr_cpp,
  output [7:0]  Dmem_data_wr1_cpp,
  output [7:0]  Dmem_data_wr2_cpp,
  output [7:0]  Dmem_data_wr3_cpp,
  output [7:0]  Dmem_data_wr4_cpp,
  output [31:0] Dmem_addr_cpp,
  output [1:0]  Dmem_write_en
  );

//Forward Connection [fetch to decode]
  wire [31:0] if2id_instruction;
  wire [31:0] if2id_pc;
//Reg File
  wire [31:0] id_rs1_data, id_rs2_data;
//Forward Connection [decode to execute]
  wire [31:0] id2exe_pc, id2exe_imm, id2exe_rs1, id2exe_rs2;
  wire [4:0]  id2exe_rd;
  wire        id2exe_src1_sel, id2exe_src2_sel;
  wire [4:0]  id2exe_alu_code;
  wire [1:0]  id2exe_mem_out_sel;
  wire [1:0]  id2exe_mem_we;
  wire [2:0]  id2exe_mem_rd_sel;
  wire        id2exe_wb_we;
//Forward connection [execute to memory]
  wire [31:0] exe2mem_pc, exe2mem_alu_result, exe2mem_rs2, exe2mem_imm;
  wire [4:0]  exe2mem_rd;
  wire [1:0]  exe2mem_mem_out_sel;
  wire [1:0]  exe2mem_mem_we;
  wire [2:0]  exe2mem_mem_rd_sel;
  wire        exe2mem_wb_we;
//Forward Connection [memory to writeback]
  wire [31:0] mem2wb_wb_data;
  wire [4:0]  mem2wb_wb_addr;
  wire mem2wb_wb_we;
//Backward Connection [decode to fetch]
  wire [31:0] id2if_branch_target; 
  wire [2:0]  id2if_branch_sel;
  wire [31:0] id2if_jump_target;   
  wire        id2if_jump_sel;
//Backward Connection [execute to fetch]
  wire        exe2if_branch_less;
  wire        exe2if_branch_equal;
  wire        exe2if_branch_greater; //unused
//Hazard Ctrl
  wire stall_if;
  wire stall_id;


  wire [4:0] wb_addr;
  wire [7:0] Aif_inst, Aid_inst, Aexe_inst, Amem_inst;
  reg [7:0] Awb_inst;

assign Imem_addr_cpp = if2id_pc;

if_stage fetch (
  .Clk(Clk),
  .Reset(Reset),
  .Inst_branch_less_i(exe2if_branch_less),
  .Inst_branch_equal_i(exe2if_branch_equal),  
  .Src_branch_target_i(id2if_branch_target),
  .Inst_branch_code(id2if_branch_sel),
  .Src_jump_target_i(id2if_jump_target),    
  .Jump_line(id2if_jump_sel),
  .Instruction_i(Imem_data_read_cpp),
  .Stall_if(stall_if),
  .Stall_id(stall_id),
  .Instruction_o(if2id_instruction),
  .Program_counter(if2id_pc),
  .IF_tracker(Aif_inst)
  );

stall_controller stall_ctrl(
  .Opcode(if2id_instruction[6:0]),
  .Rs1(if2id_instruction[19:15]),
  .Rs2(if2id_instruction[24:20]),
  .Rd_id2exe(id2exe_rd),
  .Rd_exe2mem(exe2mem_rd),
  .Rd_mem2wb(mem2wb_wb_addr),
  .We_id2exe(id2exe_wb_we),
  .We_exe2mem(exe2mem_wb_we),
  .We_mem2wb(mem2wb_wb_we),
  .Stall_if(stall_if),
  .Stall_id(stall_id)
  );

id_stage decode (
  .Clk(Clk),
  .Reset(Reset),
  .Instruction(if2id_instruction),
  .Src_pc_i(if2id_pc),
  .Src_rs1_i(id_rs1_data),
  .Src_rs2_i(id_rs2_data),  
  .Stall_id(stall_id),
  .Src_pc_o(id2exe_pc),
  .Src_rs1_o(id2exe_rs1),
  .Src_rs2_o(id2exe_rs2),   
  .Src_imm_o(id2exe_imm),
  .Src_rd_o(id2exe_rd),
  .Inst_exe_src1_sel_o(id2exe_src1_sel),
  .Inst_exe_src2_sel_o(id2exe_src2_sel),
  .Inst_exe_alu_code_o(id2exe_alu_code),
  .Inst_mem_out_sel_o(id2exe_mem_out_sel),
  .Inst_mem_we_o(id2exe_mem_we),
  .Inst_mem_rd_sel_o(id2exe_mem_rd_sel),
  .Inst_wb_we_o(id2exe_wb_we),
  .Src_branch_target_o(id2if_branch_target),
  .Inst_branch_code(id2if_branch_sel),
  .Src_jump_target_o(id2if_jump_target),    
  .Inst_jump(id2if_jump_sel),
  .IF_tracker(Aif_inst),
  .ID_tracker(Aid_inst)
  );


reg_file reg_file (
  .Clk(Clk),
  .Reset(Reset),
  .Rd_Addr(wb_addr),
  .Rs1_Addr(if2id_instruction[19:15]),
  .Rs2_Addr(if2id_instruction[24:20]),
  .Rd_Data(mem2wb_wb_data),
  .Rs1_Data(id_rs1_data),
  .Rs2_Data(id_rs2_data)
  );

exe_stage execute(
  .Clk(Clk),
  .Reset(Reset),
  .Src_pc_i(id2exe_pc),
  .Src_rs1_i(id2exe_rs1),
  .Src_rs2_i(id2exe_rs2),
  .Src_imm_i(id2exe_imm),
  .Src_rd_i(id2exe_rd),
  .Inst_exe_src1_sel_i(id2exe_src1_sel),
  .Inst_exe_src2_sel_i(id2exe_src2_sel),
  .Inst_exe_alu_code_i(id2exe_alu_code),
  .Inst_mem_out_sel_i(id2exe_mem_out_sel),
  .Inst_mem_we_i(id2exe_mem_we),
  .Inst_mem_rd_sel_i(id2exe_mem_rd_sel),
  .Inst_wb_we_i(id2exe_wb_we),
  .Src_pc_o(exe2mem_pc),
  .Src_alu_o(exe2mem_alu_result),
  .Src_rs2_o(exe2mem_rs2),
  .Src_imm_o(exe2mem_imm),
  .Src_rd_o(exe2mem_rd),
  .Inst_mem_out_sel_o(exe2mem_mem_out_sel),
  .Inst_mem_we_o(Dmem_write_en),             //Has to go to cpp
  .Inst_mem_rd_sel_o(exe2mem_mem_rd_sel),
  .Inst_wb_we_o(exe2mem_wb_we),
  .Inst_branch_less_o(exe2if_branch_less),
  .Inst_branch_equal_o(exe2if_branch_equal),
  .Inst_branch_greater_o(exe2if_branch_greater),
  .ID_tracker(Aid_inst),
  .Exe_tracker(Aexe_inst)    
  );

mem_stage memory(
  .Clk(Clk),
  .Reset(Reset),
  .Src_pc_i(exe2mem_pc),
  .Src_alu_i(exe2mem_alu_result),
  .Src_rs2_i(exe2mem_rs2),
  .Src_imm_i(exe2mem_imm),
  .Src_rd_i(exe2mem_rd),
  .Inst_mem_out_sel_i(exe2mem_mem_out_sel),
  .Inst_mem_rd_sel_i(exe2mem_mem_rd_sel),
  .Inst_wb_we_i(exe2mem_wb_we),
  .Dmem_data_read(Dmem_data_read_cpp),        //Currently comes from cpp testbench
  .Dmem_data_wr1(Dmem_data_wr1_cpp),         //To cpp
  .Dmem_data_wr2(Dmem_data_wr2_cpp),
  .Dmem_data_wr3(Dmem_data_wr3_cpp),
  .Dmem_data_wr4(Dmem_data_wr4_cpp),
  .Dmem_addr(Dmem_addr_cpp),            //To cpp
  .Src_wb_o(mem2wb_wb_data),
  .Src_rd_o(mem2wb_wb_addr),
  .Inst_wb_we_o(mem2wb_wb_we),
  .Exe_tracker(Aexe_inst),
  .Mem_tracker(Amem_inst)    
  );

  assign wb_addr = (mem2wb_wb_we) ? (mem2wb_wb_addr) : 0; //Writes to x0 if write disabled

always @ (posedge Clk) begin
  if (Reset)
    Awb_inst <= 0;
  else
    Awb_inst <= Amem_inst;
end

endmodule