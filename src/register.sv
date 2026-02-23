module register #(
    parameter int REGISTERS  = 8,
    parameter int DATA_WIDTH = 24
) (
    input  wire                      clk,
    input  wire                      rst,
    // Addressing
    input  wire [$clog2(REGISTERS)-1:0] read_reg,
    input  wire [$clog2(REGISTERS)-1:0] write_reg,
    input wire                       write_en,
    // Data
    output logic [DATA_WIDTH-1:0]     read_data,
    input  wire [DATA_WIDTH-1:0]     write_data
);

// Register Set
reg [DATA_WIDTH-1:0] registers [REGISTERS-1:0];

always @(posedge clk) begin
    if (rst) begin
        integer i;
        for (i = 0; i < REGISTERS; i = i + 1)
            registers[i] <= '0;
        read_data <= '0;
    end else begin
        if (write_en) begin
            registers[write_reg] <= write_data;
        end
        read_data <= registers[read_reg];
    end
end

endmodule
