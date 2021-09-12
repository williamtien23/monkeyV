/* Top Level*/
/**
 * Adder is split into 4-bit groupings
 * Each group produces a+b and a+b+1 in parallel
 * Each group produces 1 carry bit stored in carry_chain
 **/
module carry_select_adder(

  input wire [31:0] A,
  input wire [31:0] B,
  input wire Cin,
  output wire [31:0] Y,
  output wire Cout
);
  /* verilator lint_off UNOPTFLAT */
  wire [7:0] carry_chain;

  Full_Adder Group1 (A[3:0], B[3:0], Cin, Y[3:0], carry_chain[0]);

  genvar i;
  for (i=0; i<7; i=i+1) begin: adder
    wire c0_carry;
    wire c1_carry;
    wire [3:0] c0_sum;
    wire [3:0] c1_sum;
    Full_Adder u1 (A[4*(i+2)-1 : 4*(i+1)], B[4*(i+2)-1 : 4*(i+1)],
                   1'b0, c0_sum[3:0], c0_carry);
    Full_Adder u2 (A[4*(i+2)-1 : 4*(i+1)], B[4*(i+2)-1 : 4*(i+1)],
                   1'b1, c1_sum[3:0], c1_carry);
    Mux_2x1 u3 (c0_sum[3:0], c1_sum[3:0], carry_chain[i], Y[4*(i+2)-1 : 4*(i+1)]);
    Carry_Select u4 (c0_carry, c1_carry, carry_chain[i], carry_chain[i+1]); 
  end

  assign Cout = carry_chain[7];

endmodule

//Grouped in 4 bits
module Full_Adder ( 

  input wire [3:0] A,
  input wire [3:0] B,
  input wire Cin,
  output reg [3:0] Y,
  output reg Cout
);

  wire [3:0] carry_chain;

  //always @ (*) begin
    assign carry_chain[0] = Cin;
    assign carry_chain[3:1] = (A[2:0] & B[2:0]) | (A[2:0] & carry_chain[2:0]) | (B[2:0] & carry_chain[2:0]);
  //end
  
  always @ (*) begin
    Y = A ^ B ^ carry_chain;
    Cout = (A[3] & B[3]) | (A[3] & carry_chain[3]) | (B[3] & carry_chain[3]);
  end
  
endmodule

//Basically OR and AND gate
module Carry_Select (

  input wire A, B, C,
  output reg Y
);
  always @ (*) begin
    Y = A | (B & C);
  end

endmodule

//2 to 1 mux, 4bit bus
module Mux_2x1 (

  input wire [3:0] In0,
  input wire [3:0] In1,
  input wire Sel,
  output reg [3:0] Out
);

  always @ (*) begin
    Out = Sel ? In1 : In0;
  end
  
endmodule
