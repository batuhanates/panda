// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_id_stage (
  input  logic                     clk_i,
  input  logic                     rst_ni,

  input  logic [31:0]              instr_i,

  input  logic [31:0]              rd_data_i,
  input  logic [ 4:0]              rd_addr_i,
  input  logic                     rd_we_i,

  output panda_pkg::op_a_sel_e     op_a_sel_o,
  output panda_pkg::op_b_sel_e     op_b_sel_o,
  output panda_pkg::alu_operator_e alu_operator_o,

  output logic [31:0]              imm_o,
  output logic [31:0]              rs1_data_o,
  output logic [31:0]              rs2_data_o,

  output panda_pkg::rd_data_sel_e  rd_data_sel_o,
  output logic [ 4:0]              rd_addr_o,
  output logic                     rd_we_o,

  output logic                     lsu_store_o,
  output panda_pkg::lsu_width_e    lsu_width_o,
  output logic                     lsu_load_unsigned_o,

  output logic                     branch_o,
  output logic                     jump_o
);
  import panda_pkg::*;

  logic [4:0] rs1_addr;
  logic [4:0] rs2_addr;

  logic illegal_instr;

  panda_decoder i_decoder (
    .instr_i            (instr_i            ),
    .rs1_addr_o         (rs1_addr           ),
    .rs2_addr_o         (rs2_addr           ),
    .rd_addr_o          (rd_addr_o          ),
    .rd_we_o            (rd_we_o            ),
    .op_a_sel_o         (op_a_sel_o         ),
    .op_b_sel_o         (op_b_sel_o         ),
    .rd_data_sel_o      (rd_data_sel_o      ),
    .alu_operator_o     (alu_operator_o     ),
    .lsu_store_o        (lsu_store_o        ),
    .lsu_width_o        (lsu_width_o        ),
    .lsu_load_unsigned_o(lsu_load_unsigned_o),
    .branch_o           (branch_o           ),
    .jump_o             (jump_o             ),
    .imm_o              (imm_o              ),
    .illegal_instr_o    (illegal_instr      )
  );

  panda_register_file #(
    .Width(32),
    .Depth(32)
  ) i_register_file (
    .clk_i     (clk_i     ),
    .rst_ni    (rst_ni    ),
    .rs1_addr_i(rs1_addr  ),
    .rs1_data_o(rs1_data_o),
    .rs2_addr_i(rs2_addr  ),
    .rs2_data_o(rs2_data_o),
    .rd_addr_i (rd_addr_i ),
    .rd_data_i (rd_data_i ),
    .rd_we_i   (rd_we_i   )
  );

endmodule
