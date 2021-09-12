`include "defines.v"

module if_stage(
  input Clk,
  input Reset,
  input             Inst_branch_less_i,
  input             Inst_branch_equal_i,  
  input [31:0]      Src_branch_target_i,
  input [2:0]       Inst_branch_code,
  input [31:0]      Src_jump_target_i,    
  input             Jump_line,
  input [31:0]      Instruction_i,       //Currently comes from cpp reg
  input             Stall_if,
  input             Stall_id,

  output reg [31:0] Instruction_o,   //Latch the instruction
  output reg [31:0] Program_counter,
  output reg [7:0]  IF_tracker
  );


wire [1:0] pc_source;
wire [31:0] pc_plus4;
reg branch_line;
reg [31:0] pc_next;

wire cout; //Unused
assign pc_source = {branch_line, Jump_line} | {2{Stall_if||Stall_id}};

carry_select_adder u2 (Program_counter, 32'd4, 1'b0, pc_plus4, cout);

always @ (*) begin
  case (pc_source)
    2'b00: pc_next = pc_plus4;
    2'b01: pc_next = Src_jump_target_i;
    2'b10: pc_next = Src_branch_target_i;
    default: begin
      pc_next = Program_counter; //2'b11: Currently used to freeze PC 
    end
  endcase
  if(((Inst_branch_code == `BEQ) && Inst_branch_equal_i)  ||
     ((Inst_branch_code == `BNE) && !Inst_branch_equal_i) ||
     ((Inst_branch_code == `BGE) && !Inst_branch_less_i ) ||
     ((Inst_branch_code == `BLT) && Inst_branch_less_i)
     )
      branch_line = 1;
  else
    branch_line = 0;
end

always @ (posedge Clk) begin
  if (Reset) begin
    Instruction_o <= 32'h00000013; //NOP during reset
    Program_counter <= 0;
    IF_tracker <= 0;
  end
  else begin
    if (Stall_if)
      Instruction_o <= `NOP; //Inject NOP
    else if(Stall_id)
      Instruction_o <= Instruction_o; //Hold issued instruction
    else
      Instruction_o <= Instruction_i;
    Program_counter <= pc_next;
  end
end

always @ (posedge Clk) begin
  if (Reset)
    IF_tracker <= 1;
  else begin
    if(Stall_id || Stall_if)
      IF_tracker <= IF_tracker;
    else
      IF_tracker <= IF_tracker+1;
  end
end
endmodule