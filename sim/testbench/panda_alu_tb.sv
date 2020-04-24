// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

`timescale 1ns/1ps

module panda_alu_tb ();
  import panda_pkg::*;

  parameter Width = 32;

  panda_pkg::alu_operator_e operator;
  logic [Width-1:0]         operand_a;
  logic [Width-1:0]         operand_b;
  logic [Width-1:0]         result;

  panda_alu #(
    .Width(Width)
  ) dut (
    .operator_i (operator ),
    .operand_a_i(operand_a),
    .operand_b_i(operand_b),
    .result_o   (result   )
  );

  logic [Width-1:0] list_a [0:5] = '{
    30, 30, -62, -35, -134, -12
  };
  logic [Width-1:0] list_b [0:5] = '{
    3, 50, 5, -97, -90, -12
  };

  initial begin : proc_stim
    operator = operator.last();
    operand_a = 0;
    operand_b = 0;
    for (int i = 0; i < 6; i++) begin
      for (int k = 0; k < 14; k++) begin
        #5 operator = operator.next();
        operand_a = list_a[i];
        operand_b = list_b[i];
        #5 $display("Operator=%s", operator.name());
        $display("A=%d, %d, %b", $signed(operand_a), operand_a, operand_a);
        $display("B=%d, %d, %b", $signed(operand_b), operand_b, operand_b);
        $display("R=%d, %d, %b", $signed(result), result, result);
      end
    end
    $finish;
  end

endmodule
