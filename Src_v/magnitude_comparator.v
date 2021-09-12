/** Top module
 * Instantiates (32/4)-1 = 7, 4-bit comparators to compare bits [27-0].
 * Instantiates 1, 3-bit comparator to compare bits [30-28] and reserve bit [31] for 
 * dedicated sign bit comparison.
 * Always block "Top", evaluates sign and relies on [30-0] 31-bit unsigned comparator's
 * result if sign bit [31] of A and B are equal.
 **/
module magnitude_comparator(
  input wire [31:0] A,
  input wire [31:0] B,
  output reg Less,
  output reg Equal,
  output reg Greater
);

//Sign comparison
wire a_n_32, b_n_32;
wire sign_lt, sign_gt, sign_eq;
assign a_n_32 = ~A[31];
assign b_n_32 = ~B[31];
assign sign_lt = A[31] & b_n_32;
assign sign_gt = B[31] & a_n_32;  
assign sign_eq = ~(sign_lt | sign_gt);

//Bits [30:0] unsigned magnitude comparator
wire [7:0] lt_l3, eq_l3, gt_l3;
wire [6:0] lt_l4, gt_l4;
reg u_comparator_lt;
reg u_comparator_eq;
reg u_comparator_gt;

genvar i;
for(i=0; i<7; i=i+1) begin: l4
  magnitude_comp_4bit u1 (A[4*(i+1)-1 : 4*i], B[4*(i+1)-1 : 4*i], lt_l3[i], eq_l3[i], gt_l3[i]);
  assign lt_l4[i] = &eq_l3[7:i+1] & lt_l3[i];
  assign gt_l4[i] = &eq_l3[7:i+1] & gt_l3[i];
end

magnitude_comp_3bit u1 (A[30:28], B[30:28], lt_l3[7], eq_l3[7], gt_l3[7]);

always @ (*) begin: unsigned_comparator
  if((|lt_l4) || lt_l3[7]) begin
    u_comparator_lt = 1;
    u_comparator_eq = 0;
    u_comparator_gt = 0;
  end
  else if((|gt_l4) || gt_l3[7]) begin
    u_comparator_lt = 0;
    u_comparator_eq = 0;
    u_comparator_gt = 1;
  end
  else if(&eq_l3[7:0]) begin
    u_comparator_lt = 0;
    u_comparator_eq = 1;
    u_comparator_gt = 0;
  end
  else begin
    u_comparator_lt = 0;
    u_comparator_eq = 0;
    u_comparator_gt = 0;
  end
end

always @ (*) begin: top
  if(sign_lt || (sign_eq && u_comparator_lt)) begin //LT
    Less    = 1;
    Equal   = 0;
    Greater = 0;
  end
  else if(sign_gt || (sign_eq && u_comparator_gt)) begin //GT
    Less    = 0;
    Equal   = 0;
    Greater = 1;
  end
  else if((sign_eq && u_comparator_eq)) begin //EQ
    Less    = 0;
    Equal   = 1;
    Greater = 0;
  end
  else begin //Default: Error
    Less    = 0;
    Equal   = 0;
    Greater = 0;
  end
end

endmodule // magnitude_comparator

/** Submodule: 4-bit comparator
 * 
 **/
module magnitude_comp_4bit(
  input wire [3:0] A,
  input wire [3:0] B,
  output reg Y_LT,
  output reg Y_EQ,
  output reg Y_GT
  );

wire [3:0] a_n, b_n;
wire [3:0] lt_l1, eq_l1, gt_l1;
wire [2:0] lt_l2, gt_l2;

//Inversion
assign a_n = ~ A;
assign b_n = ~B;

//L1 
genvar i, j;
for (i=0; i<4; i=i+1) begin: l1
  assign lt_l1[i] = a_n[i] & B[i];
  assign eq_l1[i] = ~(lt_l1[i] | gt_l1[i]);
  assign gt_l1[i] = A[i] & b_n[i];
end

//L2
for (j=0; j<3; j=j+1) begin: l2
  assign lt_l2[j] = &eq_l1[3:j+1] & lt_l1[j];
  assign gt_l2[j] = &eq_l1[3:j+1] & gt_l1[j];
end

//Result (L3)
always @ (*) begin
  if(lt_l1[3] || (|lt_l2[2:0])) begin //less than
    Y_LT = 1;
    Y_EQ = 0;
    Y_GT = 0;
  end
  else if (gt_l1[3] || (|gt_l2[2:0])) begin//greater than
    Y_LT = 0;
    Y_EQ = 0;
    Y_GT = 1;
  end
  else if (&eq_l1[3:0]) begin //equal
    Y_LT = 0;
    Y_EQ = 1;
    Y_GT = 0;
  end
  else begin //undefined
    Y_LT = 0;
    Y_EQ = 0;
    Y_GT = 0;
  end
end

endmodule // magnitude_comp_4bit

/** Submodule: 3-bit comparator
 * 
 **/
module magnitude_comp_3bit(
  input wire [2:0] A,
  input wire [2:0] B,
  output reg Y_LT,
  output reg Y_EQ,
  output reg Y_GT
  );

wire [2:0] a_n, b_n;
wire [2:0] lt_l1, eq_l1, gt_l1;
wire [1:0] lt_l2, gt_l2;

//Inversion
assign a_n = ~ A;
assign b_n = ~B;

//L1 
genvar i, j;
for (i=0; i<3; i=i+1) begin: l1
  assign lt_l1[i] = a_n[i] & B[i];
  assign eq_l1[i] = ~(lt_l1[i] | gt_l1[i]);
  assign gt_l1[i] = A[i] & b_n[i];
end

//L2
for (j=0; j<2; j=j+1) begin: l2
  assign lt_l2[j] = &eq_l1[2:j+1] & lt_l1[j];
  assign gt_l2[j] = &eq_l1[2:j+1] & gt_l1[j];
end

//Result (L3)
always @ (*) begin
  if(lt_l1[2] || (|lt_l2[1:0])) begin //less than
    Y_LT = 1;
    Y_EQ = 0;
    Y_GT = 0;
  end
  else if (gt_l1[2] || (|gt_l2[1:0])) begin//greater than
    Y_LT = 0;
    Y_EQ = 0;
    Y_GT = 1;
  end
  else if (&eq_l1[2:0]) begin //equal
    Y_LT = 0;
    Y_EQ = 1;
    Y_GT = 0;
  end
  else begin //undefined
    Y_LT = 0;
    Y_EQ = 0;
    Y_GT = 0;
  end
end

endmodule // magnitude_comp_3bit
