/* Logical shift using cascaded multiplexors
*/
module barrel_shifter #(parameter LEFT = 1) (
  input [31:0] A,  
  input [4:0] Shift_amount,
  input Sign_ext_n,
  output [31:0] Y
  );

wire [31:0] l1_out, l2_out, l3_out, l4_out, l5_out; 
wire [15:0] l1_sign;
wire [7:0] l2_sign;
wire [3:0] l3_sign;
wire [1:0] l4_sign;
wire l5_sign;

generate

  if(LEFT == 1) begin
    assign l1_out = (Shift_amount[4]) ? {A[15:0],16'b0}     : A[31:0];      //shift left 16
    assign l2_out = (Shift_amount[3]) ? {l1_out[23:0],8'b0} : l1_out[31:0]; //shift left 8
    assign l3_out = (Shift_amount[2]) ? {l2_out[27:0],4'b0} : l2_out[31:0]; //shift left 4
    assign l4_out = (Shift_amount[1]) ? {l3_out[29:0],2'b0} : l3_out[31:0]; //shift left 2
    assign l5_out = (Shift_amount[0]) ? {l4_out[30:0],1'b0} : l4_out[31:0]; //shift left 1
    assign Y = l5_out;
  end

  else begin
    //Choose if sign extension or zero padding is used (SRA vs SRL)
    assign l1_sign = (!Sign_ext_n) ? {16{A[31]}} : 16'b0;
    assign l2_sign = (!Sign_ext_n) ? {8{A[31]}}  : 8'b0;
    assign l3_sign = (!Sign_ext_n) ? {4{A[31]}}  : 4'b0;
    assign l4_sign = (!Sign_ext_n) ? {2{A[31]}}  : 2'b0;
    assign l5_sign = (!Sign_ext_n) ? A[31]       : 1'b0;
    
    assign l1_out = (Shift_amount[4]) ? {l1_sign, A[31:16]}     : A[31:0];      //shift right 16
    assign l2_out = (Shift_amount[3]) ? {l2_sign, l1_out[31:8]} : l1_out[31:0]; //shift right 8
    assign l3_out = (Shift_amount[2]) ? {l3_sign, l2_out[31:4]} : l2_out[31:0]; //shift right 4
    assign l4_out = (Shift_amount[1]) ? {l4_sign, l3_out[31:2]} : l3_out[31:0]; //shift right 2
    assign l5_out = (Shift_amount[0]) ? {l5_sign, l4_out[31:1]} : l4_out[31:0]; //shift right 1
    assign Y = l5_out;
  end  

endgenerate

endmodule




