// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

`timescale 1ns/1ps

module panda_register_file_tb ();

  parameter Width = 32;
  parameter Depth = 32;

  logic                     clk_i      = 1'b0;
  logic                     rst_ni     = 1'b0;
  logic [$clog2(Depth)-1:0] rs1_addr_i = '0;
  logic [        Width-1:0] rs1_data_o;
  logic [$clog2(Depth)-1:0] rs2_addr_i = '0;
  logic [        Width-1:0] rs2_data_o;
  logic [$clog2(Depth)-1:0] rd_addr_i  = '0;
  logic [        Width-1:0] rd_data_i  = '0;
  logic                     rd_we_i    = 1'b0;

  panda_register_file #(
    .Width(Width),
    .Depth(Depth)
  ) dut (
    .clk_i     (clk_i     ),
    .rst_ni    (rst_ni    ),
    .rs1_addr_i(rs1_addr_i),
    .rs1_data_o(rs1_data_o),
    .rs2_addr_i(rs2_addr_i),
    .rs2_data_o(rs2_data_o),
    .rd_addr_i (rd_addr_i ),
    .rd_data_i (rd_data_i ),
    .rd_we_i   (rd_we_i   )
  );

  function void display();
    $display("rs1_addr_i = %d, rs1_data_o = %h", rs1_addr_i, rs1_data_o);
    $display("rs2_addr_i = %d, rs2_data_o = %h", rs2_addr_i, rs2_data_o);
    $display("rd_addr_i  = %d, rd_data_i  = %h, rd_we_i = %b",
      rd_addr_i, rd_data_i, rd_we_i);
    $display("-------------------");
  endfunction : display

  always #5 clk_i = ~clk_i;

  initial begin
    rst_ni = 1'b0;
    #25 rst_ni = 1'b1;
    for (int i = 0; i < 64; i++) begin
      #5 rs1_addr_i = i - 1;
      rs2_addr_i = i;
      rd_addr_i = i;
      rd_data_i = $urandom();
      rd_we_i = $urandom_range(0,1);
      #1 display(); #4;
    end
    #10 $finish;
  end

endmodule
