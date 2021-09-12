module reg_file (
  input Clk,
  input Reset,
  input [4:0] Rd_Addr,
  input [4:0] Rs1_Addr,
  input [4:0] Rs2_Addr,
  input [31:0] Rd_Data,
  output [31:0] Rs1_Data,
  output [31:0] Rs2_Data
  );

reg [31:0] rs1_reg;
reg [31:0] rs2_reg;

reg [31:0] x0, x1, x2, x3, x4, x5, x6, x7, x8, x9;
reg [31:0] x10, x11, x12, x13, x14, x15, x16, x17, x18, x19;
reg [31:0] x20, x21, x22, x23, x24, x25, x26, x27, x28, x29;
reg [31:0] x30, x31;

assign Rs1_Data = rs1_reg;
assign Rs2_Data = rs2_reg;

always @ (posedge Clk) begin //Write Logic
  if(Reset) begin
    x0 <= 32'd0;
    x1 <= 32'd0;
    x2 <= 32'd4096;
    x3 <= 32'd0;
    x4 <= 32'd0;
    x5 <= 32'd0;
    x6 <= 32'd0;
    x7 <= 32'd0;
    x8 <= 32'd0;
    x9 <= 32'd0;
    x10 <= 32'd0;
    x11 <= 32'd0;
    x12 <= 32'd0;
    x13 <= 32'd0;
    x14 <= 32'd0;
    x15 <= 32'd0;
    x16 <= 32'd0;
    x17 <= 32'd0;
    x18 <= 32'd0;
    x19 <= 32'd0;
    x20 <= 32'd0;
    x21 <= 32'd0;
    x22 <= 32'd0;
    x23 <= 32'd0;
    x24 <= 32'd0;
    x25 <= 32'd0;
    x26 <= 32'd0;
    x27 <= 32'd0;
    x28 <= 32'd0;
    x29 <= 32'd0;
    x30 <= 32'd0;
    x31 <= 32'd0;
  end // if(Reset)
  else begin
    case (Rd_Addr) //1->32 Mux
      5'd0: begin
            //NOP - x0 read only
            end
      5'd1: x1 <= Rd_Data;
      5'd2: x2 <= Rd_Data;
      5'd3: x3 <= Rd_Data;
      5'd4: x4 <= Rd_Data;
      5'd5: x5 <= Rd_Data;
      5'd6: x6 <= Rd_Data;
      5'd7: x7 <= Rd_Data;
      5'd8: x8 <= Rd_Data;
      5'd9: x9 <= Rd_Data;
      5'd10: x10 <= Rd_Data;
      5'd11: x11 <= Rd_Data;
      5'd12: x12 <= Rd_Data;
      5'd13: x13 <= Rd_Data;
      5'd14: x14 <= Rd_Data;
      5'd15: x15 <= Rd_Data;
      5'd16: x16 <= Rd_Data;
      5'd17: x17 <= Rd_Data;
      5'd18: x18 <= Rd_Data;
      5'd19: x19 <= Rd_Data;
      5'd20: x20 <= Rd_Data;
      5'd21: x21 <= Rd_Data;
      5'd22: x22 <= Rd_Data;
      5'd23: x23 <= Rd_Data;
      5'd24: x24 <= Rd_Data;
      5'd25: x25 <= Rd_Data;
      5'd26: x26 <= Rd_Data;
      5'd27: x27 <= Rd_Data;
      5'd28: x28 <= Rd_Data;
      5'd29: x29 <= Rd_Data;
      5'd30: x30 <= Rd_Data;
      5'd31: x31 <= Rd_Data;
      default: begin
               //NOP
               end
    endcase // Rd_Addr
  end
end

always @ (*) begin
  case (Rs1_Addr)
    5'd0: rs1_reg = x0;
    5'd1: rs1_reg = x1;
    5'd2: rs1_reg = x2;
    5'd3: rs1_reg = x3;
    5'd4: rs1_reg = x4;
    5'd5: rs1_reg = x5;
    5'd6: rs1_reg = x6;
    5'd7: rs1_reg = x7;
    5'd8: rs1_reg = x8;
    5'd9: rs1_reg = x9;
    5'd10: rs1_reg = x10;
    5'd11: rs1_reg = x11;
    5'd12: rs1_reg = x12;
    5'd13: rs1_reg = x13;
    5'd14: rs1_reg = x14;
    5'd15: rs1_reg = x15;
    5'd16: rs1_reg = x16;
    5'd17: rs1_reg = x17;
    5'd18: rs1_reg = x18;
    5'd19: rs1_reg = x19;
    5'd20: rs1_reg = x20;
    5'd21: rs1_reg = x21;
    5'd22: rs1_reg = x22;
    5'd23: rs1_reg = x23;
    5'd24: rs1_reg = x24;
    5'd25: rs1_reg = x25;
    5'd26: rs1_reg = x26;
    5'd27: rs1_reg = x27;
    5'd28: rs1_reg = x28;
    5'd29: rs1_reg = x29;
    5'd30: rs1_reg = x30;
    5'd31: rs1_reg = x31;
    default: begin
             //NOP
             end
    endcase // Rs1_Addr

  case (Rs2_Addr)
    5'd0: rs2_reg = x0;
    5'd1: rs2_reg = x1;
    5'd2: rs2_reg = x2;
    5'd3: rs2_reg = x3;
    5'd4: rs2_reg = x4;
    5'd5: rs2_reg = x5;
    5'd6: rs2_reg = x6;
    5'd7: rs2_reg = x7;
    5'd8: rs2_reg = x8;
    5'd9: rs2_reg = x9;
    5'd10: rs2_reg = x10;
    5'd11: rs2_reg = x11;
    5'd12: rs2_reg = x12;
    5'd13: rs2_reg = x13;
    5'd14: rs2_reg = x14;
    5'd15: rs2_reg = x15;
    5'd16: rs2_reg = x16;
    5'd17: rs2_reg = x17;
    5'd18: rs2_reg = x18;
    5'd19: rs2_reg = x19;
    5'd20: rs2_reg = x20;
    5'd21: rs2_reg = x21;
    5'd22: rs2_reg = x22;
    5'd23: rs2_reg = x23;
    5'd24: rs2_reg = x24;
    5'd25: rs2_reg = x25;
    5'd26: rs2_reg = x26;
    5'd27: rs2_reg = x27;
    5'd28: rs2_reg = x28;
    5'd29: rs2_reg = x29;
    5'd30: rs2_reg = x30;
    5'd31: rs2_reg = x31;
    default: begin
             //NOP
             end
  endcase // Rs1_Addr    
end
endmodule // reg_file


