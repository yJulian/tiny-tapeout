`default_nettype none

module tt_um_yjulian_alu #(
    parameter DATA_WIDTH = 8
) (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);
  assign uio_out = 8'b0;
  assign uio_oe  = 8'b0;

  wire we, alu_en, peri_en;
  wire [2:0] imm;
  wire [2:0] addr_A, addr_B, addr_Z, addr_oio;
  wire [DATA_WIDTH-1:0] A, B, Z, r_data_oio;

  assign uo_out = r_data_oio;

  decoder decoder_inst (
      .op(uio_in[4:0]),
      .we(we),
      .alu_en(alu_en),
      .peri_en(peri_en),
      .imm(imm)
  );

  register_file #(
      .ADDR_WIDTH(3),
      .DATA_WIDTH(DATA_WIDTH)
  ) register_file_inst (
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
      .r_data3(r_data_oio),
      .alu_en(alu_en),
      .Z_addr(addr_Z),
      .Z_data(Z)
  );

  periphery periphery_inst (
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

  alu #(
      .DATA_WIDTH(DATA_WIDTH)
  ) alu_inst (
      .en(alu_en),
      .OP(imm),
      .X(A),
      .Y(B),
      .Z(Z)
  );
endmodule
