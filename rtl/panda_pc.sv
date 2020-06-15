// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_pc #(
  parameter int unsigned Width = 32
) (
  input  logic             clk_i,
  input  logic             rst_ni,
  input  logic             stall_i,

  input  logic             change_flow_i,
  input  logic [Width-1:0] target_address_i,
  output logic [Width-1:0] pc_o,
  output logic [Width-1:0] pc_inc_o
);

  logic [Width-1:0] pc;
  logic [Width-1:0] pc_tmp;
  logic [Width-1:0] pc_inc;

  assign pc_o     = pc_tmp;
  assign pc_inc_o = pc_inc;

  assign pc_tmp = change_flow_i ? target_address_i : pc;

  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_pc
    if(~rst_ni) begin
      pc <= 0;
    end else if (~stall_i) begin
      pc <= pc_inc;
    end
  end

  panda_adder #(
    .Width(Width)
  ) i_adder_inc (
    .operand_a_i(pc_tmp   ),
    .operand_b_i(Width'(4)),
    .subtract_i (1'b0     ),
    .result_o   (pc_inc   )
  );

endmodule
