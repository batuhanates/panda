// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_ex_stage (
  input  logic [31:0]              pc_i,

  input  panda_pkg::op_a_sel_e     op_a_sel_i,
  input  panda_pkg::op_b_sel_e     op_b_sel_i,
  input  panda_pkg::alu_operator_e alu_operator_i,

  input  logic [31:0]              imm_i,
  input  logic [31:0]              rs1_data_i,
  input  logic [31:0]              rs2_data_i,

  output logic [31:0]              alu_result_o,
  output logic [31:0]              jump_target_o,
  output logic [31:0]              branc_target_o,
  output logic                     branch_cond_o
);
  import panda_pkg::*;

  logic [31:0] alu_operand_a;
  logic [31:0] alu_operand_b;

  always_comb begin : proc_alu_operands
    unique case (op_a_sel_i)
      OP_A_RS1 : alu_operand_a = rs1_data_i;
      OP_A_PC  : alu_operand_a = pc_i;
      default  : alu_operand_a = rs1_data_i;
    endcase

    unique case (op_b_sel_i)
      OP_B_RS2 : alu_operand_b = rs2_data_i;
      OP_B_IMM : alu_operand_b = imm_i;
      default  : alu_operand_b = rs2_data_i;
    endcase
  end

  panda_alu #(
    .Width(32)
  ) i_alu (
    .operator_i   (alu_operator_i),
    .operand_a_i  (alu_operand_a ),
    .operand_b_i  (alu_operand_b ),
    .result_o     (alu_result_o  ),
    .jump_target_o(jump_target_o ),
    .branch_cond_o(branch_cond_o )
  );

  panda_adder #(
    .Width(32)
  ) i_adder_branch (
    .operand_a_i(pc_i          ),
    .operand_b_i(imm_i         ),
    .subtract_i (1'b0          ),
    .result_o   (branc_target_o)
  );

endmodule
