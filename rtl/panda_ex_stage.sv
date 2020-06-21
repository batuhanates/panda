// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_ex_stage (
  input  logic               clk_i,
  input  logic               rst_ni,

  input  panda_pkg::id_ex_t  id_ex_i,
  output panda_pkg::ex_mem_t ex_mem_o,

  // Inputs from WB stage
  input  logic [ 4:0]        rd_addr_i,
  input  logic               rd_we_i,
  input  logic [31:0]        rd_data_i,

  // Send to ID stage for forwarding
  output logic [31:0]        rd_data_ex_o
);
  import panda_pkg::*;

  logic [31:0] alu_result;
  logic [31:0] alu_operand_a;
  logic [31:0] alu_operand_b;

  logic [31:0] rd_data_ex;
  logic [31:0] rs1_data;
  logic [31:0] rs2_data;

  logic [1:0] forward_rs1;
  logic [1:0] forward_rs2;

  assign rd_data_ex_o = rd_data_ex;

  panda_forward_ex i_forward_ex (
    .id_ex_rs1_addr_i(id_ex_i.rs1_addr),
    .id_ex_rs2_addr_i(id_ex_i.rs2_addr),
    .ex_mem_rd_addr_i(ex_mem_o.rd_addr),
    .ex_mem_rd_we_i  (ex_mem_o.rd_we  ),
    .mem_wb_rd_addr_i(rd_addr_i       ),
    .mem_wb_rd_we_i  (rd_we_i         ),
    .forward_rs1_o   (forward_rs1     ),
    .forward_rs2_o   (forward_rs2     )
  );

  always_comb begin : proc_forward
    unique case (ex_mem_o.rd_data_sel)
      RD_DATA_ALU    : rd_data_ex = ex_mem_o.alu_result;
      RD_DATA_PC_INC : rd_data_ex = ex_mem_o.pc_inc;
      RD_DATA_IMM    : rd_data_ex = ex_mem_o.imm;
      default        : rd_data_ex = ex_mem_o.alu_result;
    endcase

    unique case (forward_rs1)
      2'b00   : rs1_data = id_ex_i.rs1_data;
      2'b01   : rs1_data = rd_data_ex;
      2'b10   : rs1_data = rd_data_i;
      default : rs1_data = id_ex_i.rs1_data;
    endcase

    unique case (forward_rs2)
      2'b00   : rs2_data = id_ex_i.rs2_data;
      2'b01   : rs2_data = rd_data_ex;
      2'b10   : rs2_data = rd_data_i;
      default : rs2_data = id_ex_i.rs2_data;
    endcase
  end

  always_comb begin : proc_alu_operands
    unique case (id_ex_i.op_a_sel)
      OP_A_RS1 : alu_operand_a = rs1_data;
      OP_A_PC  : alu_operand_a = id_ex_i.pc;
      default  : alu_operand_a = rs1_data;
    endcase

    unique case (id_ex_i.op_b_sel)
      OP_B_RS2 : alu_operand_b = rs2_data;
      OP_B_IMM : alu_operand_b = id_ex_i.imm;
      default  : alu_operand_b = rs2_data;
    endcase
  end

  panda_alu #(
    .Width(32)
  ) i_alu (
    .operator_i (id_ex_i.alu_operator),
    .operand_a_i(alu_operand_a       ),
    .operand_b_i(alu_operand_b       ),
    .result_o   (alu_result          )
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin : proc_ex_mem
    if(~rst_ni) begin
      ex_mem_o.alu_result        <= 0;
      ex_mem_o.pc_inc            <= 0;
      ex_mem_o.rd_data_sel       <= rd_data_sel_e'(0);
      ex_mem_o.rd_addr           <= 0;
      ex_mem_o.rd_we             <= 0;
      ex_mem_o.lsu_store         <= 0;
      ex_mem_o.lsu_width         <= lsu_width_e'(0);
      ex_mem_o.lsu_load_unsigned <= 0;
      ex_mem_o.imm               <= 0;
      ex_mem_o.rs2_data          <= 0;
      ex_mem_o.rs2_addr          <= 0;
    end else begin
      ex_mem_o.alu_result        <= alu_result;
      ex_mem_o.pc_inc            <= id_ex_i.pc_inc;
      ex_mem_o.rd_data_sel       <= id_ex_i.rd_data_sel;
      ex_mem_o.rd_addr           <= id_ex_i.rd_addr;
      ex_mem_o.rd_we             <= id_ex_i.rd_we;
      ex_mem_o.lsu_store         <= id_ex_i.lsu_store;
      ex_mem_o.lsu_width         <= id_ex_i.lsu_width;
      ex_mem_o.lsu_load_unsigned <= id_ex_i.lsu_load_unsigned;
      ex_mem_o.imm               <= id_ex_i.imm;
      ex_mem_o.rs2_data          <= rs2_data;
      ex_mem_o.rs2_addr          <= id_ex_i.rs2_addr;
    end
  end

endmodule
