// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_if_stage (
  input  logic              clk_i,
  input  logic              rst_ni,
  input  logic              stall_i,
  input  logic              flush_i,

  output panda_pkg::if_id_t if_id_o,

  input  logic [31:0]       instr_rdata_i,
  output logic [31:0]       instr_addr_o,

  input  logic              change_flow_i,
  input  logic [31:0]       jb_address_i
);
  import panda_pkg::*;

  logic [31:0] pc;
  logic [31:0] pc_inc;

  panda_pc #(
    .Width(32)
  ) i_pc (
    .clk_i           (clk_i            ),
    .rst_ni          (rst_ni           ),
    .stall_i         (stall_i | flush_i),
    .change_flow_i   (change_flow_i    ),
    .target_address_i(jb_address_i     ),
    .pc_o            (pc               ),
    .pc_inc_o        (pc_inc           )
  );

  // Stall has priority over flush. If they are both asserted in the same cycle,
  // the registers will keep their values and will NOT be flushed.
  // For flushing 32'h13 is put as instruction instead of completely reseting in
  // order to avoid putting an intruction with an illegal opcode.
  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_if_id
    if(~rst_ni) begin
      if_id_o.instr  <= 0;
      if_id_o.pc     <= 0;
      if_id_o.pc_inc <= 0;
    end else if (~stall_i) begin
      if_id_o.instr  <= flush_i ? 32'h13 : instr_rdata_i; // Put NOP for flush
      if_id_o.pc     <= flush_i ? 0 : pc;
      if_id_o.pc_inc <= flush_i ? 0 : pc_inc;
    end
  end

  assign instr_addr_o = pc;

endmodule
