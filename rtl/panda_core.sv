// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_core (
  input  logic        clk_i,
  input  logic        rst_ni,

  input  logic [31:0] instr_rdata_i,
  output logic [31:0] instr_addr_o,

  input  logic [31:0] data_rdata_i,
  output logic [31:0] data_wdata_o,
  output logic [31:0] data_addr_o,
  output logic [ 3:0] data_we_o
);
  import panda_pkg::*;

  // IF stage outputs
  logic [31:0] instr_if;
  logic [31:0] pc_if;
  logic [31:0] pc_inc_if;

  // IF/ID registers
  struct {
    logic [31:0] instr;
    logic [31:0] pc;
    logic [31:0] pc_inc;
  } if_id;

  // ID stage outputs
  op_a_sel_e     op_a_sel_id;
  op_b_sel_e     op_b_sel_id;
  alu_operator_e alu_operator_id;
  logic [31:0]   imm_id;
  logic [31:0]   rs1_data_id;
  logic [31:0]   rs2_data_id;
  rd_data_sel_e  rd_data_sel_id;
  logic [ 4:0]   rd_addr_id;
  logic          rd_we_id;
  logic          lsu_store_id;
  lsu_width_e    lsu_width_id;
  logic          lsu_load_unsigned_id;
  logic          branch_id;
  logic          jump_id;

  // EX stage outputs
  logic [31:0] alu_result_ex;
  logic [31:0] jump_target_ex;
  logic [31:0] branc_target_ex;
  logic        branch_cond_ex;

  // EX/MEM registers
  struct {
    logic [31:0]  pc_inc;
    logic         lsu_store;
    lsu_width_e   lsu_width;
    logic         lsu_load_unsigned;
    logic [31:0]  alu_result;
    logic [31:0]  imm;
    logic [31:0]  rs2_data;
    rd_data_sel_e rd_data_sel;
    logic [ 4:0]  rd_addr;
    logic         rd_we;
  } ex_mem;

  // MEM stage signals
  logic [31:0] load_data_mem;

  // WB stage signals
  logic [31:0] rd_data_wb;

  logic branch;
  assign branch = branch_id & branch_cond_ex;

  panda_if_stage i_if_stage (
    .clk_i          (clk_i          ),
    .rst_ni         (rst_ni         ),
    .instr_rdata_i  (instr_rdata_i  ),
    .instr_addr_o   (instr_addr_o   ),
    .branch_i       (branch         ),
    .jump_i         (jump_id        ),
    .branch_target_i(branc_target_ex),
    .jump_target_i  (jump_target_ex ),
    .instr_o        (instr_if       ),
    .pc_o           (pc_if          ),
    .pc_inc_o       (pc_inc_if      )
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_if_id
    if(~rst_ni) begin
      if_id.instr  <= 0;
      if_id.pc     <= 0;
      if_id.pc_inc <= 0;
    end else begin
      if_id.instr  <= instr_if;
      if_id.pc     <= pc_if;
      if_id.pc_inc <= pc_inc_if;
    end
  end

  panda_id_stage i_id_stage (
    .clk_i              (clk_i               ),
    .rst_ni             (rst_ni              ),
    .instr_i            (if_id.instr         ),
    .rd_data_i          (rd_data_wb          ),
    .rd_addr_i          (ex_mem.rd_addr      ),
    .rd_we_i            (ex_mem.rd_we        ),
    .op_a_sel_o         (op_a_sel_id         ),
    .op_b_sel_o         (op_b_sel_id         ),
    .alu_operator_o     (alu_operator_id     ),
    .imm_o              (imm_id              ),
    .rs1_data_o         (rs1_data_id         ),
    .rs2_data_o         (rs2_data_id         ),
    .rd_data_sel_o      (rd_data_sel_id      ),
    .rd_addr_o          (rd_addr_id          ),
    .rd_we_o            (rd_we_id            ),
    .lsu_store_o        (lsu_store_id        ),
    .lsu_width_o        (lsu_width_id        ),
    .lsu_load_unsigned_o(lsu_load_unsigned_id),
    .branch_o           (branch_id           ),
    .jump_o             (jump_id             )
  );

  panda_ex_stage i_ex_stage (
    .pc_i          (if_id.pc       ),
    .op_a_sel_i    (op_a_sel_id    ),
    .op_b_sel_i    (op_b_sel_id    ),
    .alu_operator_i(alu_operator_id),
    .imm_i         (imm_id         ),
    .rs1_data_i    (rs1_data_id    ),
    .rs2_data_i    (rs2_data_id    ),
    .alu_result_o  (alu_result_ex  ),
    .jump_target_o (jump_target_ex ),
    .branc_target_o(branc_target_ex),
    .branch_cond_o (branch_cond_ex )
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_ex_mem
    if(~rst_ni) begin
      ex_mem.pc_inc            <= 0;
      ex_mem.lsu_store         <= 0;
      ex_mem.lsu_width         <= lsu_width_e'(0);
      ex_mem.lsu_load_unsigned <= 0;
      ex_mem.alu_result        <= 0;
      ex_mem.imm               <= 0;
      ex_mem.rs2_data          <= 0;
      ex_mem.rd_data_sel       <= rd_data_sel_e'(0);
      ex_mem.rd_addr           <= 0;
      ex_mem.rd_we             <= 0;
    end else begin
      ex_mem.pc_inc            <= if_id.pc_inc;
      ex_mem.lsu_store         <= lsu_store_id;
      ex_mem.lsu_width         <= lsu_width_id;
      ex_mem.lsu_load_unsigned <= lsu_load_unsigned_id;
      ex_mem.alu_result        <= alu_result_ex;
      ex_mem.imm               <= imm_id;
      ex_mem.rs2_data          <= rs2_data_id;
      ex_mem.rd_data_sel       <= rd_data_sel_id;
      ex_mem.rd_addr           <= rd_addr_id;
      ex_mem.rd_we             <= rd_we_id;
    end
  end

  panda_lsu i_lsu (
    .store_i        (ex_mem.lsu_store        ),
    .load_unsigned_i(ex_mem.lsu_load_unsigned),
    .width_i        (ex_mem.lsu_width        ),
    .addr_i         (ex_mem.alu_result       ),
    .store_data_i   (ex_mem.rs2_data         ),
    .load_data_o    (load_data_mem           ),
    .data_rdata_i   (data_rdata_i            ),
    .data_wdata_o   (data_wdata_o            ),
    .data_addr_o    (data_addr_o             ),
    .data_we_o      (data_we_o               )
  );

  always_comb begin : proc_rd_data_mux
    unique case (ex_mem.rd_data_sel)
      RD_DATA_ALU    : rd_data_wb = ex_mem.alu_result;
      RD_DATA_LOAD   : rd_data_wb = load_data_mem;
      RD_DATA_PC_INC : rd_data_wb = ex_mem.pc_inc;
      RD_DATA_IMM    : rd_data_wb = ex_mem.imm;
      default        : rd_data_wb = ex_mem.alu_result;
    endcase
  end

endmodule
