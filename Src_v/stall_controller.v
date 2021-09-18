`include "defines.v"

module stall_controller(
  input [6:0] Opcode,
  input [4:0] Rs1,
  input [4:0] Rs2,
  input [4:0] Rd_id2exe,
  input [4:0] Rd_exe2mem,
  input [4:0] Rd_mem2wb, 
  input       We_id2exe,
  input       We_exe2mem,
  input       We_mem2wb,
  output      Stall_ctrl_hazard,
  output      Stall_data_hazard
  );

/*Rules for stall:
  Stall due to data hazard: Freeze PC, Freeze if2id instruction register, Insert id2exe nop
  Stall due to branch: Freeze PC, Insert if2id nop instruction
*/

wire src1_comp, src2_comp; //If source register matches destination register with writeback
wire src1_format, src2_format; //If instruction format uses source register x

assign src1_comp = ((Rs1 == Rd_id2exe) && We_id2exe) || ((Rs1 == Rd_exe2mem) && We_exe2mem) ||  
                   ((Rs1 == Rd_mem2wb) && We_mem2wb);

assign src2_comp = ((Rs2 == Rd_id2exe) && We_id2exe) || ((Rs2 == Rd_exe2mem) && We_exe2mem) || 
                   ((Rs2 == Rd_mem2wb) && We_mem2wb);

assign src1_format = ((Opcode == `OP_R) || (Opcode == `OP_I_JALR) || (Opcode == `OP_I_LD ) || 
                      (Opcode == `OP_I_ARITH) || (Opcode == `OP_S) || (Opcode == `OP_B));

assign src2_format = ((Opcode == `OP_R) || (Opcode == `OP_S) || (Opcode == `OP_B));


assign Stall_data_hazard = (src1_comp && src1_format && Rs1 != 0) ||
                           (src2_comp && src2_format && Rs2 != 0);
assign Stall_ctrl_hazard = (Opcode == `OP_B);

endmodule

