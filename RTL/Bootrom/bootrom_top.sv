module bootrom_top
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------
    input  logic         clk,
    input  logic         rst_n,

    //------------------------------------------------------------
    // APB Read Interface
    //------------------------------------------------------------
    input  logic         rd_en,
    input  logic [31:0]  addr,

    output logic [31:0]  rd_data
);

import bootrom_pkg::*;

//------------------------------------------------------------
// Internal Signals
//------------------------------------------------------------

logic [31:0] reg_rd_data;
logic [31:0] rom_rd_data;

//------------------------------------------------------------
// Register Block
//------------------------------------------------------------

bootrom_regs u_bootrom_regs
(
    .rd_en   (rd_en),
    .addr    (addr),
    .rd_data (reg_rd_data)
);

//------------------------------------------------------------
// Boot ROM Logic
//------------------------------------------------------------

bootrom_logic u_bootrom_logic
(
    .clk     (clk),
    .rd_en   (rd_en),
    .addr    (addr),
    .rd_data (rom_rd_data)
);

//------------------------------------------------------------
// Read Data Mux
//------------------------------------------------------------

always_comb
begin
    case (addr)

        BOOTROM_BASE_ADDR + 32'h00,
        BOOTROM_BASE_ADDR + 32'h04 :
            rd_data = reg_rd_data;

        default :
            rd_data = rom_rd_data;

    endcase
end

endmodule