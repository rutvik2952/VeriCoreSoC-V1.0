`timescale 1ns/1ps

package intc_pkg;

    //------------------------------------------------------------
    // Interrupt Controller Information
    //------------------------------------------------------------

    parameter logic [31:0] INTC_ID      = 32'h494E_5443; // "INTC"
    parameter logic [31:0] INTC_VERSION = 32'h0001_0000;

    //------------------------------------------------------------
    // Base Address
    //------------------------------------------------------------

    parameter logic [31:0] INTC_BASE_ADDR = 32'h4000_7000;

    //------------------------------------------------------------
    // Register Map
    //------------------------------------------------------------

    parameter logic [31:0] INTC_ID_ADDR       = INTC_BASE_ADDR + 32'h00;
    parameter logic [31:0] INTC_VERSION_ADDR  = INTC_BASE_ADDR + 32'h04;
    parameter logic [31:0] INTC_ENABLE_ADDR   = INTC_BASE_ADDR + 32'h08;
    parameter logic [31:0] INTC_PENDING_ADDR  = INTC_BASE_ADDR + 32'h0C;
    parameter logic [31:0] INTC_PRIORITY_ADDR = INTC_BASE_ADDR + 32'h10;
    parameter logic [31:0] INTC_CLEAR_ADDR    = INTC_BASE_ADDR + 32'h14;

    //------------------------------------------------------------
    // Reset Values
    //------------------------------------------------------------

    parameter logic [7:0] RESET_INT_ENABLE   = 8'h00;
    parameter logic [7:0] RESET_INT_PRIORITY = 8'h00;

endpackage