// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_mem_stage (
  input  logic               clk_i,
  input  logic               rst_ni,

  input  panda_pkg::ex_mem_t ex_mem_i,
  output panda_pkg::mem_wb_t mem_wb_o,

  input  logic [31:0]        data_rdata_i,
  output logic [31:0]        data_wdata_o,
  output logic [31:0]        data_addr_o,
  output logic [ 3:0]        data_we_o
);
  import panda_pkg::*;

  logic [31:0] load_data;
  logic [31:0] store_data;

  logic mem_to_mem_copy;

  assign mem_to_mem_copy = ex_mem_i.rs2_addr == mem_wb_o.rd_addr & mem_wb_o.rd_we
    & mem_wb_o.rd_addr != 5'b0 & mem_wb_o.rd_data_sel == RD_DATA_LOAD;

  // Check for memory to memory copy
  always_comb begin
    if (mem_to_mem_copy) begin
      store_data = mem_wb_o.load_data;
    end else begin
      store_data = ex_mem_i.rs2_data;
    end
  end

  panda_lsu i_lsu (
    .store_i        (ex_mem_i.lsu_store        ),
    .load_unsigned_i(ex_mem_i.lsu_load_unsigned),
    .width_i        (ex_mem_i.lsu_width        ),
    .addr_i         (ex_mem_i.alu_result       ),
    .store_data_i   (store_data                ),
    .load_data_o    (load_data                 ),
    .data_rdata_i   (data_rdata_i              ),
    .data_wdata_o   (data_wdata_o              ),
    .data_addr_o    (data_addr_o               ),
    .data_we_o      (data_we_o                 )
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_mem_wb
    if(~rst_ni) begin
      mem_wb_o.load_data   <= 0;
      mem_wb_o.pc_inc      <= 0;
      mem_wb_o.imm         <= 0;
      mem_wb_o.rd_data_sel <= rd_data_sel_e'(0);
      mem_wb_o.rd_addr     <= 0;
      mem_wb_o.rd_we       <= 0;
      mem_wb_o.alu_result  <= 0;
    end else begin
      mem_wb_o.load_data   <= load_data;
      mem_wb_o.pc_inc      <= ex_mem_i.pc_inc;
      mem_wb_o.imm         <= ex_mem_i.imm;
      mem_wb_o.rd_data_sel <= ex_mem_i.rd_data_sel;
      mem_wb_o.rd_addr     <= ex_mem_i.rd_addr;
      mem_wb_o.rd_we       <= ex_mem_i.rd_we;
      mem_wb_o.alu_result  <= ex_mem_i.alu_result;
    end
  end

endmodule
