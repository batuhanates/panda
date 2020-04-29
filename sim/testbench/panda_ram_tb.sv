// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_ram_tb ();

  parameter int unsigned DataWidth = 32;
  parameter int unsigned Depth     = 64;
  parameter InitFile = "ram_test.mem";

  logic                     clk_i  = 1'b0;
  logic                     ce_i;
  logic [  DataWidth/8-1:0] we_i;
  logic [$clog2(Depth)-1:0] addr_i;
  logic [    DataWidth-1:0] data_i;
  logic [    DataWidth-1:0] data_o;

  panda_ram #(
    .DataWidth(DataWidth),
    .Depth    (Depth    ),
    .InitFile (InitFile )
  ) dut (
    .clk_i (clk_i ),
    .ce_i  (ce_i  ),
    .we_i  (we_i  ),
    .addr_i(addr_i),
    .data_i(data_i),
    .data_o(data_o)
  );

  always #5 clk_i <= ~clk_i;

  initial begin
    ce_i = 1'b0;
    we_i = 4'b0;
    addr_i = 5'd0;
    data_i = 32'b0;
    #10 ce_i = 1'b1;
    #10 $monitor("addr_i:0x%h",  addr_i);
    $monitor("data_o:0x%h", data_o);
    for (int i = 0; i < 36; i++) begin
      #10 addr_i = i;
    end
    #10 addr_i = 40;
    data_i = 32'hABCDEF89;
    we_i = 4'b1111;
    #10 addr_i = 41;
    we_i = 4'b0011;
    #10 addr_i = 42;
    we_i = 4'b0001;
    #10 addr_i = 43;
    we_i = 4'b0101;
    #10 $finish;
  end

endmodule
