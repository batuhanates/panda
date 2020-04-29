// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_adder #(
  parameter int unsigned Width = 32
) (
  input  logic [Width-1:0] operand_a_i,
  input  logic [Width-1:0] operand_b_i,
  input  logic             subtract_i,
  output logic [Width-1:0] result_o
);

  logic [Width:0] operand_a_ext;
  logic [Width:0] operand_b_ext;
  logic [Width:0] result_ext;

  // In order to perform both add and subtract operations with a single adder,
  // operands are extended from right (as a carry in bit) and operand_b_i is
  // XOR'd with the subtract_i input. Extended bit is ignored on result.
  assign operand_a_ext = {operand_a_i, 1'b1};
  assign operand_b_ext = {operand_b_i ^ {Width{subtract_i}}, subtract_i};
  assign result_ext    = $unsigned(operand_a_ext) + $unsigned(operand_b_ext);
  assign result_o      = result_ext[Width:1];

endmodule
