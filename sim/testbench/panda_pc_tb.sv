// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_pc_tb ();

  parameter int unsigned Width = 32;

  logic clk    = 1'b0;
  logic rst_n  = 1'b0;
  logic branch = 1'b0;
  logic jump   = 1'b0;

  logic [Width-1:0] branch_target = 0;
  logic [Width-1:0] jump_target   = 0;
  logic [Width-1:0] pc;
  logic [Width-1:0] pc_inc;

  panda_pc #(
    .Width(Width)
  ) dut (
    .clk_i          (clk          ),
    .rst_ni         (rst_n        ),
    .branch_i       (branch       ),
    .jump_i         (jump         ),
    .branch_target_i(branch_target),
    .jump_target_i  (jump_target  ),
    .pc_o           (pc           ),
    .pc_inc_o       (pc_inc       )
  );

  always #5 clk = ~clk;

  initial begin : proc_stim
    #10 rst_n = 1'b1;
    branch_target = 24;
    jump_target = 56;
    #30 branch = 1'b1;
    #10 branch = 1'b0;
    #30 jump = 1'b1;
    #10 jump = 1'b0;
    #35 $finish;
  end

endmodule
