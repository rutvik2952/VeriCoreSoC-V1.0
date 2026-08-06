`timescale 1ns/1ps

package dma_pkg;

    //------------------------------------------------------------
    // DMA Information
    //------------------------------------------------------------

    parameter logic [31:0] DMA_ID      = 32'h444D_4120;   // "DMA "
    parameter logic [31:0] DMA_VERSION = 32'h0001_0000;

    //------------------------------------------------------------
    // Base Address
    //------------------------------------------------------------

    parameter logic [31:0] DMA_BASE_ADDR = 32'h4000_6000;

    //------------------------------------------------------------
    // Register Map
    //------------------------------------------------------------

    parameter logic [31:0] DMA_ID_ADDR         = DMA_BASE_ADDR + 32'h00;
    parameter logic [31:0] DMA_VERSION_ADDR    = DMA_BASE_ADDR + 32'h04;
    parameter logic [31:0] DMA_CONTROL_ADDR    = DMA_BASE_ADDR + 32'h08;
    parameter logic [31:0] DMA_SRC_ADDR        = DMA_BASE_ADDR + 32'h0C;
    parameter logic [31:0] DMA_DST_ADDR        = DMA_BASE_ADDR + 32'h10;
    parameter logic [31:0] DMA_LENGTH_ADDR     = DMA_BASE_ADDR + 32'h14;
    parameter logic [31:0] DMA_STATUS_ADDR     = DMA_BASE_ADDR + 32'h18;
    parameter logic [31:0] DMA_INT_STATUS_ADDR = DMA_BASE_ADDR + 32'h1C;
    parameter logic [31:0] DMA_INT_CLEAR_ADDR  = DMA_BASE_ADDR + 32'h20;

    //------------------------------------------------------------
    // Reset Values
    //------------------------------------------------------------

    parameter logic [31:0] RESET_DMA_CONTROL = 32'h0000_0000;
    parameter logic [31:0] RESET_DMA_LENGTH  = 32'h0000_0000;

    //------------------------------------------------------------
    // CONTROL Register Bits
    //------------------------------------------------------------

    parameter int DMA_ENABLE_BIT = 0;
    parameter int DMA_START_BIT  = 1;
    parameter int DMA_IRQ_EN_BIT = 2;

    //------------------------------------------------------------
    // STATUS Register Bits
    //------------------------------------------------------------

    parameter int DMA_BUSY_BIT = 0;
    parameter int DMA_DONE_BIT = 1;

    //------------------------------------------------------------
    // DMA State Machine
    //------------------------------------------------------------

    typedef enum logic [2:0]
    {
        DMA_IDLE,
        DMA_READ,
        DMA_WRITE,
        DMA_CHECK,
        DMA_DONE

    } dma_state_e;

endpackage