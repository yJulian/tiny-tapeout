module decoder (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [4:0]  op,
    output logic we,
    output logic alu_en,
    output logic peri_en,
    output logic [2:0] imm
);
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        we    <= '0;
        alu_en <= '0;
        peri_en <= '0;
        imm <= '0;
    end else begin
        case (op[4:3])
        2'b00: begin    // ALU OP
            we    <= '0;
            alu_en <= '1;
            peri_en <= '0;
            imm <= op[2:0];
        end
        2'b01: begin    // MEM OP
            we    <= '1;
            alu_en <= '0;
            peri_en <= '0;
            imm <= op[2:0];
        end
        2'b10: begin    // DATAFLOW OP
            we    <= '0;
            alu_en <= '0;
            peri_en <= '1;
            imm <= op[2:0];
        end
        default: begin
            we    <= '0;
            alu_en <= '0;
            peri_en <= '0;
            imm <= '0;
        end
        endcase
    end
end
endmodule
