// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

/**
* EX stage forward unit
*
* Controls forwarding in EX stage for RAW hazards
*/
module panda_forward_ex (
  input  logic [4:0] id_ex_rs1_addr_i,
  input  logic [4:0] id_ex_rs2_addr_i,

  input  logic [4:0] ex_mem_rd_addr_i,
  input  logic       ex_mem_rd_we_i,

  input  logic [4:0] mem_wb_rd_addr_i,
  input  logic       mem_wb_rd_we_i,

  output logic [1:0] forward_rs1_o,
  output logic [1:0] forward_rs2_o
);

  logic eq_ex_mem_1;
  logic eq_ex_mem_2;
  logic eq_mem_wb_1;
  logic eq_mem_wb_2;
  logic nz_ex_mem;
  logic nz_mem_wb;

  assign eq_ex_mem_1 = id_ex_rs1_addr_i == ex_mem_rd_addr_i;
  assign eq_ex_mem_2 = id_ex_rs2_addr_i == ex_mem_rd_addr_i;
  assign eq_mem_wb_1 = id_ex_rs1_addr_i == mem_wb_rd_addr_i;
  assign eq_mem_wb_2 = id_ex_rs2_addr_i == mem_wb_rd_addr_i;
  assign nz_ex_mem   = ex_mem_rd_addr_i != 5'b0;
  assign nz_mem_wb   = mem_wb_rd_addr_i != 5'b0;

  assign forward_rs1_o[0] = eq_ex_mem_1 & nz_ex_mem & ex_mem_rd_we_i;
  assign forward_rs1_o[1] = eq_mem_wb_1 & nz_mem_wb & mem_wb_rd_we_i &
    ~forward_rs1_o[0];

  assign forward_rs2_o[0] = eq_ex_mem_2 & nz_ex_mem & ex_mem_rd_we_i;
  assign forward_rs2_o[1] = eq_mem_wb_2 & nz_mem_wb & mem_wb_rd_we_i &
    ~forward_rs2_o[0];

endmodule
