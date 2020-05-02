// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

`timescale 1ns/1ps

module panda_sc_datapath_mem_tb ();
  import panda_pkg::*;

  parameter unsigned DataMemDepth = 32;
  parameter unsigned DataMemInitFile = "ram_test.mem";

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
  logic [31:0] pc_i               = 0;
  logic [31:0] pc_next_i;
  logic [31:0] imm_i              = 0;
  logic [31:0] jump_target_o;
  logic        branch_cond_o;

  panda_pkg::alu_operator_e alu_operator_i = ALU_ADD;

  panda_sc_datapath_mem #(
    .DataMemDepth   (DataMemDepth   ),
    .DataMemInitFile(DataMemInitFile)
  ) dut (
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
    .pc_i              (pc_i              ),
    .pc_next_i         (pc_next_i         ),
    .imm_i             (imm_i             ),
    .jump_target_o     (jump_target_o     ),
    .branch_cond_o     (branch_cond_o     )
  );

  always #5 clk_i = ~clk_i;

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
    rd_addr_i = 1; rd_we_i = 1'b1; sel_operand_b_i = 1'b1; imm_i = 32'hABCDEF78;
    #10 rd_addr_i = 2; imm_i = 32'h1234DEAD;
    // load word from mem 8 to x3
    #10 rd_addr_i = 3; rs1_addr_i = 0; sel_rd_data_i = 2'b01; imm_i = 8;
    load_store_width_i = 2'b10; load_unsigned_i = 1'b0;
    // load half from mem 8 to x4
    #10 rd_addr_i = 4; load_store_width_i = 2'b01;
    // load unsigned half from mem 8 to x5
    #10 rd_addr_i = 5; load_unsigned_i = 1'b1;
    // load byte from mem 8 to x6
    #10 rd_addr_i = 6; load_store_width_i = 2'b00; load_unsigned_i = 1'b0;
    // load unsigned byte from mem 8 to x7
    #10 rd_addr_i = 7; load_unsigned_i = 1'b1;
    // load unsigned half from mem 18 to x8 (2 aligned read)
    #10 rd_addr_i = 8; imm_i = 18; load_store_width_i = 2'b01;
    // load half from mem 18 to x9 (2 aligned read)
    #10 rd_addr_i = 9; load_unsigned_i = 1'b0;

    // store word from x1 to mem 0
    #10 rd_we_i = 1'b0; rs2_addr_i = 1; load_store_i = 1'b1; imm_i = 0;
    load_store_width_i = 2'b10;
    // store half from x1 to mem 4
    #10 imm_i = 4; load_store_width_i = 2'b01;
    // store half from x2 to mem 6 (2 aligned write)
    #10 rs2_addr_i = 2; imm_i = 6;
    // store byte from x2 to mem 9 (1 aligned write)
    #10 imm_i = 9; load_store_width_i = 2'b00;
    #20 $finish;
  end

endmodule
