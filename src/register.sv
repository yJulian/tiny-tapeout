module register_file #(
    parameter ADDR_WIDTH = 3,
    parameter DATA_WIDTH = 8
)(
    input wire clk,
    input wire rst_n,

    input wire we,
    input wire [ADDR_WIDTH-1:0] w_addr,
    input wire [DATA_WIDTH-1:0] w_data,

    input wire [ADDR_WIDTH-1:0] r_addr1,
    output wire [DATA_WIDTH-1:0] r_data1,

    input wire [ADDR_WIDTH-1:0] r_addr2,
    output wire [DATA_WIDTH-1:0] r_data2,

    input wire [ADDR_WIDTH-1:0] r_addr3,
    output wire [DATA_WIDTH-1:0] r_data3,

    input wire [ADDR_WIDTH-1:0] r_addr4,
    output wire [DATA_WIDTH-1:0] r_data4
);
    localparam NUM_REGS = 1 << ADDR_WIDTH;

    reg [DATA_WIDTH-1:0] registers [0:NUM_REGS-1];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            integer i;
            for (i = 0; i < NUM_REGS; i = i + 1) begin
                registers[i] <= {DATA_WIDTH{1'b0}};
            end
        end else if (we) begin
            registers[w_addr] <= w_data;
        end
    end

    assign r_data1 = registers[r_addr1];
    assign r_data2 = registers[r_addr2];
    assign r_data3 = registers[r_addr3];
    assign r_data4 = registers[r_addr4];

endmodule
