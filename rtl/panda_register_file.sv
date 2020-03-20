// Copyright 2020 Batuhan Ates
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_register_file (
  input  logic        clk_i,
  input  logic        rst_ni,
  // Read port rs1
  input  logic [ 4:0] rs1_addr_i,
  output logic [31:0] rs1_data_o,
  // Read port rs2
  input  logic [ 4:0] rs2_addr_i,
  output logic [31:0] rs2_data_o,
  // Write port rd
  input  logic [ 4:0] rd_addr_i,
  input  logic [31:0] rd_data_i,
  input  logic        rd_we_i
);
  logic [0:31][31:0] registers;
  logic [1:31][31:0] registers_tmp;
  logic [1:31]       we;

  // Register x0 is hardwired with all bits equal to 0
  assign registers[0]    = '0;
  assign registers[1:31] = registers_tmp;

  assign rs1_data_o = registers[rs1_addr_i];
  assign rs2_data_o = registers[rs2_addr_i];

  for (genvar i = 1; i < 32; i++) begin
    assign we[i] = i == rd_addr_i ? rd_we_i : 1'b0;
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      registers_tmp <= '0;
    end else begin
      for (int i = 1; i < 32; i++) begin
        if (we[i]) begin
          registers_tmp[i] <= rd_data_i;
        end
      end
    end
  end

endmodule
