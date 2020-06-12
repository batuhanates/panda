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

  /*==================================================
  =            Pipeline Register Typedefs            =
  ==================================================*/

  typedef struct {
    logic [31:0] instr;
    logic [31:0] pc;
    logic [31:0] pc_inc;
  } if_id_t;

  typedef struct {
    op_a_sel_e     op_a_sel;
    op_b_sel_e     op_b_sel;
    alu_operator_e alu_operator;
    logic [31:0]   imm;
    logic [31:0]   rs1_data;
    logic [31:0]   rs2_data;
    logic [ 4:0]   rs1_addr;
    logic [ 4:0]   rs2_addr;
    rd_data_sel_e  rd_data_sel;
    logic [ 4:0]   rd_addr;
    logic          rd_we;
    logic          lsu_store;
    lsu_width_e    lsu_width;
    logic          lsu_load_unsigned;
    logic          branch;
    logic          jump;
    logic [31:0]   pc;
    logic [31:0]   pc_inc;
  } id_ex_t;

  typedef struct {
    logic [31:0]  pc_inc;
    logic         lsu_store;
    lsu_width_e   lsu_width;
    logic         lsu_load_unsigned;
    logic [31:0]  alu_result;
    logic [31:0]  imm;
    logic [31:0]  rs2_data;
    logic [ 4:0]  rs2_addr;
    rd_data_sel_e rd_data_sel;
    logic [ 4:0]  rd_addr;
    logic         rd_we;
  } ex_mem_t;

  typedef struct {
    logic [31:0]  pc_inc;
    logic [31:0]  alu_result;
    logic [31:0]  load_data;
    logic [31:0]  imm;
    rd_data_sel_e rd_data_sel;
    logic [ 4:0]  rd_addr;
    logic         rd_we;
  } mem_wb_t;

  /*=====  End of Pipeline Register Typedefs  ======*/

endpackage
