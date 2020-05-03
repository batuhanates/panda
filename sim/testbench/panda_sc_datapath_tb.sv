// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

`timescale 1ns/1ps

module panda_sc_datapath_tb ();
  import panda_pkg::*;

  logic        clk_i              = 1'b0;
  logic        rst_ni             = 1'b0;
  logic [ 4:0] rs1_addr_i         = 0;
  logic [ 4:0] rs2_addr_i         = 0;
  logic [ 4:0] rd_addr_i          = 0;
  logic        rd_we_i            = 1'b0;
  logic        sel_operand_a_i    = 1'b0;
  logic        sel_operand_b_i    = 1'b0;
  logic [ 1:0] sel_rd_data_i      = 2'b0;
  logic        load_store_i       = 1'b0;
  logic [ 1:0] load_store_width_i = 2'b0;
  logic        load_unsigned_i    = 1'b0;
  logic [31:0] data_rdata_i       = 0;
  logic [31:0] data_wdata_o;
  logic [31:0] data_addr_o;
  logic [ 3:0] data_we_o;
  logic [31:0] pc_i               = 0;
  logic [31:0] pc_next_i;
  logic [31:0] imm_i              = 0;
  logic [31:0] jump_target_o;
  logic        branch_cond_o;

  alu_operator_e alu_operator_i = ALU_ADD;

  panda_sc_datapath dut (
    .clk_i             (clk_i             ),
    .rst_ni            (rst_ni            ),
    .rs1_addr_i        (rs1_addr_i        ),
    .rs2_addr_i        (rs2_addr_i        ),
    .rd_addr_i         (rd_addr_i         ),
    .rd_we_i           (rd_we_i           ),
    .sel_operand_a_i   (sel_operand_a_i   ),
    .sel_operand_b_i   (sel_operand_b_i   ),
    .sel_rd_data_i     (sel_rd_data_i     ),
    .alu_operator_i    (alu_operator_i    ),
    .load_store_i      (load_store_i      ),
    .load_store_width_i(load_store_width_i),
    .load_unsigned_i   (load_unsigned_i   ),
    .data_rdata_i      (data_rdata_i      ),
    .data_wdata_o      (data_wdata_o      ),
    .data_addr_o       (data_addr_o       ),
    .data_we_o         (data_we_o         ),
    .pc_i              (pc_i              ),
    .pc_next_i         (pc_next_i         ),
    .imm_i             (imm_i             ),
    .jump_target_o     (jump_target_o     ),
    .branch_cond_o     (branch_cond_o     )
  );

  always #5 clk_i = ~clk_i;

  // increment pc (ignore branch and jumps)
  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_pc
    if(~rst_ni) begin
      pc_i <= 0;
    end else begin
      pc_i <= pc_next_i;
    end
  end

  assign pc_next_i = pc_i + 4;

  initial begin : proc_stim
    #10 rst_ni = 1'b1;
    // ADDI x1, x0, 10
    rd_addr_i = 1; rd_we_i = 1'b1; imm_i = 10; sel_operand_b_i = 1'b1;
    // ADDI x2, x0, 15
    #10 rd_addr_i = 2; imm_i = 15;
    // JAL x3, 12
    #10 rd_addr_i = 3; sel_rd_data_i = 2'b10;
    sel_operand_a_i = 1'b1; sel_operand_b_i = 1'b1; imm_i = 12;
    // ADDI x4, x1, 24
    #10 rd_addr_i = 4; sel_operand_a_i = 1'b0; rs1_addr_i = 1; imm_i = 24;
    // BGE x4, x3, 24
    #10 rd_we_i = 1'b0; rs1_addr_i = 4; rs2_addr_i = 3;
    sel_operand_a_i = 1'b0; sel_operand_b_i = 1'b0; alu_operator_i = ALU_GE;
    // BLT x4, x3, 24
    #10 alu_operator_i = ALU_LT;
    // SW x0, x1, 16
    #10 rs1_addr_i = 0; rs2_addr_i = 1; sel_operand_b_i = 1'b1; imm_i = 16;
    load_store_i = 1'b1; load_store_width_i = 2'b10; alu_operator_i = ALU_ADD;
    // SH x0, x1, 20
    #10 imm_i = 20; load_store_width_i = 2'b01;
    // SH x0, x1, 22
    #10 imm_i = 22;
    // LH x5, x0, 12
    #10 rd_we_i = 1'b1; rd_addr_i = 5; load_store_i = 1'b0; imm_i = 12;
    sel_rd_data_i = 2'b01; data_rdata_i = 32'hABCDEF78;
    // LHU x6, x0, 12
    #10 rd_addr_i = 6; load_unsigned_i = 1'b1;
    #10 $finish;
  end

endmodule
