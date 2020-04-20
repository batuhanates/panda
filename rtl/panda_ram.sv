// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_ram #(
  parameter DataWidth = 32,
  parameter Depth     = 32,
  parameter InitFile  = ""
) (
  input  logic                     clk_i,
  input  logic                     ce_i,
  input  logic [  DataWidth/8-1:0] we_i,
  input  logic [$clog2(Depth)-1:0] addr_i,
  input  logic [    DataWidth-1:0] data_i,
  output logic [    DataWidth-1:0] data_o
);

  logic [DataWidth-1:0] memory[Depth];

  always_ff @(posedge clk_i) begin
    if (ce_i) begin
      data_o <= memory[addr_i];
      for (int i = 0; i < DataWidth/8; i++) begin
        if (we_i[i]) begin
          memory[addr_i][i*8+:8] <= data_i[i*8+:8];
        end
      end
    end
  end

  if (InitFile != "") begin
    initial begin
      $display("Initializing RAM from %s", InitFile);
      $readmemh(InitFile, memory);
    end
  end

endmodule
