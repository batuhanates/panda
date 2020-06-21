// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

/**
* Controller
*
* Checks for hazards which require pipeline stalling.
*/
module panda_controller (
  input  panda_pkg::rd_data_sel_e id_ex_rd_data_sel_i,
  input  logic [4:0]              id_ex_rd_addr_i,
  input  logic                    id_ex_rd_we_i,

  input  panda_pkg::rd_data_sel_e ex_mem_rd_data_sel_i,
  input  logic [4:0]              ex_mem_rd_addr_i,

  input  panda_pkg::op_a_sel_e    op_a_sel_i,
  input  panda_pkg::op_b_sel_e    op_b_sel_i,
  input  logic                    branch_i,
  input  logic                    jalr_i,
  input  logic [4:0]              rs1_addr_i,
  input  logic [4:0]              rs2_addr_i,

  output logic                    bubble_id_o
);
  import panda_pkg::*;

  logic load_use_hazard_1; // Load instruction currently at EX stage
  logic load_use_hazard_2; // Load instruction currently at MEM stage
  logic raw_hazard;        // RAW hazard for branch or jalr

  logic load_id_ex;
  logic eq_id_ex_1;
  logic eq_id_ex_2;
  logic nz_id_ex;
  logic rs1_used;
  logic rs2_used;

  logic load_ex_mem;
  logic eq_ex_mem_1;
  logic eq_ex_mem_2;
  logic nz_ex_mem;
  logic br_or_jalr;

  assign load_id_ex = id_ex_rd_data_sel_i == RD_DATA_LOAD;
  assign eq_id_ex_1 = rs1_addr_i == id_ex_rd_addr_i;
  assign eq_id_ex_2 = rs2_addr_i == id_ex_rd_addr_i;
  assign nz_id_ex   = id_ex_rd_addr_i != 5'b0;
  assign rs1_used   = op_a_sel_i == OP_A_RS1;
  assign rs2_used   = op_b_sel_i == OP_B_RS2;

  assign load_ex_mem = ex_mem_rd_data_sel_i == RD_DATA_LOAD;
  assign eq_ex_mem_1 = rs1_addr_i == ex_mem_rd_addr_i;
  assign eq_ex_mem_2 = rs2_addr_i == ex_mem_rd_addr_i;
  assign nz_ex_mem   = ex_mem_rd_addr_i != 5'b0;
  assign br_or_jalr  = branch_i | jalr_i;


  assign load_use_hazard_1 = load_id_ex & nz_id_ex &
    ((eq_id_ex_1 & rs1_used) | (eq_id_ex_2 & rs2_used));

  assign load_use_hazard_2 = load_ex_mem & nz_ex_mem &
    ((eq_ex_mem_1 & br_or_jalr) | (eq_ex_mem_2 & branch_i));

  assign raw_hazard = id_ex_rd_we_i & nz_id_ex &
    ((eq_id_ex_1 & br_or_jalr) | (eq_id_ex_2 & branch_i));


  assign bubble_id_o = load_use_hazard_1 | load_use_hazard_2 | raw_hazard;

endmodule
