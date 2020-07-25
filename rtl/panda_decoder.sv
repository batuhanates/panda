// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

module panda_decoder (
  input  logic [31:0]              instr_i,

  output logic [ 4:0]              rs1_addr_o,
  output logic [ 4:0]              rs2_addr_o,
  output logic [ 4:0]              rd_addr_o,
  output logic                     rd_we_o,
  output panda_pkg::op_a_sel_e     op_a_sel_o,
  output panda_pkg::op_b_sel_e     op_b_sel_o,
  output panda_pkg::rd_data_sel_e  rd_data_sel_o,
  output panda_pkg::alu_operator_e alu_operator_o,
  output logic                     lsu_store_o,
  output panda_pkg::lsu_width_e    lsu_width_o,
  output logic                     lsu_load_unsigned_o,
  output logic [31:0]              imm_o,

  output logic                     jal_o,
  output logic                     jalr_o,
  output logic                     branch_o,
  output logic                     br_not_o,
  output logic                     br_unsigned_o,
  output logic                     br_lt_o,

  output logic                     illegal_instr_o
);
  import panda_pkg::*;

  opcode_e    opcode;
  logic [2:0] funct3;
  logic [6:0] funct7;

  imm_sel_e    imm_sel;
  logic [31:0] imm_i_type;
  logic [31:0] imm_s_type;
  logic [31:0] imm_b_type;
  logic [31:0] imm_u_type;
  logic [31:0] imm_j_type;

  assign opcode = opcode_e'(instr_i[6:0]);
  assign funct3 = instr_i[14:12];
  assign funct7 = instr_i[31:25];

  // Register addresses are fixed in the instruction
  assign rs1_addr_o = instr_i[19:15];
  assign rs2_addr_o = instr_i[24:20];
  assign rd_addr_o  = instr_i[11:7];

  // All the immediate types
  assign imm_i_type = {{21{instr_i[31]}}, instr_i[30:20]};
  assign imm_s_type = {{21{instr_i[31]}}, instr_i[30:25], instr_i[11:7]};
  assign imm_b_type = {{20{instr_i[31]}}, instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
  assign imm_u_type = {instr_i[31:12], 12'b0};
  assign imm_j_type = {{12{instr_i[31]}}, instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};

  // Select the required immediate type depending on the instruction
  always_comb begin : proc_imm_mux
    unique case (imm_sel)
      IMM_I   : imm_o = imm_i_type;
      IMM_S   : imm_o = imm_s_type;
      IMM_B   : imm_o = imm_b_type;
      IMM_U   : imm_o = imm_u_type;
      IMM_J   : imm_o = imm_j_type;
      default : imm_o = '0;
    endcase
  end

  // Load/Store width and signed/unsigned load flags are kept in funct3 section
  assign lsu_width_o         = lsu_width_e'(funct3[1:0]);
  assign lsu_load_unsigned_o = funct3[2];

  // Control signals to choose which branch comparison to use
  assign {br_lt_o, br_unsigned_o, br_not_o} = funct3;

  always_comb begin : proc_decode
    rd_we_o     = 1'b0;
    lsu_store_o = 1'b0;
    jal_o       = 1'b0;
    jalr_o      = 1'b0;
    branch_o    = 1'b0;

    op_a_sel_o     = OP_A_PC;
    op_b_sel_o     = OP_B_IMM;
    rd_data_sel_o  = RD_DATA_ALU;
    alu_operator_o = ALU_ADD;
    imm_sel        = IMM_I;

    illegal_instr_o = 1'b0; // Unused for now

    unique case (opcode)
      OPCODE_LOAD : begin
        op_a_sel_o     = OP_A_RS1;
        op_b_sel_o     = OP_B_IMM;
        alu_operator_o = ALU_ADD;
        rd_data_sel_o  = RD_DATA_LOAD;
        rd_we_o        = 1'b1;
        imm_sel        = IMM_I;
      end

      OPCODE_OP_IMM : begin
        op_a_sel_o    = OP_A_RS1;
        op_b_sel_o    = OP_B_IMM;
        rd_data_sel_o = RD_DATA_ALU;
        rd_we_o       = 1'b1;

        unique case (funct3)
          3'b000 : alu_operator_o = ALU_ADD;  // Addition
          3'b010 : alu_operator_o = ALU_SLT;  // Set Less Then
          3'b011 : alu_operator_o = ALU_SLTU; // Set Less Than Unsigned
          3'b100 : alu_operator_o = ALU_XOR;  // XOR
          3'b110 : alu_operator_o = ALU_OR;   // OR
          3'b111 : alu_operator_o = ALU_AND;  // AND
          3'b001 : if (funct7 == 7'b000_0000) begin
            alu_operator_o = ALU_SLL; // Shift Left
          end else begin
            illegal_instr_o = 1'b1;
          end
          3'b101 : if (funct7 == 7'b000_0000) begin
            alu_operator_o = ALU_SRL; // Shift Right Logical
          end else if (funct7 == 7'b010_0000) begin
            alu_operator_o = ALU_SRA; // Shift Right Arithmetic
          end else begin
            illegal_instr_o = 1'b1;
          end
          default : illegal_instr_o = 1'b1;
        endcase
      end

      OPCODE_AUIPC : begin
        op_a_sel_o     = OP_A_PC;
        op_b_sel_o     = OP_B_IMM;
        alu_operator_o = ALU_ADD;
        rd_data_sel_o  = RD_DATA_ALU;
        rd_we_o        = 1'b1;
        imm_sel        = IMM_U;
      end

      OPCODE_STORE : begin
        op_a_sel_o     = OP_A_RS1;
        op_b_sel_o     = OP_B_IMM;
        alu_operator_o = ALU_ADD;
        lsu_store_o    = 1'b1;
        imm_sel        = IMM_S;
      end

      OPCODE_OP : begin
        op_a_sel_o    = OP_A_RS1;
        op_b_sel_o    = OP_B_RS2;
        rd_data_sel_o = RD_DATA_ALU;
        rd_we_o       = 1'b1;

        unique case ({funct7, funct3})
          {7'b000_0000, 3'b000} : alu_operator_o = ALU_ADD;  // Addition
          {7'b010_0000, 3'b000} : alu_operator_o = ALU_SUB;  // Subtrction
          {7'b000_0000, 3'b001} : alu_operator_o = ALU_SLL;  // Shift Left
          {7'b000_0000, 3'b010} : alu_operator_o = ALU_SLT;  // Set Less Than
          {7'b000_0000, 3'b011} : alu_operator_o = ALU_SLTU; // SLT Unsigned
          {7'b000_0000, 3'b100} : alu_operator_o = ALU_XOR;  // XOR
          {7'b000_0000, 3'b101} : alu_operator_o = ALU_SRL;  // Shift Right Logic
          {7'b010_0000, 3'b101} : alu_operator_o = ALU_SRA;  // Shift Right Arith
          {7'b000_0000, 3'b110} : alu_operator_o = ALU_OR;   // OR
          {7'b000_0000, 3'b111} : alu_operator_o = ALU_AND;  // AND
          default : illegal_instr_o = 1'b1;
        endcase
      end

      OPCODE_LUI : begin
        rd_data_sel_o = RD_DATA_IMM;
        rd_we_o       = 1'b1;
        imm_sel       = IMM_U;
      end

      OPCODE_BRANCH : begin
        imm_sel    = IMM_B;
        branch_o   = 1'b1;
        op_a_sel_o = OP_A_RS1;
        op_b_sel_o = OP_B_RS2;
      end

      OPCODE_JALR : begin
        rd_data_sel_o = RD_DATA_PC_INC;
        rd_we_o       = 1'b1;
        imm_sel       = IMM_I;
        jalr_o        = 1'b1;
        op_a_sel_o    = OP_A_RS1;
      end

      OPCODE_JAL : begin
        rd_data_sel_o = RD_DATA_PC_INC;
        rd_we_o       = 1'b1;
        imm_sel       = IMM_J;
        jal_o         = 1'b1;
      end

      default : illegal_instr_o = 1'b1;
    endcase
  end

endmodule
