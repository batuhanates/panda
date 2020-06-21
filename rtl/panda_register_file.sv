// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_register_file #(
  parameter int unsigned Width = 32,
  parameter int unsigned Depth = 32
) (
  input  logic                     clk_i,
  input  logic                     rst_ni,
  // Read port rs1
  input  logic [$clog2(Depth)-1:0] rs1_addr_i,
  output logic [        Width-1:0] rs1_data_o,
  // Read port rs2
  input  logic [$clog2(Depth)-1:0] rs2_addr_i,
  output logic [        Width-1:0] rs2_data_o,
  // Write port rd
  input  logic [$clog2(Depth)-1:0] rd_addr_i,
  input  logic [        Width-1:0] rd_data_i,
  input  logic                     rd_we_i
);

  logic [Depth-1:0][Width-1:0] registers;
  logic [Depth-1:1][Width-1:0] registers_tmp;
  logic [Depth-1:0]            we;
  logic [Depth-1:0]            we_tmp;

  // Register x0 is hardwired with all bits equal to 0
  assign registers[0]         = '0;
  assign registers[Depth-1:1] = registers_tmp;

  // decoder
  assign we_tmp = ({{Depth-1{1'b0}}, 1'b1} << rd_addr_i) & {Depth{rd_we_i}};
  assign we     = {we_tmp[Depth-1:1], 1'b0};

  // Check we signals for write-first operation. we[0] is always 0.
  assign rs1_data_o = we[rs1_addr_i] ? rd_data_i : registers[rs1_addr_i];
  assign rs2_data_o = we[rs2_addr_i] ? rd_data_i : registers[rs2_addr_i];

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      registers_tmp <= '0;
    end else begin
      for (int i = 1; i < Depth; i++) begin
        if (we[i]) begin
          registers_tmp[i] <= rd_data_i;
        end
      end
    end
  end

endmodule
