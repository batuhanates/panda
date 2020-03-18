// Panda Core
// Batuhan Ates
// https://github.com/batuhanates

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

endpackage
