// Copyright 2020 Batuhan Ates, Ozgur Deniz Temel
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// Panda Core <https://github.com/batuhanates/panda>

`timescale 1ns/1ps

module panda_sc_load_store_unit_tb ();
  import panda_pkg::*;

  logic        store;
  logic        load_unsigned;
  lsu_width_e  width;
  logic [31:0] addr;
  logic [31:0] store_data;
  logic [31:0] load_data;
  logic [31:0] data_rdata;
  logic [31:0] data_wdata;
  logic [31:0] data_addr;
  logic [ 3:0] data_we;

  panda_sc_load_store_unit dut (
    .store_i        (store        ),
    .load_unsigned_i(load_unsigned),
    .width_i        (width        ),
    .addr_i         (addr         ),
    .store_data_i   (store_data   ),
    .load_data_o    (load_data    ),
    .data_rdata_i   (data_rdata   ),
    .data_wdata_o   (data_wdata   ),
    .data_addr_o    (data_addr    ),
    .data_we_o      (data_we      )
  );

  initial begin : proc_stim
    store = 1'b0;
    load_unsigned = 1'b0;
    width = LSU_WIDTH_BYTE;
    addr = '0;
    store_data = '0;
    data_rdata = '0;

    #10 data_rdata = 32'h89AB67EF;
    store_data = 32'h12345678;

    for (addr = 0; addr < 4; addr++) begin
      for (int i = 0; i < 3; i++) begin
        width = width.next();
        load_unsigned = 1'b0; store = 1'b0;
        #10 store = 1'b1;
        #10 load_unsigned = 1'b1; store = 1'b0;
        #10 store = 1'b1;
        #10;
      end
    end
    #10 $finish;
  end
endmodule
