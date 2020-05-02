// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_sc_datapath_mem #(
  parameter int unsigned DataMemDepth    = 32,
  parameter              DataMemInitFile = ""
) (
  input  logic                     clk_i,
  input  logic                     rst_ni,
  // Register File
  input  logic [ 4:0]              rs1_addr_i,         // AA
  input  logic [ 4:0]              rs2_addr_i,         // BA
  input  logic [ 4:0]              rd_addr_i,          // DA
  input  logic                     rd_we_i,            // RW
  // Select
  input  logic                     sel_operand_a_i,    // MA
  input  logic                     sel_operand_b_i,    // MB
  input  logic [ 1:0]              sel_rd_data_i,      // MD
  input  panda_pkg::alu_operator_e alu_operator_i,     // FS
  // Load-Store
  input  logic                     load_store_i,       // LS
  input  logic [ 1:0]              load_store_width_i, // WS
  input  logic                     load_unsigned_i,    // LU
  // Data from controller
  input  logic [31:0]              pc_i,
  input  logic [31:0]              pc_next_i,
  input  logic [31:0]              imm_i,
  // Jump-Branch
  output logic [31:0]              jump_target_o,
  output logic                     branch_cond_o
);
  import panda_pkg::*;

  localparam int unsigned DATA_ADDR_WIDTH = $clog2(DataMemDepth);

  logic [31:0] data_rdata;
  logic [31:0] data_wdata;
  logic [31:0] data_addr_ext; // byte address
  logic [ 3:0] data_we;

  logic [DATA_ADDR_WIDTH-1:0] data_addr; // word address

  // convert byte address to word address
  assign data_addr = data_addr_ext[DATA_ADDR_WIDTH+1:2];

  panda_sc_datapath i_datapath (
    .clk_i             (clk_i             ),
    .rst_ni            (rst_ni            ),
    .rs1_addr_i        (rs1_addr_i        ),
    .rs2_addr_i        (rs2_addr_i        ),
    .rd_addr_i         (rd_addr_i         ),
    .rd_we_i           (rd_we_i           ),
    .sel_operand_a_i   (sel_operand_a_i   ),
    .sel_operand_b_i   (sel_operand_b_i   ),
    .sel_rd_data_i     (sel_rd_data_i     ),
    .alu_operator_i    (alu_operator_i    ),
    .load_store_i      (load_store_i      ),
    .load_store_width_i(load_store_width_i),
    .load_unsigned_i   (load_unsigned_i   ),
    .data_rdata_i      (data_rdata        ),
    .data_wdata_o      (data_wdata        ),
    .data_addr_o       (data_addr_ext     ),
    .data_we_o         (data_we           ),
    .pc_i              (pc_i              ),
    .pc_next_i         (pc_next_i         ),
    .imm_i             (imm_i             ),
    .jump_target_o     (jump_target_o     ),
    .branch_cond_o     (branch_cond_o     )
  );

  panda_ram #(
    .DataWidth(32             ),
    .Depth    (DataMemDepth   ),
    .OutputReg(1'b0           ),
    .InitFile (DataMemInitFile)
  ) i_data_memory (
    .clk_i (clk_i     ),
    .ce_i  (rst_ni    ),
    .we_i  (data_we   ),
    .addr_i(data_addr ),
    .data_i(data_wdata),
    .data_o(data_rdata)
  );

endmodule
