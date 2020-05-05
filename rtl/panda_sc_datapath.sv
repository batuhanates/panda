// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_sc_datapath (
  input  logic                     clk_i,
  input  logic                     rst_ni,
  // Register File
  input  logic [ 4:0]              rs1_addr_i,          // AA
  input  logic [ 4:0]              rs2_addr_i,          // BA
  input  logic [ 4:0]              rd_addr_i,           // DA
  input  logic                     rd_we_i,             // RW
  // Select
  input  panda_pkg::op_a_sel_e     op_a_sel_i,          // MA
  input  panda_pkg::op_b_sel_e     op_b_sel_i,          // MB
  input  panda_pkg::rd_data_sel_e  rd_data_sel_i,       // MD
  input  panda_pkg::alu_operator_e alu_operator_i,      // FS
  // Load-Store
  input  logic                     lsu_store_i,         // LS
  input  panda_pkg::lsu_width_e    lsu_width_i,         // WS
  input  logic                     lsu_load_unsigned_i, // LU
  // Data memory interface
  input  logic [31:0]              data_rdata_i,        // data in
  output logic [31:0]              data_wdata_o,        // data out
  output logic [31:0]              data_addr_o,         // address out
  output logic [ 3:0]              data_we_o,           // MW
  // Data from controller
  input  logic [31:0]              pc_i,
  input  logic [31:0]              pc_inc_i,
  input  logic [31:0]              imm_i,
  // Jump-Branch
  output logic [31:0]              jump_target_o,
  output logic                     branch_cond_o
);
  import panda_pkg::*;

  // Register File signals
  logic [31:0] rs1_data;
  logic [31:0] rs2_data;
  logic [31:0] rd_data;
  // ALU signals
  logic [31:0] alu_operand_a;
  logic [31:0] alu_operand_b;
  logic [31:0] alu_result;
  // Load-Store Unit signals
  logic [31:0] load_data;
  logic [31:0] store_data;
  logic [31:0] lsu_addr;

  assign jump_target_o = {alu_result[31:1], 1'b0};
  assign branch_cond_o = alu_result[0];

  always_comb begin : proc_rd_data_mux
    unique case (rd_data_sel_i)
      RD_DATA_ALU    : rd_data = alu_result;
      RD_DATA_LOAD   : rd_data = load_data;
      RD_DATA_PC_INC : rd_data = pc_inc_i;
      RD_DATA_IMM    : rd_data = imm_i;
      default        : rd_data = alu_result;
    endcase
  end

  panda_register_file #(
    .Width(32),
    .Depth(32)
  ) i_register_file (
    .clk_i     (clk_i     ),
    .rst_ni    (rst_ni    ),
    .rs1_addr_i(rs1_addr_i),
    .rs1_data_o(rs1_data  ),
    .rs2_addr_i(rs2_addr_i),
    .rs2_data_o(rs2_data  ),
    .rd_addr_i (rd_addr_i ),
    .rd_data_i (rd_data   ),
    .rd_we_i   (rd_we_i   )
  );

  always_comb begin : proc_op_mux
    unique case (op_a_sel_i)
      OP_A_RS1 : alu_operand_a = rs1_data;
      OP_A_PC  : alu_operand_a = pc_i;
      default  : alu_operand_a = rs1_data;
    endcase

    unique case (op_b_sel_i)
      OP_B_RS2 : alu_operand_b = rs2_data;
      OP_B_IMM : alu_operand_b = imm_i;
      default  : alu_operand_b = rs2_data;
    endcase
  end

  panda_alu #(
    .Width(32)
  ) i_alu (
    .operator_i (alu_operator_i),
    .operand_a_i(alu_operand_a ),
    .operand_b_i(alu_operand_b ),
    .result_o   (alu_result    )
  );

  assign store_data = rs2_data;
  assign lsu_addr   = alu_result;

  panda_sc_load_store_unit i_load_store_unit (
    .store_i        (lsu_store_i        ),
    .load_unsigned_i(lsu_load_unsigned_i),
    .width_i        (lsu_width_i        ),
    .addr_i         (lsu_addr           ),
    .store_data_i   (store_data         ),
    .load_data_o    (load_data          ),
    .data_rdata_i   (data_rdata_i       ),
    .data_wdata_o   (data_wdata_o       ),
    .data_addr_o    (data_addr_o        ),
    .data_we_o      (data_we_o          )
  );

endmodule
