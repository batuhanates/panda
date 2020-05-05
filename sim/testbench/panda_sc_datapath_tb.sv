// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

`timescale 1ns/1ps

module panda_sc_datapath_tb ();
  import panda_pkg::*;

  logic          clk_i               = 1'b0;
  logic          rst_ni              = 1'b0;
  logic [ 4:0]   rs1_addr_i          = 0;
  logic [ 4:0]   rs2_addr_i          = 0;
  logic [ 4:0]   rd_addr_i           = 0;
  logic          rd_we_i             = 1'b0;
  op_a_sel_e     op_a_sel_i          = OP_A_RS1;
  op_b_sel_e     op_b_sel_i          = OP_B_RS2;
  rd_data_sel_e  rd_data_sel_i       = RD_DATA_ALU;
  alu_operator_e alu_operator_i      = ALU_ADD;
  logic          lsu_store_i         = 1'b0;
  lsu_width_e    lsu_width_i         = LSU_WIDTH_BYTE;
  logic          lsu_load_unsigned_i = 1'b0;
  logic [31:0]   data_rdata_i        = 0;
  logic [31:0]   data_wdata_o;
  logic [31:0]   data_addr_o;
  logic [ 3:0]   data_we_o;
  logic [31:0]   pc_i                = 0;
  logic [31:0]   pc_inc_i;
  logic [31:0]   imm_i               = 0;
  logic [31:0]   jump_target_o;
  logic          branch_cond_o;



  panda_sc_datapath dut (
    .clk_i              (clk_i              ),
    .rst_ni             (rst_ni             ),
    .rs1_addr_i         (rs1_addr_i         ),
    .rs2_addr_i         (rs2_addr_i         ),
    .rd_addr_i          (rd_addr_i          ),
    .rd_we_i            (rd_we_i            ),
    .op_a_sel_i         (op_a_sel_i         ),
    .op_b_sel_i         (op_b_sel_i         ),
    .rd_data_sel_i      (rd_data_sel_i      ),
    .alu_operator_i     (alu_operator_i     ),
    .lsu_store_i        (lsu_store_i        ),
    .lsu_width_i        (lsu_width_i        ),
    .lsu_load_unsigned_i(lsu_load_unsigned_i),
    .data_rdata_i       (data_rdata_i       ),
    .data_wdata_o       (data_wdata_o       ),
    .data_addr_o        (data_addr_o        ),
    .data_we_o          (data_we_o          ),
    .pc_i               (pc_i               ),
    .pc_inc_i           (pc_inc_i           ),
    .imm_i              (imm_i              ),
    .jump_target_o      (jump_target_o      ),
    .branch_cond_o      (branch_cond_o      )
  );

  always #5 clk_i = ~clk_i;

  // increment pc (ignore branch and jumps)
  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_pc
    if(~rst_ni) begin
      pc_i <= 0;
    end else begin
      pc_i <= pc_inc_i;
    end
  end

  assign pc_inc_i = pc_i + 4;

  initial begin : proc_stim
    #10 rst_ni = 1'b1;
    // ADDI x1, x0, 10
    rd_addr_i = 1; rd_we_i = 1'b1; imm_i = 10; op_b_sel_i = OP_B_IMM;
    // ADDI x2, x0, 15
    #10 rd_addr_i = 2; imm_i = 15;
    // JAL x3, 12
    #10 rd_addr_i = 3; rd_data_sel_i = RD_DATA_PC_INC;
    op_a_sel_i = OP_A_PC; imm_i = 12;
    // ADDI x4, x1, 24
    #10 rd_addr_i = 4; op_a_sel_i = OP_A_RS1; rs1_addr_i = 1; imm_i = 24;
    // BGE x4, x3, 24
    #10 rd_we_i = 1'b0; rs1_addr_i = 4; rs2_addr_i = 3;
    op_b_sel_i = OP_B_RS2; alu_operator_i = ALU_GE;
    // BLT x4, x3, 24
    #10 alu_operator_i = ALU_LT;
    // SW x0, x1, 16
    #10 rs1_addr_i = 0; rs2_addr_i = 1; op_b_sel_i = OP_B_IMM; imm_i = 16;
    lsu_store_i = 1'b1; lsu_width_i = LSU_WIDTH_WORD;
    alu_operator_i = ALU_ADD;
    // SH x0, x1, 20
    #10 imm_i = 20; lsu_width_i = LSU_WIDTH_HALF;
    // SH x0, x1, 22
    #10 imm_i = 22;
    // LH x5, x0, 12
    #10 rd_we_i = 1'b1; rd_addr_i = 5; lsu_store_i = 1'b0; imm_i = 12;
    rd_data_sel_i = RD_DATA_LOAD; data_rdata_i = 32'hABCDEF78;
    // LHU x6, x0, 12
    #10 rd_addr_i = 6; lsu_load_unsigned_i = 1'b1;
    // LUI x7, 0xABCDE000
    #10 rd_addr_i = 7; imm_i = 32'hABCDE000; rd_data_sel_i = RD_DATA_IMM;
    #15 $finish;
  end

endmodule
