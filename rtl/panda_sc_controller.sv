// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_sc_controller (
  input  logic                     clk_i,
  input  logic                     rst_ni,
  // Register File
  output logic [ 4:0]              rs1_addr_o,          // AA
  output logic [ 4:0]              rs2_addr_o,          // BA
  output logic [ 4:0]              rd_addr_o,           // DA
  output logic                     rd_we_o,             // RW
  // Select
  output panda_pkg::op_a_sel_e     op_a_sel_o,          // MA
  output panda_pkg::op_b_sel_e     op_b_sel_o,          // MB
  output panda_pkg::rd_data_sel_e  rd_data_sel_o,       // MD
  output panda_pkg::alu_operator_e alu_operator_o,      // FS
  // Load-Store
  output logic                     lsu_store_o,         // LS
  output panda_pkg::lsu_width_e    lsu_width_o,         // WS
  output logic                     lsu_load_unsigned_o, // LU
  // Data to datapath
  output logic [31:0]              pc_o,
  output logic [31:0]              pc_inc_o,
  output logic [31:0]              imm_o,
  // Jump-Branch
  input  logic [31:0]              jump_target_i,
  input  logic                     branch_cond_i,
  // Instruction Memory
  input  logic [31:0]              instr_i
);
  import panda_pkg::*;

  logic [31:0] imm;
  logic [31:0] pc;
  logic [31:0] branch_target;

  logic branch;
  logic jump;

  assign imm_o = imm;
  assign pc_o  = pc;

  panda_pc #(
    .Width(32)
  ) i_pc (
    .clk_i          (clk_i                 ),
    .rst_ni         (rst_ni                ),
    .branch_i       (branch & branch_cond_i),
    .jump_i         (jump                  ),
    .branch_target_i(branch_target         ),
    .jump_target_i  (jump_target_i         ),
    .pc_o           (pc                    ),
    .pc_inc_o       (pc_inc_o              )
  );

  panda_adder #(
    .Width(32)
  ) i_adder_branch (
    .operand_a_i(pc           ),
    .operand_b_i(imm          ),
    .subtract_i (1'b0         ),
    .result_o   (branch_target)
  );

  panda_sc_id i_instruction_decoder (
    .instr_i            (instr_i            ),
    .rs1_addr_o         (rs1_addr_o         ),
    .rs2_addr_o         (rs2_addr_o         ),
    .rd_addr_o          (rd_addr_o          ),
    .rd_we_o            (rd_we_o            ),
    .op_a_sel_o         (op_a_sel_o         ),
    .op_b_sel_o         (op_b_sel_o         ),
    .rd_data_sel_o      (rd_data_sel_o      ),
    .alu_operator_o     (alu_operator_o     ),
    .lsu_store_o        (lsu_store_o        ),
    .lsu_width_o        (lsu_width_o        ),
    .lsu_load_unsigned_o(lsu_load_unsigned_o),
    .branch_o           (branch             ),
    .jump_o             (jump               ),
    .imm_o              (imm                )
  );

endmodule
