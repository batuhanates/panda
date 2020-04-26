// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

`timescale 1ns/1ps

module panda_shifter_tb ();

  parameter Width = 32;

  logic                     left;
  logic                     arithmetic;
  logic [        Width-1:0] operand;
  logic [$clog2(Width)-1:0] amount;
  logic [        Width-1:0] result;

  panda_shifter #(
    .Width(Width)
  ) dut (
    .left_i      (left      ),
    .arithmetic_i(arithmetic),
    .operand_i   (operand   ),
    .amount_i    (amount    ),
    .result_o    (result    )
  );

  initial begin : proc_stim
    operand = 0;
    amount = 0;
    left = 1'b0;
    arithmetic = 1'b0;
    $monitor("operand = %b, amount = %d, left = %b, arith = %b, result = %b",
      operand, amount, left, arithmetic, result);
    #10 operand = 3429435;
    #10 amount = 5;
    #10 arithmetic = 1'b1;
    #10 left = 1'b1;
    #10 arithmetic = 1'b0;
    #10 operand = -4358234;
    amount = 0; arithmetic = 1'b0; left = 1'b0;
    #10 amount = 8;
    #10 arithmetic = 1'b1;
    #10 left = 1'b1;
    #10 arithmetic = 1'b0;
    #10 amount = 24;
    #10 $finish;
  end

endmodule
