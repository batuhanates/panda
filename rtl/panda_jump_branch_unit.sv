// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_jump_branch_unit (
  input  logic [31:0] rs1_data_i,
  input  logic [31:0] rs2_data_i,
  input  logic [31:0] imm_i,
  input  logic [31:0] pc_i,

  input  logic        jal_i,
  input  logic        jalr_i,
  input  logic        branch_i,
  input  logic        br_not_i,
  input  logic        br_unsigned_i,
  input  logic        br_lt_i,

  output logic [31:0] target_address_o,
  output logic        change_flow_o
);

  logic is_equal;
  logic is_less;
  logic br_cond;

  logic [31:0] sub_result;
  logic [31:0] address_operand;
  logic [31:0] target_address_tmp;

  assign br_cond       = (br_lt_i ? is_less : is_equal) ^ br_not_i;
  assign change_flow_o = jal_i | jalr_i | (branch_i & br_cond);

  assign address_operand  = jalr_i ? rs1_data_i : pc_i;
  assign target_address_o = {target_address_tmp[31:1], 1'b0};

  panda_adder #(
    .Width(32)
  ) i_subtractor (
    .operand_a_i(rs1_data_i),
    .operand_b_i(rs2_data_i),
    .subtract_i (1'b1      ),
    .result_o   (sub_result)
  );

  panda_comparator_sub #(
    .Width(32)
  ) i_comparator (
    .sub_result_i(sub_result    ),
    .msb_a_i     (rs1_data_i[31]),
    .msb_b_i     (rs2_data_i[31]),
    .sign_i      (~br_unsigned_i),
    .is_equal_o  (is_equal      ),
    .is_less_o   (is_less       )
  );

  panda_adder #(
    .Width(32)
  ) i_address_adder (
    .operand_a_i(address_operand   ),
    .operand_b_i(imm_i             ),
    .subtract_i (1'b0              ),
    .result_o   (target_address_tmp)
  );

endmodule
