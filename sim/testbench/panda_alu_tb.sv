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

  initial begin : proc_stim
    operand_a_i = 20;
    operand_b_i = 7;
    operator_i = operator_i.first;
    for (int i = 0; i < 13; i++) begin
      #10 operator_i = operator_i.next;
    end

    operand_b_i = 50;
    operator_i = operator_i.first;
    for (int i = 0; i < 13; i++) begin
      #10 operator_i = operator_i.next;
    end

    operand_a_i = -62;
    operator_i = operator_i.first;
    for (int i = 0; i < 13; i++) begin
      #10 operator_i = operator_i.next;
    end

    operand_b_i = -90;
    operator_i = operator_i.first;
    for (int i = 0; i < 13; i++) begin
      #10 operator_i = operator_i.next;
    end

    operand_a_i = -134;
    operator_i = operator_i.first;
    for (int i = 0; i < 13; i++) begin
      #10 operator_i = operator_i.next;
    end

    operand_b_i = -134;
    operator_i = operator_i.first;
    for (int i = 0; i < 13; i++) begin
      #10 operator_i = operator_i.next;
    end
    $finish;
  end

endmodule
