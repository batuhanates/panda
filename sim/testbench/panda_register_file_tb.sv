// Copyright 2020 Batuhan Ates
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

`timescale 1ns/1ps

module panda_register_file_tb ();

  logic        clk_i      = 1'b0;
  logic        rst_ni     = 1'b0;
  logic [ 4:0] rs1_addr_i = '0;
  logic [31:0] rs1_data_o;
  logic [ 4:0] rs2_addr_i = '0;
  logic [31:0] rs2_data_o;
  logic [ 4:0] rd_addr_i  = '0;
  logic [31:0] rd_data_i  = '0;
  logic        rd_we_i    = 1'b0;

  panda_register_file dut (
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
    $display("-------------------");
    $display("rs1_addr_i = %d", rs1_addr_i);
    $display("rs1_data_o = %h", rs1_data_o);
    $display("rs2_addr_i = %d", rs2_addr_i);
    $display("rs2_data_o = %h", rs2_data_o);
    $display("rd_addr_i  = %d", rd_addr_i);
    $display("rd_data_i  = %h", rd_data_i);
    $display("rd_we_i    = %b", rd_we_i);
    $display("-------------------");
  endfunction : display

  always #5 clk_i = ~clk_i;

  initial begin
    rst_ni = 1'b0;
    #25 rst_ni = 1'b1;
    for (int i = 0; i < 64; i++) begin
      #1 rs1_addr_i = i - 1;
      rs2_addr_i = i;
      rd_addr_i = i;
      rd_data_i = $urandom();
      rd_we_i = $urandom_range(0,1);
      #1 display(); #8;
    end
    #10 $finish;
  end

endmodule
