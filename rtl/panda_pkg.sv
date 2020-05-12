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
    OPCODE_LOAD     = 7'b000_0011,
    OPCODE_MISC_MEM = 7'b000_1111,
    OPCODE_OP_IMM   = 7'b001_0011,
    OPCODE_AUIPC    = 7'b001_0111,
    OPCODE_STORE    = 7'b010_0011,
    OPCODE_OP       = 7'b011_0011,
    OPCODE_LUI      = 7'b011_0111,
    OPCODE_BRANCH   = 7'b110_0011,
    OPCODE_JALR     = 7'b110_0111,
    OPCODE_JAL      = 7'b110_1111,
    OPCODE_SYSTEM   = 7'b111_0011
  } opcode_e;

  typedef enum logic [3:0] {
    IMM_I,
    IMM_S,
    IMM_B,
    IMM_U,
    IMM_J
  } imm_sel_e;

  typedef enum logic {
    OP_A_RS1,
    OP_A_PC
  } op_a_sel_e;

  typedef enum logic {
    OP_B_RS2,
    OP_B_IMM
  } op_b_sel_e;

  typedef enum logic [1:0] {
    RD_DATA_ALU,
    RD_DATA_LOAD,
    RD_DATA_PC_INC,
    RD_DATA_IMM
  } rd_data_sel_e;

  typedef enum logic [1:0] {
    LSU_WIDTH_BYTE,
    LSU_WIDTH_HALF,
    LSU_WIDTH_WORD
  } lsu_width_e;

endpackage
