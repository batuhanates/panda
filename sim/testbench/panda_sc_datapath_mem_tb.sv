// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

`timescale 1ns/1ps

module panda_sc_datapath_mem_tb ();
  import panda_pkg::*;

  parameter unsigned DataMemDepth = 64;
  parameter unsigned DataMemInitFile = "ram_test.mem";

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
  logic [31:0]   pc_i                = 0;
  logic [31:0]   pc_inc_i;
  logic [31:0]   imm_i               = 0;
  logic [31:0]   jump_target_o;
  logic          branch_cond_o;

  panda_sc_datapath_mem #(
    .DataMemDepth   (DataMemDepth   ),
    .DataMemInitFile(DataMemInitFile)
  ) dut (
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
    .pc_i               (pc_i               ),
    .pc_inc_i           (pc_inc_i           ),
    .imm_i              (imm_i              ),
    .jump_target_o      (jump_target_o      ),
    .branch_cond_o      (branch_cond_o      )
  );

  always #5 clk_i = ~clk_i;

  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_pc
    if(~rst_ni) begin
      pc_i <= 0;
    end else begin
      pc_i <= pc_inc_i;
    end
  end

  assign pc_inc_i = pc_i + 4;

  initial begin : proc_stim
    #10 rst_ni = 1'b1; rd_addr_i = 1; rd_we_i = 1'b1;
    op_b_sel_i = OP_B_IMM; imm_i = 32'hABCDEF78;
    #10 rd_addr_i = 2; imm_i = 32'h1234DEAD;
    // load word from mem 8 to x3
    #10 rd_addr_i = 3; rs1_addr_i = 0; rd_data_sel_i = RD_DATA_LOAD; imm_i = 8;
    lsu_width_i = LSU_WIDTH_WORD; lsu_load_unsigned_i = 1'b0;
    // load half from mem 8 to x4
    #10 rd_addr_i = 4; lsu_width_i = LSU_WIDTH_HALF;
    // load unsigned half from mem 8 to x5
    #10 rd_addr_i = 5; lsu_load_unsigned_i = LSU_WIDTH_HALF;
    // load byte from mem 8 to x6
    #10 rd_addr_i = 6; lsu_width_i = LSU_WIDTH_BYTE;
    lsu_load_unsigned_i = 1'b0;
    // load unsigned byte from mem 8 to x7
    #10 rd_addr_i = 7; lsu_load_unsigned_i = 1'b1;
    // load unsigned half from mem 18 to x8 (2 aligned read)
    #10 rd_addr_i = 8; imm_i = 18; lsu_width_i = LSU_WIDTH_HALF;
    // load half from mem 18 to x9 (2 aligned read)
    #10 rd_addr_i = 9; lsu_load_unsigned_i = 1'b0;

    // store word from x1 to mem 0
    #10 rd_we_i = 1'b0; rs2_addr_i = 1; lsu_store_i = 1'b1; imm_i = 0;
    lsu_width_i = LSU_WIDTH_WORD;
    // store half from x1 to mem 4
    #10 imm_i = 4; lsu_width_i = LSU_WIDTH_HALF;
    // store half from x2 to mem 6 (2 aligned write)
    #10 rs2_addr_i = 2; imm_i = 6;
    // store byte from x2 to mem 9 (1 aligned write)
    #10 imm_i = 9; lsu_width_i = LSU_WIDTH_BYTE;
    #15 $finish;
  end

endmodule
