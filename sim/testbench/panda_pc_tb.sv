// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

`timescale 1ns/1ps

module panda_pc_tb ();

  parameter int unsigned Width = 32;

  logic clk         = 1'b0;
  logic rst_n       = 1'b0;
  logic stall       = 1'b0;
  logic change_flow = 1'b0;

  logic [Width-1:0] target_address = 0;
  logic [Width-1:0] pc;
  logic [Width-1:0] pc_inc;

  panda_pc #(
    .Width(Width)
  ) dut (
    .clk_i           (clk           ),
    .rst_ni          (rst_n         ),
    .stall_i         (stall         ),
    .change_flow_i   (change_flow   ),
    .target_address_i(target_address),
    .pc_o            (pc            ),
    .pc_inc_o        (pc_inc        )
  );

  always #5 clk = ~clk;

  initial begin : proc_stim
    #10 rst_n = 1'b1;
    target_address = 24;
    #30 change_flow = 1'b1;
    #10 change_flow = 1'b0;
    #30 stall = 1'b1;
    #10 stall = 1'b0;
    #35 $finish;
  end

endmodule
