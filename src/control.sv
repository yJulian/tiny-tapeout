module mima_control #(
    parameter ADDR_WIDTH = 20,
    parameter DATA_WIDTH = 24
) (
    input wire clk,
    input wire rst,
    input wire [ADDR_WIDTH-1:0] pc,
    input wire [DATA_WIDTH-1:0] ir,
    output reg [ADDR_WIDTH-1:0] addr
);


endmodule
