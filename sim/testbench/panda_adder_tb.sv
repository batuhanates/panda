// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

`timescale 1ns/1ps

module panda_adder_tb ();

  parameter int unsigned Width = 32;

  logic signed [Width-1:0] operand_a;
  logic signed [Width-1:0] operand_b;
  logic signed [Width-1:0] result;
  logic                    subtract;

  panda_adder #(
    .Width(Width)
  ) dut (
    .operand_a_i(operand_a),
    .operand_b_i(operand_b),
    .subtract_i (subtract ),
    .result_o   (result   )
  );

  initial begin : proc_stim
    operand_a = 0;
    operand_b = 0;
    subtract = 1'b0;
    $monitor("A = %d, B = %d, sub = %b, result = %d",
      operand_a, operand_b, subtract, result);
    #10 operand_a = 35;
    #10 operand_b = 27;
    #10 subtract = 1;
    #10 operand_a = 12;
    #10 operand_b = -19;
    #10 subtract = 1'b0;
    #10 operand_a = -45;
    #10 subtract = 1'b1;
    #10 $finish;
  end

endmodule
