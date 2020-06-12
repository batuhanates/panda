// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_id_stage (
  input  logic              clk_i,
  input  logic              rst_ni,

  input  panda_pkg::if_id_t if_id_i,
  output panda_pkg::id_ex_t id_ex_o,

  input  logic [31:0]       rd_data_i,
  input  logic [ 4:0]       rd_addr_i,
  input  logic              rd_we_i
);
  import panda_pkg::*;

  op_a_sel_e     op_a_sel;
  op_b_sel_e     op_b_sel;
  alu_operator_e alu_operator;
  logic [ 4:0]   rs1_addr;
  logic [ 4:0]   rs2_addr;
  logic [31:0]   rs1_data;
  logic [31:0]   rs2_data;
  logic [31:0]   imm;
  rd_data_sel_e  rd_data_sel;
  logic [ 4:0]   rd_addr;
  logic          rd_we;
  logic          lsu_store;
  lsu_width_e    lsu_width;
  logic          lsu_load_unsigned;
  logic          branch;
  logic          jump;

  logic illegal_instr;

  panda_decoder i_decoder (
    .instr_i            (if_id_i.instr    ),
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
    .branch_o           (branch           ),
    .jump_o             (jump             ),
    .imm_o              (imm              ),
    .illegal_instr_o    (illegal_instr    )
  );

  panda_register_file #(
    .Width(32),
    .Depth(32)
  ) i_register_file (
    .clk_i     (clk_i    ),
    .rst_ni    (rst_ni   ),
    .rs1_addr_i(rs1_addr ),
    .rs1_data_o(rs1_data ),
    .rs2_addr_i(rs2_addr ),
    .rs2_data_o(rs2_data ),
    .rd_addr_i (rd_addr_i),
    .rd_data_i (rd_data_i),
    .rd_we_i   (rd_we_i  )
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_id_ex
    if(~rst_ni) begin
      id_ex_o.op_a_sel          <= op_a_sel_e'(0);
      id_ex_o.op_b_sel          <= op_b_sel_e'(0);
      id_ex_o.alu_operator      <= alu_operator_e'(0);
      id_ex_o.rs1_data          <= 0;
      id_ex_o.rs2_data          <= 0;
      id_ex_o.rs2_addr          <= 0;
      id_ex_o.imm               <= 0;
      id_ex_o.rd_data_sel       <= rd_data_sel_e'(0);
      id_ex_o.rd_addr           <= 0;
      id_ex_o.rd_we             <= 0;
      id_ex_o.lsu_store         <= 0;
      id_ex_o.lsu_width         <= lsu_width_e'(0);
      id_ex_o.lsu_load_unsigned <= 0;
      id_ex_o.branch            <= 0;
      id_ex_o.jump              <= 0;
      id_ex_o.pc                <= 0;
      id_ex_o.pc_inc            <= 0;
    end else begin
      id_ex_o.op_a_sel          <= op_a_sel;
      id_ex_o.op_b_sel          <= op_b_sel;
      id_ex_o.alu_operator      <= alu_operator;
      id_ex_o.rs1_data          <= rs1_data;
      id_ex_o.rs2_data          <= rs2_data;
      id_ex_o.rs2_addr          <= rs2_addr;
      id_ex_o.imm               <= imm;
      id_ex_o.rd_data_sel       <= rd_data_sel;
      id_ex_o.rd_addr           <= rd_addr;
      id_ex_o.rd_we             <= rd_we;
      id_ex_o.lsu_store         <= lsu_store;
      id_ex_o.lsu_width         <= lsu_width;
      id_ex_o.lsu_load_unsigned <= lsu_load_unsigned;
      id_ex_o.branch            <= branch;
      id_ex_o.jump              <= jump;
      id_ex_o.pc                <= if_id_i.pc;
      id_ex_o.pc_inc            <= if_id_i.pc_inc;
    end
  end

endmodule
