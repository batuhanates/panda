// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_sc_controller #(
  parameter int unsigned InstrMemDepth    = 32,
  parameter              InstrMemInitFile = ""
) (
  input  logic                     clk_i,
  input  logic                     rst_ni,
  // Register File
  output logic [ 4:0]              rs1_addr_o,          // AA
  output logic [ 4:0]              rs2_addr_o,          // BA
  output logic [ 4:0]              rd_addr_o,           // DA
  output logic                     rd_we_o,             // RW
  // Select
  output panda_pkg::op_a_sel_e     op_a_sel_o,          // MA
  output panda_pkg::op_b_sel_e     op_b_sel_o,          // MB
  output panda_pkg::rd_data_sel_e  rd_data_sel_o,       // MD
  output panda_pkg::alu_operator_e alu_operator_o,      // FS
  // Load-Store
  output logic                     lsu_store_o,         // LS
  output panda_pkg::lsu_width_e    lsu_width_o,         // WS
  output logic                     lsu_load_unsigned_o, // LU
  // Data to datapath
  output logic [31:0]              pc_o,
  output logic [31:0]              pc_inc_o,
  output logic [31:0]              imm_o,
  // Jump-Branch
  input  logic [31:0]              jump_target_i,
  input  logic                     branch_cond_i
);
  import panda_pkg::*;

  logic [31:0] instr;
  logic [31:0] imm;

  logic branch;
  logic jump;

  logic [31:0] pc;
  logic [31:0] pc_next;
  logic [31:0] adder_input;
  logic [31:0] adder_result;

  assign imm_o    = imm;
  assign pc_o     = pc;
  assign pc_inc_o = adder_result;

  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_pc
    if(~rst_ni) begin
      pc <= 0;
    end else begin
      pc <= pc_next;
    end
  end

  assign adder_input  = branch & branch_cond_i ? imm : 32'd4;
  assign adder_result = $unsigned(pc) + $unsigned(adder_input);
  assign pc_next      = jump ? jump_target_i : adder_result;

  localparam int unsigned AddrWidth = $clog2(InstrMemDepth);

  panda_ram #(
    .DataWidth (32              ),
    .Depth     (InstrMemDepth   ),
    .OutputReg (1'b0            ),
    .WriteFirst(1'b0            ),
    .InitFile  (InstrMemInitFile)
  ) i_instruction_memory (
    .clk_i (clk_i            ),
    .ce_i  (1'b1             ),
    .we_i  (4'b0             ),
    .addr_i(pc[AddrWidth+1:2]),
    .data_i(32'b0            ),
    .data_o(instr            )
  );

  panda_sc_id i_instruction_decoder (
    .instr_i            (instr              ),
    .rs1_addr_o         (rs1_addr_o         ),
    .rs2_addr_o         (rs2_addr_o         ),
    .rd_addr_o          (rd_addr_o          ),
    .rd_we_o            (rd_we_o            ),
    .op_a_sel_o         (op_a_sel_o         ),
    .op_b_sel_o         (op_b_sel_o         ),
    .rd_data_sel_o      (rd_data_sel_o      ),
    .alu_operator_o     (alu_operator_o     ),
    .lsu_store_o        (lsu_store_o        ),
    .lsu_width_o        (lsu_width_o        ),
    .lsu_load_unsigned_o(lsu_load_unsigned_o),
    .branch_o           (branch             ),
    .jump_o             (jump               ),
    .imm_o              (imm                )
  );

endmodule
