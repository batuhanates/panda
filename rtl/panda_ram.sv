// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_ram #(
  parameter int unsigned DataWidth  = 32,
  parameter int unsigned Depth      = 32,
  parameter bit          OutputReg  = 1'b1,
  parameter bit          WriteFirst = 1'b0,
  parameter              InitFile   = ""
) (
  input  logic                     clk_i,
  input  logic                     ce_i,
  input  logic [  DataWidth/8-1:0] we_i,
  input  logic [$clog2(Depth)-1:0] addr_i,
  input  logic [    DataWidth-1:0] data_i,
  output logic [    DataWidth-1:0] data_o
);

  logic [DataWidth-1:0] mem[Depth];

  logic [DataWidth-1:0] mem_rdata;
  logic [DataWidth-1:0] mem_wdata;

  assign mem_rdata = mem[addr_i];

  if (OutputReg) begin
    always_ff @(posedge clk_i) begin
      if (ce_i) begin
        data_o <= WriteFirst ? mem_wdata : mem_rdata;
      end
    end
  end else begin
    assign data_o = WriteFirst ? mem_wdata : mem_rdata;
  end

  // Determine write input according to byte-wide write enable
  for (genvar i = 0; i < DataWidth/8; i++) begin
    assign mem_wdata[i*8+:8] = we_i[i] ? data_i[i*8+:8] : mem_rdata[i*8+:8];
  end

  always_ff @(posedge clk_i) begin
    if (ce_i) begin
      mem[addr_i] <= mem_wdata;
    end
  end

  if (InitFile != "") begin
    initial begin
      $display("Initializing RAM from %s", InitFile);
      $readmemh(InitFile, mem);
    end
  end

endmodule
