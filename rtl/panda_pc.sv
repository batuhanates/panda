// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_pc #(
  parameter int unsigned Width = 32
) (
  input  logic             clk_i,
  input  logic             rst_ni,
  input  logic             branch_i,
  input  logic             jump_i,
  input  logic [Width-1:0] branch_target_i,
  input  logic [Width-1:0] jump_target_i,
  output logic [Width-1:0] pc_o,
  output logic [Width-1:0] pc_inc_o
);

  logic [Width-1:0] pc;
  logic [Width-1:0] pc_inc;
  logic [Width-1:0] pc_next;

  assign pc_o     = pc;
  assign pc_inc_o = pc_inc;

  assign pc_next = jump_i ? jump_target_i : (branch_i ? branch_target_i : pc_inc);

  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_pc
    if(~rst_ni) begin
      pc <= 0;
    end else begin
      pc <= pc_next;
    end
  end

  panda_adder #(
    .Width(Width)
  ) i_adder_inc (
    .operand_a_i(pc       ),
    .operand_b_i(Width'(4)),
    .subtract_i (1'b0     ),
    .result_o   (pc_inc   )
  );

endmodule
