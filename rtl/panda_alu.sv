// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_alu #(
  parameter int unsigned Width = 32
) (
  input  panda_pkg::alu_operator_e operator_i,
  input  logic [Width-1:0]         operand_a_i,
  input  logic [Width-1:0]         operand_b_i,
  output logic [Width-1:0]         result_o
);
  import panda_pkg::*;

  /*=============================
  =            Adder            =
  =============================*/
  logic             adder_sub;
  logic [Width-1:0] adder_result;

  // For subtract and any comparison operator, adder operates on subtract mode.
  always_comb begin
    adder_sub = 1'b0;
    unique case (operator_i)
      ALU_SUB,
      ALU_SLT,
      ALU_SLTU : adder_sub = 1'b1;
      default  : ;
    endcase
  end

  panda_adder #(
    .Width(Width)
  ) i_adder (
    .operand_a_i(operand_a_i ),
    .operand_b_i(operand_b_i ),
    .subtract_i (adder_sub   ),
    .result_o   (adder_result)
  );
  /*=====  End of Adder  ======*/

  /*==================================
  =            Comparator            =
  ==================================*/
  logic cmp_signed;
  logic is_less;

  assign cmp_signed = operator_i == ALU_SLT;

  // is_equal is not used.
  panda_comparator_sub #(
    .Width(Width)
  ) i_comparator (
    .sub_result_i(adder_result        ),
    .msb_a_i     (operand_a_i[Width-1]),
    .msb_b_i     (operand_b_i[Width-1]),
    .sign_i      (cmp_signed          ),
    .is_less_o   (is_less             )
  );
  /*=====  End of Comparator  ======*/

  /*===============================
  =            Shifter            =
  ===============================*/
  logic                     shift_left;
  logic                     shift_arithmetic;
  logic [$clog2(Width)-1:0] shift_amount;
  logic [        Width-1:0] shift_result;

  assign shift_left       = operator_i == ALU_SLL;
  assign shift_arithmetic = operator_i == ALU_SRA;
  assign shift_amount     = operand_b_i[$clog2(Width)-1:0];

  panda_shifter #(
    .Width(Width)
  ) i_shifter (
    .left_i      (shift_left      ),
    .arithmetic_i(shift_arithmetic),
    .operand_i   (operand_a_i     ),
    .amount_i    (shift_amount    ),
    .result_o    (shift_result    )
  );
  /*=====  End of Shifter  ======*/

  always_comb begin : proc_result_mux
    result_o = '0;
    unique case (operator_i)
      ALU_ADD,
      ALU_SUB : result_o = adder_result;

      ALU_AND : result_o = operand_a_i & operand_b_i;
      ALU_OR  : result_o = operand_a_i | operand_b_i;
      ALU_XOR : result_o = operand_a_i ^ operand_b_i;

      ALU_SLL,
      ALU_SRL,
      ALU_SRA : result_o = shift_result;

      ALU_SLT,
      ALU_SLTU : result_o = {{Width-1{1'b0}}, is_less};

      default : ;
    endcase
  end

endmodule
