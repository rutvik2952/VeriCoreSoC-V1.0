
module spi_regs
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic         clk,
    input  logic         rst_n,

    //------------------------------------------------------------
    // APB Interface
    //------------------------------------------------------------

    input  logic         wr_en,
    input  logic         rd_en,

    input  logic [31:0]  addr,
    input  logic [31:0]  wr_data,

    output logic [31:0]  rd_data,

    //------------------------------------------------------------
    // Hardware Status
    //------------------------------------------------------------

    input  logic [15:0]  rx_data,

    input  logic         spi_busy,

    input  logic         tx_fifo_full,
    input  logic         tx_fifo_empty,

    input  logic         rx_fifo_full,
    input  logic         rx_fifo_empty,

    input  logic         spi_irq_pending,

    //------------------------------------------------------------
    // Control Outputs
    //------------------------------------------------------------

    output logic [31:0]  spi_control,

    output logic [31:0]  spi_clkdiv,

    output logic [15:0]  spi_tx_data,

    output logic         spi_tx_write,

    output logic         spi_rx_read,

    output logic         spi_int_clear
);

import spi_pkg::*;

    //------------------------------------------------------------
    // Register Storage
    //------------------------------------------------------------

    logic [31:0] control_reg;

    logic [31:0] clkdiv_reg;

    logic [15:0] txdata_reg;

    logic        tx_write_reg;

    logic        rx_read_reg;

    logic        int_clear_reg;
	
	    //------------------------------------------------------------
    // Register Write Logic
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            control_reg   <= RESET_SPI_CONTROL;

            clkdiv_reg    <= RESET_SPI_CLKDIV;

            txdata_reg    <= RESET_SPI_TXDATA[15:0];

            tx_write_reg  <= 1'b0;

            rx_read_reg   <= 1'b0;

            int_clear_reg <= 1'b0;

        end
        else
        begin

            //----------------------------------------------------
            // Default Pulse Outputs
            //----------------------------------------------------

            tx_write_reg  <= 1'b0;

            rx_read_reg   <= 1'b0;

            int_clear_reg <= 1'b0;
			
			            if(wr_en)
            begin

                case(addr)

                    SPI_CONTROL_ADDR :

                        control_reg <= wr_data;

                    SPI_CLKDIV_ADDR :

                        clkdiv_reg <= wr_data;

                    SPI_TXDATA_ADDR :
                    begin

                        txdata_reg <= wr_data[15:0];

                        tx_write_reg <= 1'b1;

                    end

                    SPI_INT_CLEAR_ADDR :

                        int_clear_reg <= 1'b1;

                    default :

                        ;

                endcase

            end
			
			            if(rd_en)
            begin

                if(addr == SPI_RXDATA_ADDR)

                    rx_read_reg <= 1'b1;

            end

        end

    end
	
	    //------------------------------------------------------------
    // APB Read Logic
    //------------------------------------------------------------

    always_comb
    begin

        rd_data = 32'h0000_0000;

        case(addr)

            SPI_ID_ADDR :
                rd_data = SPI_ID;

            SPI_VERSION_ADDR :
                rd_data = SPI_VERSION;

            SPI_CONTROL_ADDR :
                rd_data = control_reg;

            SPI_CLKDIV_ADDR :
                rd_data = clkdiv_reg;

            SPI_RXDATA_ADDR :
                rd_data = {16'h0000, rx_data};

            SPI_STATUS_ADDR :
            begin
                rd_data[SPI_BUSY_BIT]     = spi_busy;
                rd_data[SPI_TX_EMPTY_BIT] = tx_fifo_empty;
                rd_data[SPI_TX_FULL_BIT]  = tx_fifo_full;
                rd_data[SPI_RX_EMPTY_BIT] = rx_fifo_empty;
                rd_data[SPI_RX_FULL_BIT]  = rx_fifo_full;
            end

            SPI_INT_STATUS_ADDR :
                rd_data[0] = spi_irq_pending;

            default :
                rd_data = 32'h0000_0000;

        endcase

    end
	
	//------------------------------------------------------------
    // Output Assignments
    //------------------------------------------------------------

    assign spi_control   = control_reg;

    assign spi_clkdiv    = clkdiv_reg;

    assign spi_tx_data   = txdata_reg;

    assign spi_tx_write  = tx_write_reg;

    assign spi_rx_read   = rx_read_reg;

    assign spi_int_clear = int_clear_reg;

endmodule

`default_nettype wire