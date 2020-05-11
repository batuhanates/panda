// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_sc_core #(
  parameter int unsigned InstrMemDepth    = 32,
  parameter              InstrMemInitFile = ""
) (
  input  logic        clk_i,
  input  logic        rst_ni,

  input  logic [31:0] data_rdata_i,
  output logic [31:0] data_wdata_o,
  output logic [31:0] data_addr_o,
  output logic [ 3:0] data_we_o
);
  import panda_pkg::*;

  logic [ 4:0]   rs1_addr;
  logic [ 4:0]   rs2_addr;
  logic [ 4:0]   rd_addr;
  logic          rd_we;
  op_a_sel_e     op_a_sel;
  op_b_sel_e     op_b_sel;
  rd_data_sel_e  rd_data_sel;
  alu_operator_e alu_operator;
  logic          lsu_store;
  lsu_width_e    lsu_width;
  logic          lsu_load_unsigned;
  logic [31:0]   pc;
  logic [31:0]   pc_inc;
  logic [31:0]   imm;
  logic [31:0]   jump_target;
  logic          branch_cond;

  panda_sc_controller #(
    .InstrMemDepth   (InstrMemDepth   ),
    .InstrMemInitFile(InstrMemInitFile)
  ) i_controller (
    .clk_i              (clk_i            ),
    .rst_ni             (rst_ni           ),
    .rs1_addr_o         (rs1_addr         ),
    .rs2_addr_o         (rs2_addr         ),
    .rd_addr_o          (rd_addr          ),
    .rd_we_o            (rd_we            ),
    .op_a_sel_o         (op_a_sel         ),
    .op_b_sel_o         (op_b_sel         ),
    .rd_data_sel_o      (rd_data_sel      ),
    .alu_operator_o     (alu_operator     ),
    .lsu_store_o        (lsu_store        ),
    .lsu_width_o        (lsu_width        ),
    .lsu_load_unsigned_o(lsu_load_unsigned),
    .pc_o               (pc               ),
    .pc_inc_o           (pc_inc           ),
    .imm_o              (imm              ),
    .jump_target_i      (jump_target      ),
    .branch_cond_i      (branch_cond      )
  );

  panda_sc_datapath i_datapath (
    .clk_i              (clk_i            ),
    .rst_ni             (rst_ni           ),
    .rs1_addr_i         (rs1_addr         ),
    .rs2_addr_i         (rs2_addr         ),
    .rd_addr_i          (rd_addr          ),
    .rd_we_i            (rd_we            ),
    .op_a_sel_i         (op_a_sel         ),
    .op_b_sel_i         (op_b_sel         ),
    .rd_data_sel_i      (rd_data_sel      ),
    .alu_operator_i     (alu_operator     ),
    .lsu_store_i        (lsu_store        ),
    .lsu_width_i        (lsu_width        ),
    .lsu_load_unsigned_i(lsu_load_unsigned),
    .data_rdata_i       (data_rdata_i     ),
    .data_wdata_o       (data_wdata_o     ),
    .data_addr_o        (data_addr_o      ),
    .data_we_o          (data_we_o        ),
    .pc_i               (pc               ),
    .pc_inc_i           (pc_inc           ),
    .imm_i              (imm              ),
    .jump_target_o      (jump_target      ),
    .branch_cond_o      (branch_cond      )
  );

endmodule
