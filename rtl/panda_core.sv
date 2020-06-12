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

  if_id_t  if_id;
  id_ex_t  id_ex;
  ex_mem_t ex_mem;
  mem_wb_t mem_wb;

  logic [31:0] jump_target;
  logic [31:0] branch_target;
  logic        branch_cond;
  logic        branch;

  logic [31:0] rd_data;

  logic [1:0] forward_rs1;
  logic [1:0] forward_rs2;

  assign branch = id_ex.branch & branch_cond;

  panda_if_stage i_if_stage (
    .clk_i          (clk_i        ),
    .rst_ni         (rst_ni       ),
    .if_id_o        (if_id        ),
    .instr_rdata_i  (instr_rdata_i),
    .instr_addr_o   (instr_addr_o ),
    .branch_i       (branch       ),
    .jump_i         (id_ex.jump   ),
    .branch_target_i(branch_target),
    .jump_target_i  (jump_target  )
  );

  panda_id_stage i_id_stage (
    .clk_i    (clk_i         ),
    .rst_ni   (rst_ni        ),
    .if_id_i  (if_id         ),
    .id_ex_o  (id_ex         ),
    .rd_data_i(rd_data       ),
    .rd_addr_i(mem_wb.rd_addr),
    .rd_we_i  (mem_wb.rd_we  )
  );

  panda_ex_stage i_ex_stage (
    .clk_i          (clk_i        ),
    .rst_ni         (rst_ni       ),
    .id_ex_i        (id_ex        ),
    .ex_mem_o       (ex_mem       ),
    .jump_target_o  (jump_target  ),
    .branch_target_o(branch_target),
    .branch_cond_o  (branch_cond  ),
    .forward_rs1_i  (forward_rs1  ),
    .forward_rs2_i  (forward_rs2  ),
    .rd_data_i      (rd_data      )
  );

  panda_mem_stage i_mem_stage (
    .clk_i       (clk_i       ),
    .rst_ni      (rst_ni      ),
    .ex_mem_i    (ex_mem      ),
    .mem_wb_o    (mem_wb      ),
    .data_rdata_i(data_rdata_i),
    .data_wdata_o(data_wdata_o),
    .data_addr_o (data_addr_o ),
    .data_we_o   (data_we_o   )
  );

  always_comb begin : proc_rd_data_mux
    unique case (mem_wb.rd_data_sel)
      RD_DATA_ALU    : rd_data = mem_wb.alu_result;
      RD_DATA_LOAD   : rd_data = mem_wb.load_data;
      RD_DATA_PC_INC : rd_data = mem_wb.pc_inc;
      RD_DATA_IMM    : rd_data = mem_wb.imm;
      default        : rd_data = mem_wb.alu_result;
    endcase
  end

  panda_forward_unit i_forward_unit (
    .rs1_addr_i   (id_ex.rs1_addr),
    .rs2_addr_i   (id_ex.rs2_addr),
    .rd_addr_ex_i (ex_mem.rd_addr),
    .rd_we_ex_i   (ex_mem.rd_we  ),
    .rd_addr_mem_i(mem_wb.rd_addr),
    .rd_we_mem_i  (mem_wb.rd_we  ),
    .forward_rs1_o(forward_rs1   ),
    .forward_rs2_o(forward_rs2   )
  );

endmodule
