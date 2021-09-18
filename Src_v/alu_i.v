`include "defines.v"
/**
 * Integer ALU
 * Instantiates carry_select_adder.v
 * Instantiates magnitude_comparator.v
 * Instantiates barrel_shifter.v
 **/
module alu_i(
  input [31:0] A,
  input [31:0] B,
  input [3:0]  Code,
  input        Sel,

  output reg [31:0] C,
  output Less,
  output Equal,
  output Greater
  );

//Codes (see defines.v) : Add=0 Shift_l=1 Shift_r=2 XOR=3 OR=4 AND=5 Comp=6 nop=7
//Sel : 0=signed 1=unsigned/subtraction

//Adder Signals
wire cout;
wire [31:0] b_adder;
assign b_adder = (Sel) ? (~B + 1) : B; //Sel add/sub encoding
//Comparator Signals
wire lt_s;
wire eq_s; 
wire gt_s;
reg lt_u;
reg eq_u;
reg gt_u;
//Output selection signals
wire [31:0] y_adder, y_shift_l, y_shift_r;
wire y_lt;

assign y_lt     = (Sel) ? lt_u : lt_s;
assign Less     = y_lt;
assign Equal    = (Sel) ? eq_u : eq_s;
assign Greater  = (Sel) ? gt_u : gt_s;

//Submodule Instantiation
carry_select_adder u1 (A, b_adder, 1'b0, y_adder, cout); //A, B, Cin, Y, Cout
magnitude_comparator u2 (A, B, lt_s, eq_s, gt_s); //A, B, Sel, Less, Equal, Greater
barrel_shifter u3 (A, B[4:0], 1'b0, y_shift_l); //A, Shamt, Sign_Extend, Y
barrel_shifter #(.LEFT(0)) u4 (A, B[4:0], Sel, y_shift_r); //A, Shamt, Sign_Extend, Y

//Comparator Unsigned
always @ (*) begin: comp_u
  if(A[31] == B[31]) begin //A - B cannot overflow
    if(y_adder[31] == 1'b0) begin
      lt_u = 0;
      if(y_adder[30:0] == 31'b0) begin
        eq_u = 1;
        gt_u = 0;
      end
      else begin
        eq_u = 0;
        gt_u = 1;
      end
    end  
    else begin
      lt_u = 1;
      eq_u = 0;
      gt_u = 0;
    end
  end
  else if(A[31] == 1) begin //Automatically implies A is larger
    lt_u = 0;
    eq_u = 0;
    gt_u = 1;
  end
  else begin //Automatically implies A is smaller
    lt_u = 1;
    eq_u = 0;
    gt_u = 0;
  end
end

//Output Selection Block
always @ (*) begin
  case (Code)  
    `ADD:      C = y_adder;
    `SHIFT_L:  C = y_shift_l;
    `SHIFT_R:  C = y_shift_r;
    `XOR:      C = A ^ B;
    `OR:       C = A | B;
    `AND:      C = A & B;
    `COMP:     C = {31'd0,y_lt};
    default:  begin
      C = 32'd0;
    end
  endcase
end

endmodule