// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_controller (
  input  logic load_use_hazard_i,

  output logic stall_if_o,
  output logic bubble_id_o
);
  import panda_pkg::*;

  assign stall_if_o  = load_use_hazard_i;
  assign bubble_id_o = load_use_hazard_i;

endmodule
