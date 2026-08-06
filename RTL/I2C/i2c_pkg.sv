`timescale 1ns/1ps

package i2c_pkg;

    //------------------------------------------------------------
    // I2C Information
    //------------------------------------------------------------

    parameter logic [31:0] I2C_ID      = 32'h4932_4320;   // "I2C "
    parameter logic [31:0] I2C_VERSION = 32'h0001_0000;

    //------------------------------------------------------------
    // Base Address
    //------------------------------------------------------------

    parameter logic [31:0] I2C_BASE_ADDR = 32'h4000_5000;

    //------------------------------------------------------------
    // Register Map
    //------------------------------------------------------------

    parameter logic [31:0] I2C_ID_ADDR         = I2C_BASE_ADDR + 32'h00;
    parameter logic [31:0] I2C_VERSION_ADDR    = I2C_BASE_ADDR + 32'h04;
    parameter logic [31:0] I2C_CONTROL_ADDR    = I2C_BASE_ADDR + 32'h08;
    parameter logic [31:0] I2C_CLKDIV_ADDR     = I2C_BASE_ADDR + 32'h0C;
    parameter logic [31:0] I2C_ADDRESS_ADDR    = I2C_BASE_ADDR + 32'h10;
    parameter logic [31:0] I2C_TXDATA_ADDR     = I2C_BASE_ADDR + 32'h14;
    parameter logic [31:0] I2C_RXDATA_ADDR     = I2C_BASE_ADDR + 32'h18;
    parameter logic [31:0] I2C_STATUS_ADDR     = I2C_BASE_ADDR + 32'h1C;
    parameter logic [31:0] I2C_INT_STATUS_ADDR = I2C_BASE_ADDR + 32'h20;
    parameter logic [31:0] I2C_INT_CLEAR_ADDR  = I2C_BASE_ADDR + 32'h24;

    //------------------------------------------------------------
    // Reset Values
    //------------------------------------------------------------

    parameter logic [31:0] RESET_I2C_CONTROL = 32'h0000_0000;
    parameter logic [31:0] RESET_I2C_CLKDIV  = 32'd100;
    parameter logic [6:0]  RESET_I2C_ADDR    = 7'h00;

    //------------------------------------------------------------
    // CONTROL Register Bits
    //------------------------------------------------------------

    parameter int I2C_ENABLE_BIT = 0;
    parameter int I2C_START_BIT  = 1;
    parameter int I2C_STOP_BIT   = 2;
    parameter int I2C_RW_BIT     = 3;
    parameter int I2C_IRQ_EN_BIT = 4;

    //------------------------------------------------------------
    // STATUS Register Bits
    //------------------------------------------------------------

    parameter int I2C_BUSY_BIT = 0;
    parameter int I2C_ACK_BIT  = 1;
    parameter int I2C_DONE_BIT = 2;

    //------------------------------------------------------------
    // I2C FSM
    //------------------------------------------------------------

    typedef enum logic [2:0]
    {
        I2C_IDLE,
        I2C_START,
        I2C_ADDRESS,
        I2C_DATA,
        I2C_STOP
    } i2c_state_e;

endpackage