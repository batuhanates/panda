// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

/**
* Load Store Unit
*
* Handles loads and stores with data memory.
* Assumes that the address is correctly alligned.
*/
module panda_sc_load_store_unit (
  input  logic        load_store_i,    // 1 for store
  input  logic        load_unsigned_i, // 1 for unsigned extended load
  input  logic [ 1:0] width_i,         // byte, half, word
  input  logic [31:0] addr_i,
  input  logic [31:0] store_data_i,    // data read from register
  output logic [31:0] load_data_o,     // data to write to register

  input  logic [31:0] data_rdata_i,    // data read from memory
  output logic [31:0] data_wdata_o,    // data to store to memory
  output logic [31:0] data_addr_o,
  output logic [ 3:0] data_we_o
);

  logic [31:0] load_byte;
  logic [31:0] load_half;
  logic [31:0] load_word;

  logic [31:0] store_byte;
  logic [31:0] store_half;
  logic [31:0] store_word;

  logic [3:0] data_we_byte;
  logic [3:0] data_we_half;
  logic [3:0] data_we_word;
  logic [3:0] data_we_tmp;

  assign data_addr_o = addr_i;

  /*============================
  =            Load            =
  ============================*/
  always_comb begin : proc_load_data
    load_byte   = '0;
    load_half   = '0;
    load_data_o = '0;

    // Select one of the 4 bytes of the word read from memory
    unique case (addr_i[1:0])
      2'b00   : load_byte[7:0] = data_rdata_i[7:0];
      2'b01   : load_byte[7:0] = data_rdata_i[15:8];
      2'b10   : load_byte[7:0] = data_rdata_i[23:16];
      2'b11   : load_byte[7:0] = data_rdata_i[31:24];
      default : ;
    endcase
    // Extend with zero or sign
    load_byte[31:8] = {24{load_unsigned_i ? 1'b0 : load_byte[7]}};

    // Select lower or upper half of the word read from memory
    unique case (addr_i[1])
      1'b0    : load_half[15:0] = data_rdata_i[15:0];
      1'b1    : load_half[15:0] = data_rdata_i[31:16];
      default : ;
    endcase
    // Extend with zero or sign
    load_half[31:16] = {16{load_unsigned_i ? 1'b0 : load_half[15]}};

    // Take the word directly
    load_word = data_rdata_i;

    // MUX for choosing byte, half, or word
    unique case (width_i)
      2'b00   : load_data_o = load_byte;
      2'b01   : load_data_o = load_half;
      2'b10   : load_data_o = load_word;
      default : ;
    endcase
  end
  /*=====  End of Load  ======*/

  /*=============================
  =            Store            =
  =============================*/
  assign store_word = store_data_i;
  assign store_half = {2{store_data_i[15:0]}};
  assign store_byte = {4{store_data_i[7:0]}};

  // MUX for choosing byte, half, or word
  always_comb begin : proc_data_wdata
    data_wdata_o = store_word;
    unique case (width_i)
      2'b00   : data_wdata_o = store_byte;
      2'b01   : data_wdata_o = store_half;
      2'b10   : data_wdata_o = store_word;
      default : ;
    endcase
  end

  always_comb begin : proc_data_we
    data_we_byte = '0;
    data_we_half = '0;
    data_we_tmp  = '0;

    // Choose which byte of the memory word will be written
    unique case (addr_i[1:0])
      2'b00   : data_we_byte = 4'b0001;
      2'b01   : data_we_byte = 4'b0010;
      2'b10   : data_we_byte = 4'b0100;
      2'b11   : data_we_byte = 4'b1000;
      default : ;
    endcase

    // Choose which half of the memory word will be written
    unique case (addr_i[1])
      1'b0    : data_we_half = 4'b0011;
      1'b1    : data_we_half = 4'b1100;
      default : ;
    endcase

    // Write to whole word
    data_we_word = 4'b1111;

    // MUX for choosing write enable depending on width
    unique case (width_i)
      2'b00   : data_we_tmp = data_we_byte;
      2'b01   : data_we_tmp = data_we_half;
      2'b10   : data_we_tmp = data_we_word;
      default : ;
    endcase
    // AND write enable with store enable signal
    data_we_o = data_we_tmp & {4{load_store_i}};
  end
  /*=====  End of Store  ======*/

endmodule
