module decoder (
    input  logic [4:0]  op,
    output logic we,
    output logic alu_en,
    output logic peri_en,
    output logic [2:0] imm
);
    // Kombinatorisch, damit Steuersignale sofort anliegen
    always_comb begin
        case (op[4:3])
            2'b00: begin    // ALU OP
                we      = 1'b0;
                alu_en  = 1'b1;
                peri_en = 1'b0;
                imm     = op[2:0];
            end
            2'b01: begin    // MEM OP (Load ui_in to Reg)
                we      = 1'b1;
                alu_en  = 1'b0;
                peri_en = 1'b0;
                imm     = op[2:0];
            end
            2'b10: begin    // DATAFLOW OP (Config Periphery)
                we      = 1'b0;
                alu_en  = 1'b0;
                peri_en = 1'b1;
                imm     = op[2:0];
            end
            default: begin
                we      = 1'b0;
                alu_en  = 1'b0;
                peri_en = 1'b0;
                imm     = 3'b000;
            end
        endcase
    end
endmodule
