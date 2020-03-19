// Panda Core
// Batuhan Ates
// https://github.com/batuhanates

`timescale 1ns/1ps

module panda_alu_tb ();
  import panda_pkg::*;

  panda_pkg::alu_operator_e operator_i;
  logic [31:0]              operand_a_i;
  logic [31:0]              operand_b_i;
  logic [31:0]              result_o;

  panda_alu uut (
    .operator_i (operator_i ),
    .operand_a_i(operand_a_i),
    .operand_b_i(operand_b_i),
    .result_o   (result_o   )
  );

  bit [0:5][31:0] list_a = {
    30, 30, -62, -35, -134, -12
  };
  bit [0:5][31:0] list_b = {
    3, 50, 5, -97, -90, -12
  };

  initial begin : proc_stim
    operator_i = operator_i.last();
    operand_a_i = 0;
    operand_b_i = 0;
    for (int i = 0; i < 6; i++) begin
      for (int k = 0; k < 14; k++) begin
        #5 operator_i = operator_i.next();
        operand_a_i = list_a[i];
        operand_b_i = list_b[i];
        #5 $display("Operator=%s", operator_i.name());
        $display("A=%d, %d, %b", $signed(operand_a_i), operand_a_i, operand_a_i);
        $display("B=%d, %d, %b", $signed(operand_b_i), operand_b_i, operand_b_i);
        $display("R=%d, %d, %b", $signed(result_o), result_o, result_o);
      end
    end
    $finish;
  end

endmodule
