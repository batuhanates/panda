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
  struct {
    logic [31:0] instr;
    logic [31:0] pc;
    logic [31:0] pc_inc;
  } ifo;

  // IF/ID registers
  struct {
    logic [31:0] instr;
    logic [31:0] pc;
    logic [31:0] pc_inc;
  } if_id;

  // ID stage outputs
  struct {
    op_a_sel_e     op_a_sel;
    op_b_sel_e     op_b_sel;
    alu_operator_e alu_operator;
    logic [31:0]   imm;
    logic [31:0]   rs1_data;
    logic [31:0]   rs2_data;
    rd_data_sel_e  rd_data_sel;
    logic [ 4:0]   rd_addr;
    logic          rd_we;
    logic          lsu_store;
    lsu_width_e    lsu_width;
    logic          lsu_load_unsigned;
    logic          branch;
    logic          jump;
  } ido;

  // EX stage outputs
  struct {
    logic [31:0] alu_result;
    logic [31:0] jump_target;
    logic [31:0] branch_target;
    logic        branch_cond;
  } exo;

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
  assign branch = ido.branch & exo.branch_cond;

  panda_if_stage i_if_stage (
    .clk_i          (clk_i            ),
    .rst_ni         (rst_ni           ),
    .instr_rdata_i  (instr_rdata_i    ),
    .instr_addr_o   (instr_addr_o     ),
    .branch_i       (branch           ),
    .jump_i         (ido.jump         ),
    .branch_target_i(exo.branch_target),
    .jump_target_i  (exo.jump_target  ),
    .instr_o        (ifo.instr        ),
    .pc_o           (ifo.pc           ),
    .pc_inc_o       (ifo.pc_inc       )
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_if_id
    if(~rst_ni) begin
      if_id.instr  <= 0;
      if_id.pc     <= 0;
      if_id.pc_inc <= 0;
    end else begin
      if_id.instr  <= ifo.instr;
      if_id.pc     <= ifo.pc;
      if_id.pc_inc <= ifo.pc_inc;
    end
  end

  panda_id_stage i_id_stage (
    .clk_i              (clk_i                ),
    .rst_ni             (rst_ni               ),
    .instr_i            (if_id.instr          ),
    .rd_data_i          (rd_data_wb           ),
    .rd_addr_i          (ex_mem.rd_addr       ),
    .rd_we_i            (ex_mem.rd_we         ),
    .op_a_sel_o         (ido.op_a_sel         ),
    .op_b_sel_o         (ido.op_b_sel         ),
    .alu_operator_o     (ido.alu_operator     ),
    .imm_o              (ido.imm              ),
    .rs1_data_o         (ido.rs1_data         ),
    .rs2_data_o         (ido.rs2_data         ),
    .rd_data_sel_o      (ido.rd_data_sel      ),
    .rd_addr_o          (ido.rd_addr          ),
    .rd_we_o            (ido.rd_we            ),
    .lsu_store_o        (ido.lsu_store        ),
    .lsu_width_o        (ido.lsu_width        ),
    .lsu_load_unsigned_o(ido.lsu_load_unsigned),
    .branch_o           (ido.branch           ),
    .jump_o             (ido.jump             )
  );

  panda_ex_stage i_ex_stage (
    .pc_i          (if_id.pc         ),
    .op_a_sel_i    (ido.op_a_sel     ),
    .op_b_sel_i    (ido.op_b_sel     ),
    .alu_operator_i(ido.alu_operator ),
    .imm_i         (ido.imm          ),
    .rs1_data_i    (ido.rs1_data     ),
    .rs2_data_i    (ido.rs2_data     ),
    .alu_result_o  (exo.alu_result   ),
    .jump_target_o (exo.jump_target  ),
    .branc_target_o(exo.branch_target),
    .branch_cond_o (exo.branch_cond  )
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
      ex_mem.lsu_store         <= ido.lsu_store;
      ex_mem.lsu_width         <= ido.lsu_width;
      ex_mem.lsu_load_unsigned <= ido.lsu_load_unsigned;
      ex_mem.alu_result        <= exo.alu_result;
      ex_mem.imm               <= ido.imm;
      ex_mem.rs2_data          <= ido.rs2_data;
      ex_mem.rd_data_sel       <= ido.rd_data_sel;
      ex_mem.rd_addr           <= ido.rd_addr;
      ex_mem.rd_we             <= ido.rd_we;
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
