// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_if_stage (
  input  logic        clk_i,
  input  logic        rst_ni,

  input  logic [31:0] instr_rdata_i,
  output logic [31:0] instr_addr_o,

  input  logic        branch_i,
  input  logic        jump_i,
  input  logic [31:0] branch_target_i,
  input  logic [31:0] jump_target_i,

  output logic [31:0] instr_o,
  output logic [31:0] pc_o,
  output logic [31:0] pc_inc_o
);

  logic [31:0] pc;

  panda_pc #(
    .Width(32)
  ) i_pc (
    .clk_i          (clk_i          ),
    .rst_ni         (rst_ni         ),
    .branch_i       (branch_i       ),
    .jump_i         (jump_i         ),
    .branch_target_i(branch_target_i),
    .jump_target_i  (jump_target_i  ),
    .pc_o           (pc             ),
    .pc_inc_o       (pc_inc_o       )
  );

  assign instr_o      = instr_rdata_i;
  assign instr_addr_o = pc;
  assign pc_o         = pc;

endmodule
