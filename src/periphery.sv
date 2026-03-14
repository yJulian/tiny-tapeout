module periphery #(
    parameter DATA_WIDTH = 8
)
(
    input clk,
    input en,
    input rst,
    input [2:0] op,
    input [DATA_WIDTH-1:0] data_in,
    output reg [2:0] addr_A,
    output reg [2:0] addr_B,
    output reg [2:0] addr_Z,
    output reg [2:0] addr_oio
);

reg [2:0] _addr_A;
reg [2:0] _addr_B;
reg [2:0] _addr_Z;
reg [2:0] _addr_oio;

assign addr_A = _addr_A;
assign addr_B = _addr_B;
assign addr_Z = _addr_Z;
assign addr_oio = _addr_oio;

always @(posedge clk) begin
    if (rst) begin
        _addr_A <= 0;
        _addr_B <= 0;
        _addr_Z <= 0;
        _addr_oio <= 0;
    end else if (en) begin
        case (op)
            3'b000: _addr_A <= data_in[2:0];
            3'b001: _addr_B <= data_in[2:0];
            3'b010: _addr_Z <= data_in[2:0];
            3'b011: _addr_oio <= data_in[2:0];
        endcase
    end
end

endmodule
