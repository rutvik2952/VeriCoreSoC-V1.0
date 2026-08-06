`timescale 1ns/1ps

package bootrom_pkg;

    //------------------------------------------------------------
    // Boot ROM Information
    //------------------------------------------------------------

    parameter logic [31:0] BOOTROM_ID      = 32'h4252_4F4D; // "BROM"
    parameter logic [31:0] BOOTROM_VERSION = 32'h0001_0000;

    //------------------------------------------------------------
    // Base Address
    //------------------------------------------------------------

    parameter logic [31:0] BOOTROM_BASE_ADDR = 32'h0000_0000;

    //------------------------------------------------------------
    // ROM Configuration
    //------------------------------------------------------------

    parameter int ROM_DEPTH = 256;
	
	parameter logic [31:0] APP_START_ADDR = 32'h0001_0000;

endpackage