`include "defines.v"
/**
 * Memory Stage
 * Instantiates carry_select_adder.v (Used to calculate pc+4)
 **/
module mem_stage (
  input Clk,
  input Reset,
  input [31:0]      Src_pc_i,
  input [31:0]      Src_alu_i,
  input [31:0]      Src_rs2_i,
  input [31:0]      Src_imm_i,
  input [4:0]       Src_rd_i,
  input [1:0]       Inst_mem_out_sel_i,
//input [1:0]       Inst_mem_we_i,           //Temporarily re-routed from exe stage to cpp IO
  input [2:0]       Inst_mem_rd_sel_i,
  input             Inst_wb_we_i,
  input [7:0]       Exe_tracker,

  input [31:0]      Dmem_data_read,        //Temporarily comes from cpp IO
  output [7:0]      Dmem_data_wr1,         //^
  output [7:0]      Dmem_data_wr2,         //^
  output [7:0]      Dmem_data_wr3,         //^
  output [7:0]      Dmem_data_wr4,         //^
  output [31:0]     Dmem_addr,             //^

  output reg [31:0] Src_wb_o,
  output reg [4:0]  Src_rd_o,
  output reg        Inst_wb_we_o,
  output reg [7:0]  Mem_tracker 
  );

wire [31:0] pc_plus4;
wire cout; //unused
reg [31:0] mem2wb_data;
reg [31:0] dmem_read_extended;

assign Dmem_data_wr1 = Src_rs2_i [7:0]; //LSB
assign Dmem_data_wr2 = Src_rs2_i [15:8];
assign Dmem_data_wr3 = Src_rs2_i [23:16];
assign Dmem_data_wr4 = Src_rs2_i [31:24]; //MSB
assign Dmem_addr = Src_alu_i;

carry_select_adder u1 (Src_pc_i, 32'd4, 1'b0, pc_plus4, cout);

/* Writeback Data Selection Block
  Choose data to send to writeback stage
  Can pass data read from mem, or passthrough for data from earlier stages
*/
always @ (*) begin
  case(Inst_mem_out_sel_i)
    `MEM_PC:  mem2wb_data = pc_plus4;
    `MEM_ALU: mem2wb_data = Src_alu_i;
    `MEM_LD:  mem2wb_data = dmem_read_extended;
    `MEM_IMM: mem2wb_data = Src_imm_i;
  endcase
end

/* Data Read Extension Block
  Reads of sizes less than word need to be 0-padded or sign extended
*/
always @ (*) begin
  case(Inst_mem_rd_sel_i)
  `RD_HWORD:   dmem_read_extended = {{16{Dmem_data_read[15]}},Dmem_data_read[15:0]};
  `RD_BYTE:    dmem_read_extended = {{24{Dmem_data_read[7]}},Dmem_data_read[7:0]};
  `RD_HWORD_U: dmem_read_extended = {16'd0, Dmem_data_read[15:0]};
  `RD_BYTE_U:  dmem_read_extended = {24'd0, Dmem_data_read[7:0]};
  default:     dmem_read_extended = Dmem_data_read; //Read whole word
  endcase
end

/* Latch Stage Outputs Block
  Data hazard injects NOPs into execute stage until hazard clears
*/
always @ (posedge Clk) begin
  if(Reset) begin
    Src_wb_o      <= 0;
    Src_rd_o      <= 0;
    Inst_wb_we_o  <= 0;
    Mem_tracker   <= 0;    
  end
  else begin
    Src_wb_o      <= mem2wb_data;
    Src_rd_o      <= Src_rd_i;
    Inst_wb_we_o  <= Inst_wb_we_i;
    Mem_tracker   <= Exe_tracker;     
  end
end

endmodule