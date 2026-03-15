`timescale 1ns/1ps

module tb_project;
    reg [7:0] ui_in;
    wire [7:0] uo_out;
    reg [7:0] uio_in;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    reg clk;
    reg rst_n;
    reg ena;

    // Instanz des Top-Moduls
    tt_um_yjulian_alu dut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

    // Taktgenerierung (10ns -> 100MHz)
    always #5 clk = ~clk;

    initial begin
        // VCD Datei für GTKWave
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_project);

        // Initialisierung
        clk = 0;
        rst_n = 0;
        ena = 1;
        ui_in = 0;
        uio_in = 0;

        #20 rst_n = 1; // Reset aufheben
        #10;

        // 1. Wert 10 in Register 0 schreiben (MEM OP: 01xxx)
        ui_in = 8'd15;
        uio_in = 5'b01000;
        #10;

        // 2. Wert 20 in Register 1 schreiben
        ui_in = 8'd20;
        uio_in = 5'b01001;
        #10;

        // 3. Peripherie konfigurieren: Setze addr_A auf Reg 0 (DATAFLOW OP: 10xxx)
        // op = 3'b000 (addr_A), data = 0
        ui_in = 8'd0;
        uio_in = 5'b10000;
        #10;

        // 4. Peripherie konfigurieren: Setze addr_B auf Reg 1
        // op = 3'b001 (addr_B), data = 1
        ui_in = 8'd1;
        uio_in = 5'b10001;
        #10;

        // 5. Peripherie konfigurieren: Setze addr_Z (Ziel) auf Reg 2
        // op = 3'b010 (addr_Z), data = 2
        ui_in = 8'd2;
        uio_in = 5'b10010;
        #10;

        // 6. ALU-Operation: ADD (ALU OP: 00xxx)
        // op = 3'b000 (ADD)
        uio_in = 5'b00000;
        #10;

        // 7. Ergebnis prüfen: Setze addr_oio auf Reg 2, um Z zu sehen
        ui_in = 8'd2;
        uio_in = 5'b10011;
        #10;

        #50;
        $display("Test beendet. Ergebnis uo_out: %d", uo_out);
        $finish;
    end
endmodule
