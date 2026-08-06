
package spi_pkg;

    //------------------------------------------------------------
    // SPI Peripheral Information
    //------------------------------------------------------------

    parameter logic [31:0] SPI_ID      = 32'h5350_4920;   // "SPI "
    parameter logic [31:0] SPI_VERSION = 32'h0001_0000;

    //------------------------------------------------------------
    // Base Address
    //------------------------------------------------------------

    parameter logic [31:0] SPI_BASE_ADDR = 32'h4000_4000;

    //------------------------------------------------------------
    // Register Address Map
    //------------------------------------------------------------

    parameter logic [31:0] SPI_ID_ADDR         = SPI_BASE_ADDR + 32'h00;
    parameter logic [31:0] SPI_VERSION_ADDR    = SPI_BASE_ADDR + 32'h04;
    parameter logic [31:0] SPI_CONTROL_ADDR    = SPI_BASE_ADDR + 32'h08;
    parameter logic [31:0] SPI_CLKDIV_ADDR     = SPI_BASE_ADDR + 32'h0C;
    parameter logic [31:0] SPI_TXDATA_ADDR     = SPI_BASE_ADDR + 32'h10;
    parameter logic [31:0] SPI_RXDATA_ADDR     = SPI_BASE_ADDR + 32'h14;
    parameter logic [31:0] SPI_STATUS_ADDR     = SPI_BASE_ADDR + 32'h18;
    parameter logic [31:0] SPI_INT_STATUS_ADDR = SPI_BASE_ADDR + 32'h1C;
    parameter logic [31:0] SPI_INT_CLEAR_ADDR  = SPI_BASE_ADDR + 32'h20;

    //------------------------------------------------------------
    // Reset Values
    //------------------------------------------------------------

    parameter logic [31:0] RESET_SPI_CONTROL    = 32'h0000_0000;
    parameter logic [31:0] RESET_SPI_CLKDIV     = 32'd4;
    parameter logic [31:0] RESET_SPI_TXDATA     = 32'h0000_0000;
    parameter logic [31:0] RESET_SPI_RXDATA     = 32'h0000_0000;
    parameter logic [31:0] RESET_SPI_STATUS     = 32'h0000_0000;
    parameter logic [31:0] RESET_SPI_INT_STATUS = 32'h0000_0000;

    //------------------------------------------------------------
    // FIFO Configuration
    //------------------------------------------------------------

    parameter int SPI_FIFO_DEPTH = 16;
    parameter int SPI_FIFO_WIDTH = 8;

    //------------------------------------------------------------
    // Clock Divider
    //------------------------------------------------------------

    parameter int SPI_CLKDIV_WIDTH = 16;

    //------------------------------------------------------------
    // Transfer Width
    //------------------------------------------------------------

    parameter int SPI_DATA_WIDTH_8  = 8;
    parameter int SPI_DATA_WIDTH_16 = 16;

        //------------------------------------------------------------
    // SPI_CONTROL Register Bit Definitions
    //------------------------------------------------------------

    parameter int SPI_ENABLE_BIT     = 0;
    parameter int SPI_MASTER_BIT     = 1;
    parameter int SPI_CPOL_BIT       = 2;
    parameter int SPI_CPHA_BIT       = 3;
    parameter int SPI_TX_IRQ_EN_BIT  = 4;
    parameter int SPI_RX_IRQ_EN_BIT  = 5;
    parameter int SPI_DATA16_BIT     = 6;

    //------------------------------------------------------------
    // SPI_STATUS Register Bit Definitions
    //------------------------------------------------------------

    parameter int SPI_BUSY_BIT           = 0;
    parameter int SPI_TX_EMPTY_BIT       = 1;
    parameter int SPI_TX_FULL_BIT        = 2;
    parameter int SPI_RX_EMPTY_BIT       = 3;
    parameter int SPI_RX_FULL_BIT        = 4;
    parameter int SPI_TX_DONE_BIT        = 5;
    parameter int SPI_RX_DONE_BIT        = 6;
	
	//------------------------------------------------------------
    // SPI FSM States
    //------------------------------------------------------------

    typedef enum logic [2:0]
    {
        SPI_IDLE,

        SPI_LOAD,

        SPI_SHIFT,

        SPI_SAMPLE,

        SPI_COMPLETE

    } spi_state_e;
	
	//------------------------------------------------------------
    // Helper Functions
    //------------------------------------------------------------

    function automatic bit is_valid_address
    (
        input logic [31:0] addr
    );

        case(addr)

            SPI_ID_ADDR,
            SPI_VERSION_ADDR,
            SPI_CONTROL_ADDR,
            SPI_CLKDIV_ADDR,
            SPI_TXDATA_ADDR,
            SPI_RXDATA_ADDR,
            SPI_STATUS_ADDR,
            SPI_INT_STATUS_ADDR,
            SPI_INT_CLEAR_ADDR :

                return 1'b1;

            default :

                return 1'b0;

        endcase

    endfunction

    //------------------------------------------------------------

    function automatic bit is_read_only
    (
        input logic [31:0] addr
    );

        case(addr)

            SPI_ID_ADDR,
            SPI_VERSION_ADDR,
            SPI_RXDATA_ADDR,
            SPI_STATUS_ADDR,
            SPI_INT_STATUS_ADDR :

                return 1'b1;

            default :

                return 1'b0;

        endcase

    endfunction

endpackage