// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_shifter #(
  parameter Width       = 32,
  parameter AmountWidth = $clog2(Width)
) (
  input  logic                   left_i,
  input  logic                   arithmetic_i,
  input  logic [      Width-1:0] operand_i,
  input  logic [AmountWidth-1:0] amount_i,
  output logic [      Width-1:0] result_o
);

  logic [Width-1:0] operand_rev;
  logic [  Width:0] operand_ext;
  logic [  Width:0] result_ext;
  logic [Width-1:0] result_rev;

  // Reverse the operand for left shit.
  // This allows a single shifter hardware to do both left and right shift.
  for (genvar i = 0; i < Width; i++) begin
    assign operand_rev[i] = operand_i[Width-1-i];
  end
  assign operand_ext[Width-1:0] = left_i ? operand_rev : operand_i;

  // Extend the operand with either MSB of operand for arithmetic shift
  // or 0 for logic shift then do arithmetic shift. This allows a single
  // shifter hardware to do both arithmetic and logic shift.
  assign operand_ext[Width] = arithmetic_i & operand_ext[Width-1];
  assign result_ext         = $signed(operand_ext) >>> amount_i;

  // Reverse the result back for left shift
  for (genvar i = 0; i < Width; i++) begin
    assign result_rev[i] = result_ext[Width-1-i];
  end

  assign result_o = left_i ? result_rev : result_ext[Width-1:0];

endmodule
