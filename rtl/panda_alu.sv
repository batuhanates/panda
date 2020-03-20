// Copyright 2020 Batuhan Ates
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_alu (
  input  panda_pkg::alu_operator_e operator_i,
  input  logic [31:0]              operand_a_i,
  input  logic [31:0]              operand_b_i,
  output logic [31:0]              result_o
);
  import panda_pkg::*;

  // Adder
  logic        adder_sub;
  logic [32:0] adder_in_a;
  logic [32:0] adder_in_b;
  logic [32:0] adder_result_ext;
  logic [31:0] adder_result;

  always_comb begin
    adder_sub = 1'b0;
    unique case (operator_i)
      ALU_SUB,
      ALU_EQ,
      ALU_NE,
      ALU_LT,
      ALU_LTU,
      ALU_GE,
      ALU_GEU : adder_sub = 1'b1;
      default : ;
    endcase
  end

  assign adder_in_a       = {operand_a_i, 1'b1};
  assign adder_in_b       = {operand_b_i ^ {32{adder_sub}}, adder_sub};
  assign adder_result_ext = $unsigned(adder_in_a) + $unsigned(adder_in_b);
  assign adder_result     = adder_result_ext[32:1];

  // Comparator
  logic cmp_signed;
  logic is_equal;
  logic is_less;
  logic cmp_result;

  always_comb begin
    cmp_signed = 1'b0;
    unique case (operator_i)
      ALU_LT,
      ALU_GE  : cmp_signed = 1'b1;
      default : ;
    endcase
  end

  assign is_equal = adder_result == 32'b0;

  always_comb begin
    if (operand_a_i[31] ^ operand_b_i[31]) begin
      is_less = operand_b_i[31] ^ cmp_signed;
    end else begin
      is_less = adder_result[31];
    end
  end

  always_comb begin
    cmp_result = is_equal;
    unique case (operator_i)
      ALU_EQ  : cmp_result = is_equal;
      ALU_NE  : cmp_result = ~is_equal;
      ALU_LT,
      ALU_LTU : cmp_result = is_less;
      ALU_GE,
      ALU_GEU : cmp_result = ~is_less;
      default : ;
    endcase
  end

  // Shifter
  logic        shift_left;
  logic        shift_arithmetic;
  logic [ 4:0] shift_amount;
  logic [31:0] operand_a_rev;
  logic [32:0] shift_operand;
  logic [32:0] shift_result_ext;
  logic [31:0] shift_result;
  logic [31:0] shift_result_rev;

  for (genvar i = 0; i < 32; i++) begin
    assign operand_a_rev[i] = operand_a_i[31-i];
  end

  assign shift_left          = operator_i == ALU_SLL;
  assign shift_arithmetic    = operator_i == ALU_SRA;
  assign shift_operand[31:0] = shift_left ? operand_a_rev : operand_a_i;
  assign shift_operand[32]   = shift_arithmetic ? shift_operand[31] : 1'b0;
  assign shift_amount        = operand_b_i[4:0];
  assign shift_result_ext    = $signed(shift_operand) >>> shift_amount;
  assign shift_result        = shift_result_ext[31:0];

  for (genvar i = 0; i < 32; i++) begin
    assign shift_result_rev[i] = shift_result[31-i];
  end

  // Result Output
  always_comb begin
    result_o = '0;
    unique case (operator_i)
      ALU_ADD,
      ALU_SUB : result_o = adder_result;

      ALU_AND : result_o = operand_a_i & operand_b_i;
      ALU_OR  : result_o = operand_a_i | operand_b_i;
      ALU_XOR : result_o = operand_a_i ^ operand_b_i;

      ALU_SLL : result_o = shift_result_rev;
      ALU_SRL,
      ALU_SRA : result_o = shift_result;

      ALU_EQ,
      ALU_NE,
      ALU_LT,
      ALU_LTU,
      ALU_GE,
      ALU_GEU : result_o = {31'b0, cmp_result};

      default : ;
    endcase
  end

endmodule
