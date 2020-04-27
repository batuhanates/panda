// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

`timescale 1ns/1ps

module panda_comparator_sub_tb ();

  parameter Width = 32;

  logic signed [Width-1:0] operand_a;
  logic signed [Width-1:0] operand_b;
  logic signed [Width-1:0] sub_result;

  logic sign;
  logic is_equal;
  logic is_less;

  panda_comparator_sub #(
    .Width(Width)
  ) dut (
    .sub_result_i(sub_result        ),
    .msb_a_i     (operand_a[Width-1]),
    .msb_b_i     (operand_b[Width-1]),
    .sign_i      (sign              ),
    .is_equal_o  (is_equal          ),
    .is_less_o   (is_less           )
  );

  panda_adder #(
    .Width(Width)
  ) i_adder (
    .operand_a_i(operand_a ),
    .operand_b_i(operand_b ),
    .subtract_i (1'b1      ),
    .result_o   (sub_result)
  );

  initial begin : proc_stim
    operand_a = 0;
    operand_b = 0;
    sign = 1'b0;
    $monitor("A = %d, B = %d, sign = %b, equal = %b, less = %b",
      operand_a, operand_b, sign, is_equal, is_less);
    #10 operand_a = 2342;
    #10 operand_b = 53493;
    #10 operand_a = -123;
    #10 sign = 1'b1;
    #10 operand_b = -23423;
    #10 sign = 1'b0;
    #10 operand_a = -23423;
    #10 sign = 1'b1;
    #10 $finish;
  end


endmodule
