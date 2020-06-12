// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_forward_unit (
  input  logic [4:0] rs1_addr_i,
  input  logic [4:0] rs2_addr_i,

  input  logic [4:0] rd_addr_ex_i,
  input  logic       rd_we_ex_i,

  input  logic [4:0] rd_addr_mem_i,
  input  logic       rd_we_mem_i,

  output logic [1:0] forward_rs1_o,
  output logic [1:0] forward_rs2_o
);

  logic rs1_eq_rd_ex;
  logic rs2_eq_rd_ex;
  logic rs1_eq_rd_mem;
  logic rs2_eq_rd_mem;
  logic rd_ex_nz;
  logic rd_mem_nz;

  assign rs1_eq_rd_ex  = rs1_addr_i == rd_addr_ex_i;
  assign rs2_eq_rd_ex  = rs2_addr_i == rd_addr_ex_i;
  assign rs1_eq_rd_mem = rs1_addr_i == rd_addr_mem_i;
  assign rs2_eq_rd_mem = rs2_addr_i == rd_addr_mem_i;
  assign rd_ex_nz      = rd_addr_ex_i != 5'b0;
  assign rd_mem_nz     = rd_addr_mem_i != 5'b0;

  assign forward_rs1_o[0] = rs1_eq_rd_ex & rd_ex_nz & rd_we_ex_i;
  assign forward_rs1_o[1] = rs1_eq_rd_mem & rd_mem_nz & rd_we_mem_i & ~rs1_eq_rd_ex;
  assign forward_rs2_o[0] = rs2_eq_rd_ex & rd_ex_nz & rd_we_ex_i;
  assign forward_rs2_o[1] = rs2_eq_rd_mem & rd_mem_nz & rd_we_mem_i & ~rs2_eq_rd_ex;

endmodule
