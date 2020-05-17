// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

`timescale 1ns/1ps

module panda_sc_core_tb ();

  parameter int unsigned InstrMemDepth = 32;
  parameter InstrMemInitFile = "modmult_instr.mem";
  parameter int unsigned DataMemDepth = 32;
  parameter DataMemInitFile = "modmult_data.mem";

  logic clk   = 1'b0;
  logic rst_n = 1'b0;

  logic [31:0] data_rdata;
  logic [31:0] data_wdata;
  logic [31:0] data_addr;
  logic [ 3:0] data_we;

  logic [31:0] instr_rdata;
  logic [31:0] instr_addr;

  panda_sc_core dut (
    .clk_i        (clk        ),
    .rst_ni       (rst_n      ),
    .data_rdata_i (data_rdata ),
    .data_wdata_o (data_wdata ),
    .data_addr_o  (data_addr  ),
    .data_we_o    (data_we    ),
    .instr_rdata_i(instr_rdata),
    .instr_addr_o (instr_addr )
  );

  panda_ram #(
    .DataWidth (32              ),
    .Depth     (InstrMemDepth   ),
    .OutputReg (1'b0            ),
    .WriteFirst(1'b0            ),
    .InitFile  (InstrMemInitFile)
  ) i_instruction_memory (
    .clk_i (clk                                  ),
    .ce_i  (1'b1                                 ),
    .we_i  (4'b0                                 ),
    .addr_i(instr_addr[$clog2(InstrMemDepth)+1:2]),
    .data_i(32'b0                                ),
    .data_o(instr_rdata                          )
  );

  panda_ram #(
    .DataWidth (32             ),
    .Depth     (DataMemDepth   ),
    .OutputReg (1'b0           ),
    .WriteFirst(1'b0           ),
    .InitFile  (DataMemInitFile)
  ) i_data_memory (
    .clk_i (clk                                ),
    .ce_i  (1'b1                               ),
    .we_i  (data_we                            ),
    .addr_i(data_addr[$clog2(DataMemDepth)+1:2]),
    .data_i(data_wdata                         ),
    .data_o(data_rdata                         )
  );

  always #5 clk = ~clk;

  initial begin : proc_stim
    #20 rst_n = 1'b1;
  end

endmodule
