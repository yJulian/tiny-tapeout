module mima_control_unit #(
    parameter int ADDR_WIDTH = 20,
    parameter int DATA_WIDTH = 24
) (
    input  logic                 clk,
    input  logic                 rst,

    // Current Instruction Register
    input  logic [DATA_WIDTH-1:0] IR,
    output  logic [ADDR_WIDTH-1:0] PC,

    // Optional status flags for branches (from ALU)
    input  logic                 flag_neg,
    input  logic                 flag_zero,

    // Control outputs
    output logic                 X_read,
    output logic                 X_write,
    output logic                 Y_read,
    output logic                 Y_write,
    output logic                 Z_read,
    output logic                 Z_write,
    output logic                 SAR_write,
    output logic                 SDR_read,
    output logic                 SDR_write,
    output logic                 mem_read,
    output logic                 mem_write,
    output logic                 one_write,
    output logic                 akku_read,
    output logic                 akku_write,
    output logic [3:0]           alu_op,

    // Bus steering outputs (statt "bus <= ...")
    output logic [3:0]           bus_src,
    output logic [3:0]           bus_dst,

    // Pipeline control
    output logic                 stall_fetch,
    output logic                 stall_decode,
    output logic                 flush_ifid
);

    // --------- IF/ID pipeline register ----------
    logic [DATA_WIDTH-1:0] IR_ifid;
    logic                  ifid_valid;

    // --------- ID/EX pipeline register ----------
    logic [3:0]            op_idex;
    logic [DATA_WIDTH-6:0] imm_idex;
    logic                  idex_valid;

    // microsequencer
    logic [7:0] upc;
    logic       ubusy;      // EX is executing micro-steps
    logic       ustart;     // load micro entry
    logic [7:0] uentry;

    // current control word (registered)
    typedef struct packed {
      logic        X_read, X_write;
      logic        Y_read, Y_write;
      logic        Z_read, Z_write;
      logic        SAR_read, SAR_write;
      logic        SDR_read, SDR_write;
      logic        mem_read, mem_write;
      logic        one_write;
      logic        akku_read, akku_write;
      logic [3:0]  alu_op;
      logic [3:0]  bus_src;
      logic [3:0]  bus_dst;
      logic        end_uop;     // marks end of microprogram
      logic [1:0]  next_sel;    // 0=upc+1,1=branch,2=end->idle,3=jump
      logic [7:0]  next_upc;    // for jump
    } uop_t;

    uop_t uop;

    // --------- Decode fields ----------
    wire logic [3:0] opcode   = IR_ifid[DATA_WIDTH-1 -: 4];
    wire logic [DATA_WIDTH-6:0] immediate = IR_ifid[DATA_WIDTH-6:0];
    wire logic no_pc_update_flag = 1'b0; // placeholder for instructions that don't update PC (e.g. jumps/branches)

    // --------- Pipeline stall policy ----------
    // While microcode is busy, stall front-end (simple multicycle EX)
    assign stall_fetch  = ubusy;
    assign stall_decode = ubusy;

    // Flush policy for jumps would go here; placeholder:
    assign flush_ifid = 1'b0;

    // --------- IF/ID register update ----------
    always_ff @(posedge clk) begin
      if (rst) begin
        IR_ifid    <= '0;
        ifid_valid <= 1'b0;
      end else if (!stall_fetch) begin
        IR_ifid    <= IR;
        ifid_valid <= 1'b1;
      end
    end

    // --------- ID/EX register update ----------
    always_ff @(posedge clk) begin
      if (rst) begin
        op_idex    <= '0;
        imm_idex   <= '0;
        idex_valid <= 1'b0;
      end else if (!stall_decode) begin
        op_idex    <= opcode;
        imm_idex   <= immediate;
        idex_valid <= ifid_valid;
      end
    end

    // --------- Microcode entry per opcode ----------
    // You map ISA opcodes to a microprogram start address.
    // Placeholder mapping; change to your MIMA ISA.
    always_comb begin
      unique case (op_idex)
        4'h0: uentry = 8'h10; // e.g. LDC
        4'h1: uentry = 8'h20; // e.g. LDV
        default: uentry = 8'h00; // NOP/illegal -> fetch only
      endcase
    end

    // Start microcode when we have a valid instruction and not busy
    assign ustart = idex_valid && !ubusy;

    // --------- Microsequencer state ----------
    always_ff @(posedge clk) begin
      if (rst) begin
        ubusy <= 1'b0;
        upc   <= 8'h00;
      end else begin
        if (ustart) begin
          ubusy <= 1'b1;
          upc   <= uentry;
        end else if (ubusy) begin
          // decide next upc based on uop.next_sel
          unique case (uop.next_sel)
            2'd0: upc <= upc + 8'd1;          // sequential
            2'd3: upc <= uop.next_upc;         // jump
            default: upc <= upc + 8'd1;
          endcase

          if (uop.end_uop) begin
            ubusy <= 1'b0;
            upc   <= 8'h00;
            if (!no_pc_update_flag) begin
              PC    <= PC + 1; // increment PC at end of microprogram
            end
          end
        end
      end
    end

    // --------- Microcode ROM ----------
    always_comb begin
      // defaults: everything off
      uop = '0;

      unique case (upc)

        // ---- LDC microprogram (example) ----
        // 0x10: bus <- immediate, AKKU <- bus, end
        8'h10: begin
          uop.bus_src   = 4'd1;   // 1=imm
          uop.bus_dst   = 4'd4;   // 4=akku
          uop.akku_write= 1'b1;
          uop.end_uop   = 1'b1;
          uop.next_sel  = 2'd2;
        end

        // ---- LDV microprogram skeleton (example) ----
        // 0x20: SAR <- imm(addr)
        8'h20: begin
          uop.bus_src   = 4'd1;   // imm
          uop.bus_dst   = 4'd5;   // SAR
          uop.SAR_write  = 1'b1;
          uop.next_sel  = 2'd0;
        end
        // 0x21: mem_read, SDR <- mem
        8'h21: begin
          uop.mem_read  = 1'b1;
          uop.SDR_write = 1'b1;
          uop.next_sel  = 2'd0;
        end
        // 0x22: bus <- SDR, AKKU <- bus, end
        8'h22: begin
          uop.bus_src   = 4'd3;   // 3=SDR
          uop.bus_dst   = 4'd4;   // akku
          uop.akku_write= 1'b1;
          uop.end_uop   = 1'b1;
          uop.next_sel  = 2'd2;
        end

        default: begin
          // idle: no controls
          uop = '0;
        end
      endcase
    end

    uop_t uop_r;

    always_ff @(posedge clk) begin
      if (rst) uop_r <= '0;
      else     uop_r <= uop;
    end

    // --------- Drive module outputs ----------
    always_comb begin
      X_read     = uop_r.X_read;
      X_write    = uop_r.X_write;
      Y_read     = uop_r.Y_read;
      Y_write    = uop_r.Y_write;
      Z_read     = uop_r.Z_read;
      Z_write    = uop_r.Z_write;
      SAR_write   = uop_r.SAR_write;
      SDR_read   = uop_r.SDR_read;
      SDR_write  = uop_r.SDR_write;
      mem_read   = uop_r.mem_read;
      mem_write  = uop_r.mem_write;
      one_write  = uop_r.one_write;
      akku_read  = uop_r.akku_read;
      akku_write = uop_r.akku_write;
      alu_op     = uop_r.alu_op;

      bus_src    = uop_r.bus_src;
      bus_dst    = uop_r.bus_dst;
    end

endmodule
