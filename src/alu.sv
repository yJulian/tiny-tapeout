module alu #(
    parameter integer DATA_WIDTH = 8
)(
    input  wire [DATA_WIDTH-1:0] X,
    input  wire [DATA_WIDTH-1:0] Y,
    input  wire [2:0] OP,
    input  wire clk,
    input wire en,
    output logic [DATA_WIDTH-1:0] Z
);

always_ff @(posedge clk) begin
    if (en) begin
        case (OP)
            3'b000: Z <= X + Y;
            3'b001: Z <= X - Y;
            3'b010: Z <= X & Y;
            3'b011: Z <= X | Y;
            3'b100: Z <= X ^ Y;
            3'b101: Z <= X << Y;
            3'b110: Z <= X >> Y;
            3'b111: Z <= 8'(X < Y);
            default: Z <= 0;
        endcase
    end
end

endmodule
