// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

/**
* ID stage forward unit
*
* Controls forwarding in ID stage for RAW hazards
*/
module panda_forward_id (
  input  logic                    branch_i,
  input  logic                    jalr_i,

  input  logic [4:0]              rs1_addr_i,
  input  logic [4:0]              rs2_addr_i,

  input  panda_pkg::rd_data_sel_e ex_mem_rd_data_sel_i,
  input  logic [4:0]              ex_mem_rd_addr_i,
  input  logic                    ex_mem_rd_we_i,

  output logic                    forward_rs1_o,
  output logic                    forward_rs2_o
);
  import panda_pkg::*;

  logic eq_ex_mem_1; // rs1_addr is same in ID and EX/MEM
  logic eq_ex_mem_2; // rs2_addr is same in ID and EX/MEM
  logic nz_ex_mem;   // rd_addr is not zero in EX/MEM
  logic not_load;    // The instruction in EX/MEM is not load

  assign eq_ex_mem_1 = rs1_addr_i == ex_mem_rd_addr_i;
  assign eq_ex_mem_2 = rs2_addr_i == ex_mem_rd_addr_i;
  assign nz_ex_mem   = ex_mem_rd_addr_i != 5'b0;
  assign not_load    = ex_mem_rd_data_sel_i != RD_DATA_LOAD;

  // Forward rs1 from EX/MEM
  assign forward_rs1_o = (jalr_i | branch_i) & eq_ex_mem_1 & nz_ex_mem &
    ex_mem_rd_we_i & not_load;
  // Forward rs2 from EX/MEM
  assign forward_rs2_o = branch_i & eq_ex_mem_2 & nz_ex_mem & ex_mem_rd_we_i &
    not_load;

endmodule
