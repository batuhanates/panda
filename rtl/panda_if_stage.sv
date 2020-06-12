// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_if_stage (
  input  logic              clk_i,
  input  logic              rst_ni,

  output panda_pkg::if_id_t if_id_o,

  input  logic [31:0]       instr_rdata_i,
  output logic [31:0]       instr_addr_o,

  input  logic              branch_i,
  input  logic              jump_i,
  input  logic [31:0]       branch_target_i,
  input  logic [31:0]       jump_target_i
);
  import panda_pkg::*;

  logic [31:0] pc;
  logic [31:0] pc_inc;

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
    .pc_inc_o       (pc_inc         )
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_if_id
    if(~rst_ni) begin
      if_id_o.instr  <= 0;
      if_id_o.pc     <= 0;
      if_id_o.pc_inc <= 0;
    end else begin
      if_id_o.instr  <= instr_rdata_i;
      if_id_o.pc     <= pc;
      if_id_o.pc_inc <= pc_inc;
    end
  end

  assign instr_addr_o = pc;

endmodule
