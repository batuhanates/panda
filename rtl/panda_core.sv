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

  // Pipeline registers
  if_id_t  if_id;
  id_ex_t  id_ex;
  ex_mem_t ex_mem;
  mem_wb_t mem_wb;

  logic [31:0] rd_data;
  logic [31:0] rd_data_ex;

  logic stall_if;
  logic flush_if;

  panda_if_stage i_if_stage (
    .clk_i        (clk_i            ),
    .rst_ni       (rst_ni           ),
    .stall_i      (stall_if         ),
    .flush_i      (flush_if         ),
    .if_id_o      (if_id            ),
    .instr_rdata_i(instr_rdata_i    ),
    .instr_addr_o (instr_addr_o     ),
    .change_flow_i(id_ex.change_flow),
    .jb_address_i (id_ex.jb_address )
  );

  panda_id_stage i_id_stage (
    .clk_i               (clk_i             ),
    .rst_ni              (rst_ni            ),
    .if_id_i             (if_id             ),
    .id_ex_o             (id_ex             ),
    .rd_data_i           (rd_data           ),
    .rd_addr_i           (mem_wb.rd_addr    ),
    .rd_we_i             (mem_wb.rd_we      ),
    .ex_mem_rd_data_sel_i(ex_mem.rd_data_sel),
    .ex_mem_rd_addr_i    (ex_mem.rd_addr    ),
    .ex_mem_rd_we_i      (ex_mem.rd_we      ),
    .rd_data_ex_i        (rd_data_ex        ),
    .stall_if_o          (stall_if          ),
    .flush_if_o          (flush_if          )
  );

  panda_ex_stage i_ex_stage (
    .clk_i       (clk_i         ),
    .rst_ni      (rst_ni        ),
    .id_ex_i     (id_ex         ),
    .ex_mem_o    (ex_mem        ),
    .rd_addr_i   (mem_wb.rd_addr),
    .rd_we_i     (mem_wb.rd_we  ),
    .rd_data_i   (rd_data       ),
    .rd_data_ex_o(rd_data_ex    )
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

endmodule
