module bootrom_logic
(
    input  logic         clk,
    input  logic         rd_en,
    input  logic [31:0]  addr,

    output logic [31:0]  rd_data
);

import bootrom_pkg::*;

//------------------------------------------------------------
// Boot ROM
//------------------------------------------------------------

logic [31:0] rom [0:ROM_DEPTH-1];

//------------------------------------------------------------
// ROM Initialization
//------------------------------------------------------------

initial
begin

    // Simple Bootloader

    rom[0] = 32'h00000000;   // Reset Vector
    rom[1] = 32'h00000013;   // NOP
    rom[2] = 32'h00000013;   // NOP
    rom[3] = APP_START_ADDR;   // Jump to Application

    // Remaining ROM

    for(int i=4;i<ROM_DEPTH;i++)
        rom[i] = 32'h00000013;

end

//------------------------------------------------------------
// ROM Read
//------------------------------------------------------------

always_comb
begin

    rd_data = 32'h00000000;

    if(rd_en)

        rd_data = rom[addr[15:2]];

end

endmodule
