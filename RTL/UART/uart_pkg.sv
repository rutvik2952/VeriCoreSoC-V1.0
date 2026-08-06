`timescale 1ns/1ps

package uart_pkg;

    //------------------------------------------------------------
    // Package Import
    //------------------------------------------------------------

  

    //------------------------------------------------------------
    // UART Information
    //------------------------------------------------------------

    parameter string UART_NAME = "TinySoC UART";

    parameter logic [31:0] UART_ID      = 32'h5541_5254;   // "UART"

    parameter logic [31:0] UART_VERSION = 32'h0001_0000;

    //------------------------------------------------------------
    // Base Address
    //------------------------------------------------------------

    parameter logic [31:0] UART_BASE_ADDR = 4000_3000;

    //------------------------------------------------------------
    // Register Address Map
    //------------------------------------------------------------

    parameter logic [31:0] UART_ID_ADDR         = UART_BASE_ADDR + 32'h00;

    parameter logic [31:0] UART_VERSION_ADDR    = UART_BASE_ADDR + 32'h04;

    parameter logic [31:0] UART_CONTROL_ADDR    = UART_BASE_ADDR + 32'h08;

    parameter logic [31:0] UART_BAUD_ADDR       = UART_BASE_ADDR + 32'h0C;

    parameter logic [31:0] UART_TXDATA_ADDR     = UART_BASE_ADDR + 32'h10;

    parameter logic [31:0] UART_RXDATA_ADDR     = UART_BASE_ADDR + 32'h14;

    parameter logic [31:0] UART_STATUS_ADDR     = UART_BASE_ADDR + 32'h18;

    parameter logic [31:0] UART_INT_STATUS_ADDR = UART_BASE_ADDR + 32'h1C;

    parameter logic [31:0] UART_INT_CLEAR_ADDR  = UART_BASE_ADDR + 32'h20;

    //------------------------------------------------------------
    // Reset Values
    //------------------------------------------------------------

    parameter logic [31:0] RESET_UART_CONTROL    = 32'h0000_0000;

    parameter logic [31:0] RESET_UART_BAUD       = 32'h0000_0000;

    parameter logic [31:0] RESET_UART_TXDATA     = 32'h0000_0000;

    parameter logic [31:0] RESET_UART_RXDATA     = 32'h0000_0000;

    parameter logic [31:0] RESET_UART_STATUS     = 32'h0000_0000;

    parameter logic [31:0] RESET_UART_INT_STATUS = 32'h0000_0000;

    //------------------------------------------------------------
    // UART Configuration
    //------------------------------------------------------------

    parameter int UART_DATA_WIDTH = 8;

    parameter int UART_FIFO_DEPTH = 16;

    parameter int UART_ADDR_WIDTH = 32;

    parameter int UART_BAUD_WIDTH = 16;

    //------------------------------------------------------------
    // FIFO Configuration
    //------------------------------------------------------------

    parameter int TX_FIFO_DEPTH = 16;

    parameter int RX_FIFO_DEPTH = 16;

    parameter int FIFO_PTR_WIDTH = 4;
	
	    //------------------------------------------------------------
    // UART Control Register Bit Definitions
    //------------------------------------------------------------

    parameter int UART_ENABLE_BIT     = 0;

    parameter int UART_TX_ENABLE_BIT  = 1;

    parameter int UART_RX_ENABLE_BIT  = 2;

    parameter int UART_TX_IRQ_EN_BIT  = 3;

    parameter int UART_RX_IRQ_EN_BIT  = 4;

    //------------------------------------------------------------
    // UART Status Register Bit Definitions
    //------------------------------------------------------------

    parameter int UART_TX_BUSY_BIT       = 0;

    parameter int UART_RX_VALID_BIT      = 1;

    parameter int UART_TX_FIFO_FULL_BIT  = 2;

    parameter int UART_TX_FIFO_EMPTY_BIT = 3;

    parameter int UART_RX_FIFO_FULL_BIT  = 4;

    parameter int UART_RX_FIFO_EMPTY_BIT = 5;

    //------------------------------------------------------------
    // UART Interrupt Bits
    //------------------------------------------------------------

    parameter int UART_TX_INT_BIT = 0;

    parameter int UART_RX_INT_BIT = 1;

    //------------------------------------------------------------
    // UART TX State Machine
    //------------------------------------------------------------

    typedef enum logic [2:0]
    {
        UART_TX_IDLE,

        UART_TX_START,

        UART_TX_DATA,

        UART_TX_STOP

    } uart_tx_state_e;

    //------------------------------------------------------------
    // UART RX State Machine
    //------------------------------------------------------------

    typedef enum logic [2:0]
    {
        UART_RX_IDLE,

        UART_RX_START,

        UART_RX_DATA,

        UART_RX_STOP

    } uart_rx_state_e;

    //------------------------------------------------------------
    // UART Status Structure
    //------------------------------------------------------------

    typedef struct packed
    {
        logic tx_busy;

        logic rx_valid;

        logic tx_fifo_full;

        logic tx_fifo_empty;

        logic rx_fifo_full;

        logic rx_fifo_empty;

    } uart_status_t;

    //------------------------------------------------------------
    // Register Type
    //------------------------------------------------------------

    typedef logic [31:0] uart_reg_t;

    //------------------------------------------------------------
    // Address Validation
    //------------------------------------------------------------

    function automatic logic is_valid_address
    (
        input logic [31:0] addr
    );

        case(addr)

            UART_ID_ADDR,
            UART_VERSION_ADDR,
            UART_CONTROL_ADDR,
            UART_BAUD_ADDR,
            UART_TXDATA_ADDR,
            UART_RXDATA_ADDR,
            UART_STATUS_ADDR,
            UART_INT_STATUS_ADDR,
            UART_INT_CLEAR_ADDR :

                is_valid_address = 1'b1;

            default :

                is_valid_address = 1'b0;

        endcase

    endfunction

    //------------------------------------------------------------
    // Read Only Register Check
    //------------------------------------------------------------

    function automatic logic is_read_only
    (
        input logic [31:0] addr
    );

        case(addr)

            UART_ID_ADDR,
            UART_VERSION_ADDR,
            UART_RXDATA_ADDR,
            UART_STATUS_ADDR,
            UART_INT_STATUS_ADDR :

                is_read_only = 1'b1;

            default :

                is_read_only = 1'b0;

        endcase

    endfunction

endpackage