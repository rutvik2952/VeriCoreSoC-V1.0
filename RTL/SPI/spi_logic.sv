module spi_logic
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------
    input  logic         clk,
    input  logic         rst_n,

    //------------------------------------------------------------
    // Register Interface
    //------------------------------------------------------------
    input  logic [31:0]  spi_control,
    input  logic [31:0]  spi_clkdiv,

    input  logic [15:0]  spi_tx_data,
    input  logic         spi_tx_write,
    input  logic         spi_rx_read,
    input  logic         spi_int_clear,

    //------------------------------------------------------------
    // SPI Pins
    //------------------------------------------------------------
    output logic         spi_sclk,
    output logic         spi_mosi,
    input  logic         spi_miso,
    output logic         spi_cs_n,

    //------------------------------------------------------------
    // Status
    //------------------------------------------------------------
    output logic [15:0]  rx_data,

    output logic         spi_busy,

    output logic         tx_fifo_full,
    output logic         tx_fifo_empty,

    output logic         rx_fifo_full,
    output logic         rx_fifo_empty,

    output logic         spi_irq_pending,
    output logic         spi_irq
);

import spi_pkg::*;

//------------------------------------------------------------
// Clock Divider
//------------------------------------------------------------

logic [15:0] clk_cnt;

logic        spi_tick;

//------------------------------------------------------------
// FIFOs
//------------------------------------------------------------

logic [15:0] tx_fifo [0:15];
logic [15:0] rx_fifo [0:15];

logic [3:0] tx_wr_ptr;
logic [3:0] tx_rd_ptr;
logic [4:0] tx_count;

logic [3:0] rx_wr_ptr;
logic [3:0] rx_rd_ptr;
logic [4:0] rx_count;

//------------------------------------------------------------
// SPI Transfer
//------------------------------------------------------------

spi_state_e spi_state;

logic [15:0] tx_shift;
logic [15:0] rx_shift;

logic [4:0] bit_cnt;

//------------------------------------------------------------
// Interrupt
//------------------------------------------------------------

logic irq_pending_reg;

 //------------------------------------------------------------
// Clock Divider
//------------------------------------------------------------

always_ff @(posedge clk or negedge rst_n)
begin

    if(!rst_n)
    begin
        clk_cnt  <= '0;
        spi_tick <= 1'b0;
    end
    else
    begin

        spi_tick <= 1'b0;

        if(clk_cnt >= spi_clkdiv)
        begin
            clk_cnt  <= '0;
            spi_tick <= 1'b1;
        end
        else
        begin
            clk_cnt <= clk_cnt + 1'b1;
        end

    end

end

    //------------------------------------------------------------
    // TX FIFO
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin
            tx_wr_ptr <= '0;
            tx_rd_ptr <= '0;
            tx_count  <= '0;
        end
        else
        begin

            // CPU writes transmit data
            if(spi_tx_write && !tx_fifo_full)
            begin
                tx_fifo[tx_wr_ptr] <= spi_tx_data;

                tx_wr_ptr <= tx_wr_ptr + 1'b1;

                tx_count <= tx_count + 1'b1;
            end

            // SPI Transfer FSM consumes one entry
            if((spi_state == SPI_LOAD) && (tx_count != 0))
            begin
                tx_shift <= tx_fifo[tx_rd_ptr];

                tx_rd_ptr <= tx_rd_ptr + 1'b1;

                tx_count <= tx_count - 1'b1;
            end

        end

    end

    assign tx_fifo_full  = (tx_count == SPI_FIFO_DEPTH);

    assign tx_fifo_empty = (tx_count == 0);

    //------------------------------------------------------------
    // RX FIFO
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin
            rx_wr_ptr <= '0;
            rx_rd_ptr <= '0;
            rx_count  <= '0;

            rx_data   <= '0;
        end
        else
        begin

            // Transfer complete
            if((spi_state == SPI_COMPLETE) && !rx_fifo_full)
            begin

                rx_fifo[rx_wr_ptr] <= rx_shift;

                rx_wr_ptr <= rx_wr_ptr + 1'b1;

                rx_count <= rx_count + 1'b1;

            end

            // CPU reads received data
            if(spi_rx_read && (rx_count != 0))
            begin

                rx_data <= rx_fifo[rx_rd_ptr];

                rx_rd_ptr <= rx_rd_ptr + 1'b1;

                rx_count <= rx_count - 1'b1;

            end

        end

    end

    assign rx_fifo_full  = (rx_count == SPI_FIFO_DEPTH);

    assign rx_fifo_empty = (rx_count == 0);
	
	    //------------------------------------------------------------
    // SPI Transfer State Machine
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            spi_state <= SPI_IDLE;

            spi_busy  <= 1'b0;

            spi_cs_n  <= 1'b1;

            spi_sclk  <= 1'b0;

            spi_mosi  <= 1'b0;

            tx_shift  <= '0;

            rx_shift  <= '0;

            bit_cnt   <= '0;

        end
        else
        begin

            if(spi_tick)
            begin

                case(spi_state)

                    //--------------------------------------------
                    // IDLE
                    //--------------------------------------------

                    SPI_IDLE :
                    begin

                        spi_busy <= 1'b0;

                        spi_cs_n <= 1'b1;

                        spi_sclk <= spi_control[SPI_CPOL_BIT];

                        if(tx_count != 0)
                        begin

                            spi_busy <= 1'b1;

                            spi_cs_n <= 1'b0;

                            spi_state <= SPI_LOAD;

                        end

                    end

                    //--------------------------------------------
                    // LOAD
                    //--------------------------------------------

                    SPI_LOAD :
                    begin

                        bit_cnt <= spi_control[SPI_DATA16_BIT] ? 5'd15 : 5'd7;

                        spi_state <= SPI_SHIFT;

                    end

                    //--------------------------------------------
                    // SHIFT
                    //--------------------------------------------

                    SPI_SHIFT :
                    begin

                        spi_sclk <= ~spi_sclk;

                        spi_mosi <= tx_shift[bit_cnt];

                        rx_shift[bit_cnt] <= spi_miso;

                        if(bit_cnt == 0)

                            spi_state <= SPI_COMPLETE;

                        else

                            bit_cnt <= bit_cnt - 1'b1;

                    end

                    //--------------------------------------------
                    // COMPLETE
                    //--------------------------------------------

                    SPI_COMPLETE :
                    begin

                        spi_cs_n <= 1'b1;

                        spi_busy <= 1'b0;

                        spi_state <= SPI_IDLE;

                    end

                    //--------------------------------------------
                    // Default
                    //--------------------------------------------

                    default :

                        spi_state <= SPI_IDLE;

                endcase

            end

        end

    end
	
	    //------------------------------------------------------------
    // Interrupt Logic
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin
            irq_pending_reg <= 1'b0;
        end
        else
        begin

            //--------------------------------------------
            // Software Clear
            //--------------------------------------------

            if(spi_int_clear)

                irq_pending_reg <= 1'b0;

            //--------------------------------------------
            // Transfer Complete
            //--------------------------------------------

            else if((spi_state == SPI_COMPLETE) &&
                    (spi_control[SPI_TX_IRQ_EN_BIT] ||
                     spi_control[SPI_RX_IRQ_EN_BIT]))

                irq_pending_reg <= 1'b1;

        end

    end

    //------------------------------------------------------------
    // Interrupt Outputs
    //------------------------------------------------------------

    assign spi_irq_pending = irq_pending_reg;

    assign spi_irq = irq_pending_reg;
	
	//assign tx_fifo_full  = (tx_count == SPI_FIFO_DEPTH);

    //assign tx_fifo_empty = (tx_count == 0);

    //assign rx_fifo_full  = (rx_count == SPI_FIFO_DEPTH);

    //assign rx_fifo_empty = (rx_count == 0);
	
	//------------------------------------------------------------
// TX FIFO Overflow
//------------------------------------------------------------

`ifndef SYNTHESIS

assert property
(
    @(posedge clk)

    disable iff(!rst_n)

    !(spi_tx_write && tx_fifo_full)
);

//------------------------------------------------------------
// RX FIFO Overflow
//------------------------------------------------------------

assert property
(
    @(posedge clk)

    disable iff(!rst_n)

    !(rx_fifo_full &&
      (spi_state == SPI_COMPLETE))
);

`endif

endmodule