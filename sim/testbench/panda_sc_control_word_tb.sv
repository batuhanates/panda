// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_sc_control_word_tb ();
  import panda_pkg::*;

  logic clk   = 1'b0;
  logic rst_n = 1'b0;

  logic [ 4:0]   rs1_addr;
  logic [ 4:0]   rs2_addr;
  logic [ 4:0]   rd_addr;
  logic          rd_we;
  op_a_sel_e     op_a_sel;
  op_b_sel_e     op_b_sel;
  rd_data_sel_e  rd_data_sel;
  alu_operator_e alu_operator;
  logic          lsu_store;
  lsu_width_e    lsu_width;
  logic          lsu_load_unsigned;
  logic [31:0]   data_rdata;
  logic [31:0]   data_wdata;
  logic [31:0]   data_addr;
  logic [ 3:0]   data_we;
  logic [31:0]   pc;
  logic [31:0]   pc_inc;
  logic [31:0]   imm;
  logic [31:0]   jump_target;
  logic          branch_cond;

  logic [27:0] cw;

  // Map control word to datapath signals
  assign alu_operator      = alu_operator_e'(cw[27:24]);
  assign lsu_width         = lsu_width_e'(cw[23:22]);
  assign lsu_load_unsigned = cw[21];
  assign lsu_store         = cw[20];
  assign op_b_sel          = op_b_sel_e'(cw[19]);
  assign op_a_sel          = op_a_sel_e'(cw[18]);
  assign rd_data_sel       = rd_data_sel_e'(cw[17:16]);
  assign rd_we             = cw[15];
  assign rs2_addr          = cw[14:10];
  assign rs1_addr          = cw[9:5];
  assign rd_addr           = cw[4:0];

  panda_sc_datapath dut (
    .clk_i              (clk              ),
    .rst_ni             (rst_n            ),
    .rs1_addr_i         (rs1_addr         ),
    .rs2_addr_i         (rs2_addr         ),
    .rd_addr_i          (rd_addr          ),
    .rd_we_i            (rd_we            ),
    .op_a_sel_i         (op_a_sel         ),
    .op_b_sel_i         (op_b_sel         ),
    .rd_data_sel_i      (rd_data_sel      ),
    .alu_operator_i     (alu_operator     ),
    .lsu_store_i        (lsu_store        ),
    .lsu_width_i        (lsu_width        ),
    .lsu_load_unsigned_i(lsu_load_unsigned),
    .data_rdata_i       (data_rdata       ),
    .data_wdata_o       (data_wdata       ),
    .data_addr_o        (data_addr        ),
    .data_we_o          (data_we          ),
    .pc_i               (pc               ),
    .pc_inc_i           (pc_inc           ),
    .imm_i              (imm              ),
    .jump_target_o      (jump_target      ),
    .branch_cond_o      (branch_cond      )
  );

  localparam int unsigned LIST_LEN = 8;

  bit [27:0] cw_list [LIST_LEN] = '{
    28'b0000_10_0_0_1_0_01_1_00000_00000_00001, // load A      LW x1, x0, 0
    28'b0000_10_0_0_1_0_01_1_00000_00000_00010, // Load N      LW x2, x0, 4
    28'b0000_00_0_0_0_0_00_1_00000_00000_00011, // C = 0       ADD x3, x0, x0
    28'b0101_00_0_0_1_0_00_1_00000_00011_00011, // C = 2C      SLLI x3, x3, 1
    28'b0001_00_0_0_0_0_00_1_00010_00011_00011, // C = C - N   SUB x3, x3, x2
    28'b0000_00_0_0_0_0_00_1_00001_00011_00011, // C = C + A   ADD x3, x3, x1
    28'b0001_00_0_0_0_0_00_1_00010_00011_00011, // C = C - N   SUB x3, x3, x2
    28'b0000_10_0_1_1_0_00_0_00011_00000_00000  // Store C     SW x0, x3, 8
  };

  bit [31:0] imm_list [LIST_LEN] = '{
    0, 4, 0, 1, 0, 0, 0, 8
  };

  bit [31:0] rdata_list [LIST_LEN] = '{
    3284, 5392, 0, 0, 0, 0, 0, 0
  };

  always #5 clk = ~clk;

  always_ff @(posedge clk or negedge rst_n) begin : proc_pc
    if(~rst_n) begin
      pc <= 0;
    end else begin
      pc <= pc_inc;
    end
  end

  assign pc_inc = pc + 4;

  initial begin : proc_stim
    cw = '0;
    #10 rst_n = 1'b1;
    for (int i = 0; i < LIST_LEN; i++) begin
      cw = cw_list[i];
      data_rdata = rdata_list[i];
      imm = imm_list[i];
      #10;
    end
    $finish;
  end

endmodule
