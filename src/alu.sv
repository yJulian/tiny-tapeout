module mima_alu #(
    parameter integer ADDR_WIDTH = 20,
    parameter integer DATA_WIDTH = 24
)(
    input wire [DATA_WIDTH-1:0] X,
    input wire [DATA_WIDTH-1:0] Y,
    input wire [3:0] OP,
    input wire clk,
    output logic [DATA_WIDTH-1:0] Z,
    output logic flag_neg,
    output logic flag_zero
);

always @(posedge clk) begin
    case (OP)
        4'h0: Z <= X + Y;
        4'h1: Z <= X - Y;
        4'h2: Z <= X & Y;
        4'h3: Z <= X | Y;
        4'h4: Z <= X ^ Y;
        4'h5: Z <= X << Y;
        4'h6: Z <= X >> Y;
        4'h7: Z <= X < Y;
        4'h8: Z <= X <= Y;
        4'h9: Z <= X == Y;
        4'hA: Z <= X != Y;
        4'hB: Z <= X > Y;
        4'hC: Z <= X >= Y;
        default: Z <= 0;
    endcase

    assign flag_neg = Z[DATA_WIDTH-1];
    assign flag_zero = (Z == 0);
end

endmodule
