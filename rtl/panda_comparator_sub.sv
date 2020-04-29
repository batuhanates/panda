// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_comparator_sub #(
  parameter int unsigned Width = 32
) (
  input  logic [Width-1:0] sub_result_i, // Result of a - b
  input  logic             msb_a_i,      // sign bit of a
  input  logic             msb_b_i,      // sign bit of b
  input  logic             sign_i,       // signed comparison?
  output logic             is_equal_o,   // a == b
  output logic             is_less_o     // a < b
);

  // If a - b == 0 then a == b
  assign is_equal_o = sub_result_i == {Width{1'b0}};

  // If a and b have different signs, check MSB of b. For signed comparison
  // if MSB of b is 1 then a < b, and the opposite for unsigned comparison.
  // If a and b have the same sign, check subtraction's sign.
  // If a - b < 0 then a < b
  always_comb begin
    if (msb_a_i ^ msb_b_i) begin
      is_less_o = msb_b_i ^ sign_i;
    end else begin
      is_less_o = sub_result_i[Width-1];
    end
  end


endmodule
