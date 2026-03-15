/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_yjulian_alu #(
    parameter DATA_WIDTH = 8
) (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  assign uio_out = 0;
  assign uio_oe  = 8'b0000_0000;

  wire _unused = &{ena, uio_in[7:5]};

  wire we;
  wire alu_en;
  wire peri_en;
  wire [2:0] imm;

  wire [2:0] addr_A;
  wire [2:0] addr_B;
  wire [2:0] addr_Z;
  wire [2:0] addr_oio;

  wire [DATA_WIDTH-1:0] A;
  wire [DATA_WIDTH-1:0] B;
  wire [DATA_WIDTH-1:0] Z;
  reg [DATA_WIDTH-1:0] oio_out_reg;

  assign uo_out = oio_out_reg;

  decoder decoder (
      .clk(clk),
      .rst_n(rst_n),
      .op(uio_in[4:0]),
      .we(we),
      .alu_en(alu_en),
      .peri_en(peri_en),
      .imm(imm)
  );

  register_file #(
      .ADDR_WIDTH(3),
      .DATA_WIDTH(DATA_WIDTH)
  ) register_file (
      .clk(clk),
      .rst_n(rst_n),
      .we(we),
      .w_addr(imm),
      .w_data(ui_in),
      .r_addr1(addr_A),
      .r_data1(A),
      .r_addr2(addr_B),
      .r_data2(B),
      .r_addr3(addr_oio),
      .r_data3(oio_out_reg),
      .alu_en(alu_en),
      .Z_addr(addr_Z),
      .Z_data(Z)
  );

  periphery periphery (
      .clk(clk),
      .en(peri_en),
      .rst_n(rst_n),
      .op(imm),
      .data_in(ui_in),
      .addr_A(addr_A),
      .addr_B(addr_B),
      .addr_Z(addr_Z),
      .addr_oio(addr_oio)
  );

  // ALU-Instanz
  alu #(
      .DATA_WIDTH(DATA_WIDTH)
  ) alu (
      .en(alu_en),
      .OP(imm),
      .X(A),
      .Y(B),
      .Z(Z)
  );

endmodule
