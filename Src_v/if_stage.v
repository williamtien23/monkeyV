`include "defines.v"
/**
 * Instruction Fetch Stage
 * Instantiates carry_select_adder.v (Used to calculate pc+4)
 **/
module if_stage(
  input Clk,
  input Reset,
  input [31:0]      Instruction_i,        //Temporarily used as cpp IO
  input             Src_branch_less_i,
  input             Src_branch_equal_i,
  input [31:0]      Src_jump_target_i,     
  input [31:0]      Src_branch_target_i,
  input             Inst_jump,  
  input [2:0]       Inst_branch,
  input             Stall_ctrl_hazard,
  input             Stall_data_hazard,

  output     [31:0] Instruction_req_addr,   //Temporarily used as cpp IO
  output reg [31:0] Instruction_o,
  output reg [31:0] Program_counter,
  output reg [7:0]  IF_tracker
  );


wire [1:0] pc_source;
wire [31:0] pc_plus4;
wire cout; //Unused
reg [31:0] Src_pc_o;
reg branch_line;
reg [31:0] pc_next;

assign pc_source = {branch_line, Inst_jump} | {2{(Stall_ctrl_hazard)||Stall_data_hazard}};
assign Instruction_req_addr = pc_next;

carry_select_adder u2 (Program_counter, 32'd4, 1'b0, pc_plus4, cout);

/* Program Counter & Branch Select Handler Block
  Data hazard and ctrl hazard both freezes PC until hazard clears
  Branch line asserts if comparator value associated with branch type matches
*/
always @ (*) begin
  case (pc_source)
    2'b00: pc_next = pc_plus4;
    2'b01: pc_next = Src_jump_target_i;
    2'b10: pc_next = Src_branch_target_i;
    default: begin
      pc_next = Program_counter;
    end
  endcase
  if(((Inst_branch == `BEQ) && Src_branch_equal_i)  ||
     ((Inst_branch == `BNE) && !Src_branch_equal_i) ||
     ((Inst_branch == `BGE) && !Src_branch_less_i ) ||
     ((Inst_branch == `BLT) && Src_branch_less_i)
     )
      branch_line = 1;
  else
    branch_line = 0;
end

/* Latch Stage Outputs Block
  Data hazard takes precedence over control hazard
  Data hazard holds issued instruction until hazard clears
  Ctrl hazard injects NOPs into decode stage until hazard clears
*/
always @ (posedge Clk) begin
  if (Reset) begin
    Instruction_o   <= 32'h00000013; //NOP during reset
    Program_counter <= 0;
    Src_pc_o        <= 0;
    IF_tracker      <= 0;
  end
  else begin
    if(Stall_data_hazard) begin : data_stall
      Instruction_o <= Instruction_o;
    end
    else if (Stall_ctrl_hazard) begin : ctrl_stall
      Instruction_o <= `NOP;
      Program_counter <= pc_next;
    end
    else begin : normal_op
      Instruction_o   <= Instruction_i;
      Program_counter <= pc_next;
      Src_pc_o        <= Program_counter;
    end
  end
end

/* Instruction Pipeline Tracker Block
  Not necessary for operation of core, only used for debug purposes
*/
always @ (posedge Clk) begin
  if (Reset)
    IF_tracker <= 1;
  else begin
    if(Stall_data_hazard || Stall_ctrl_hazard)
      IF_tracker <= IF_tracker;
    else
      IF_tracker <= IF_tracker+1;
  end
end
endmodule