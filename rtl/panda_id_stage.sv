// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_id_stage (
  input  logic                    clk_i,
  input  logic                    rst_ni,

  input  panda_pkg::if_id_t       if_id_i,
  output panda_pkg::id_ex_t       id_ex_o,

  input  logic [31:0]             rd_data_i,
  input  logic [ 4:0]             rd_addr_i,
  input  logic                    rd_we_i,

  // Inputs for hazard detection
  input  panda_pkg::rd_data_sel_e ex_mem_rd_data_sel_i,
  input  logic [ 4:0]             ex_mem_rd_addr_i,
  input  logic                    ex_mem_rd_we_i,
  // Input for forwarding
  input  logic [31:0]             rd_data_ex_i,

  output logic                    stall_if_o,
  output logic                    flush_if_o
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

  logic jal;
  logic jalr;
  logic branch;
  logic br_not;
  logic br_unsigned;
  logic br_lt;
  logic change_flow;

  logic [31:0] jb_address;

  logic forward_rs1;
  logic forward_rs2;

  logic [31:0] rs1_data_tmp;
  logic [31:0] rs2_data_tmp;

  logic bubble_id;

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
    .imm_o              (imm              ),
    .jal_o              (jal              ),
    .jalr_o             (jalr             ),
    .branch_o           (branch           ),
    .br_not_o           (br_not           ),
    .br_unsigned_o      (br_unsigned      ),
    .br_lt_o            (br_lt            ),
    .illegal_instr_o    (illegal_instr    )
  );

  panda_register_file #(
    .Width(32),
    .Depth(32)
  ) i_register_file (
    .clk_i     (clk_i       ),
    .rst_ni    (rst_ni      ),
    .rs1_addr_i(rs1_addr    ),
    .rs1_data_o(rs1_data_tmp),
    .rs2_addr_i(rs2_addr    ),
    .rs2_data_o(rs2_data_tmp),
    .rd_addr_i (rd_addr_i   ),
    .rd_data_i (rd_data_i   ),
    .rd_we_i   (rd_we_i     )
  );

  panda_jump_branch_unit i_jump_branch_unit (
    .rs1_data_i      (rs1_data   ),
    .rs2_data_i      (rs2_data   ),
    .imm_i           (imm        ),
    .pc_i            (if_id_i.pc ),
    .jal_i           (jal        ),
    .jalr_i          (jalr       ),
    .branch_i        (branch     ),
    .br_not_i        (br_not     ),
    .br_unsigned_i   (br_unsigned),
    .br_lt_i         (br_lt      ),
    .target_address_o(jb_address ),
    .change_flow_o   (change_flow)
  );

  panda_forward_id i_forward_id (
    .branch_i            (branch              ),
    .jalr_i              (jalr                ),
    .rs1_addr_i          (rs1_addr            ),
    .rs2_addr_i          (rs2_addr            ),
    .ex_mem_rd_data_sel_i(ex_mem_rd_data_sel_i),
    .ex_mem_rd_addr_i    (ex_mem_rd_addr_i    ),
    .ex_mem_rd_we_i      (ex_mem_rd_we_i      ),
    .forward_rs1_o       (forward_rs1         ),
    .forward_rs2_o       (forward_rs2         )
  );

  // MUXs for forwarding from EX/MEM
  assign rs1_data = forward_rs1 ? rd_data_ex_i : rs1_data_tmp;
  assign rs2_data = forward_rs2 ? rd_data_ex_i : rs2_data_tmp;

  panda_controller i_controller (
    .id_ex_rd_data_sel_i (id_ex_o.rd_data_sel ),
    .id_ex_rd_addr_i     (id_ex_o.rd_addr     ),
    .id_ex_rd_we_i       (id_ex_o.rd_we       ),
    .ex_mem_rd_data_sel_i(ex_mem_rd_data_sel_i),
    .ex_mem_rd_addr_i    (ex_mem_rd_addr_i    ),
    .op_a_sel_i          (op_a_sel            ),
    .op_b_sel_i          (op_b_sel            ),
    .branch_i            (branch              ),
    .jalr_i              (jalr                ),
    .rs1_addr_i          (rs1_addr            ),
    .rs2_addr_i          (rs2_addr            ),
    .bubble_id_o         (bubble_id           )
  );

  assign stall_if_o = bubble_id;
  assign flush_if_o = change_flow;

  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_id_ex
    if(~rst_ni | bubble_id) begin
      id_ex_o.op_a_sel          <= op_a_sel_e'(0);
      id_ex_o.op_b_sel          <= op_b_sel_e'(0);
      id_ex_o.alu_operator      <= alu_operator_e'(0);
      id_ex_o.rs1_data          <= 0;
      id_ex_o.rs2_data          <= 0;
      id_ex_o.rs1_addr          <= 0;
      id_ex_o.rs2_addr          <= 0;
      id_ex_o.imm               <= 0;
      id_ex_o.rd_data_sel       <= rd_data_sel_e'(0);
      id_ex_o.rd_addr           <= 0;
      id_ex_o.rd_we             <= 0;
      id_ex_o.lsu_store         <= 0;
      id_ex_o.lsu_width         <= lsu_width_e'(0);
      id_ex_o.lsu_load_unsigned <= 0;
      id_ex_o.change_flow       <= 0;
      id_ex_o.jb_address        <= 0;
      id_ex_o.pc                <= 0;
      id_ex_o.pc_inc            <= 0;
    end else begin
      id_ex_o.op_a_sel          <= op_a_sel;
      id_ex_o.op_b_sel          <= op_b_sel;
      id_ex_o.alu_operator      <= alu_operator;
      id_ex_o.rs1_data          <= rs1_data;
      id_ex_o.rs2_data          <= rs2_data;
      id_ex_o.rs1_addr          <= rs1_addr;
      id_ex_o.rs2_addr          <= rs2_addr;
      id_ex_o.imm               <= imm;
      id_ex_o.rd_data_sel       <= rd_data_sel;
      id_ex_o.rd_addr           <= rd_addr;
      id_ex_o.rd_we             <= rd_we;
      id_ex_o.lsu_store         <= lsu_store;
      id_ex_o.lsu_width         <= lsu_width;
      id_ex_o.lsu_load_unsigned <= lsu_load_unsigned;
      id_ex_o.change_flow       <= change_flow;
      id_ex_o.jb_address        <= jb_address;
      id_ex_o.pc                <= if_id_i.pc;
      id_ex_o.pc_inc            <= if_id_i.pc_inc;
    end
  end

endmodule
