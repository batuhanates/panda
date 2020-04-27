// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

package panda_pkg;

  typedef enum logic [3:0] {
    ALU_ADD,
    ALU_SUB,

    ALU_AND,
    ALU_OR,
    ALU_XOR,

    ALU_SLL,
    ALU_SRL,
    ALU_SRA,

    ALU_EQ,
    ALU_NE,
    ALU_LT,
    ALU_LTU,
    ALU_GE,
    ALU_GEU
  } alu_operator_e;

  typedef enum logic [6:0] {
    OPCODE_LOAD     = 7'b0000011,
    OPCODE_MISC_MEM = 7'b0001111,
    OPCODE_OP_IMM   = 7'b0010011,
    OPCODE_AUIPC    = 7'b0010111,
    OPCODE_STORE    = 7'b0100011,
    OPCODE_OP       = 7'b0110011,
    OPCODE_LUI      = 7'b0110111,
    OPCODE_BRANCH   = 7'b1100011,
    OPCODE_JALR     = 7'b1100111,
    OPCODE_JAL      = 7'b1101111,
    OPCODE_SYSTEM   = 7'b1110011
  } opcode_e;

endpackage
