
module uart_logic
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic         clk,
    input  logic         rst_n,

    //------------------------------------------------------------
    // Register Interface
    //------------------------------------------------------------

    input  logic [31:0]  uart_control,
    input  logic [31:0]  uart_baud,

    input  logic [7:0]   uart_tx_data,
    input  logic         uart_tx_write,

    input  logic         uart_int_clear,
	input logic          uart_rx_read,

    //------------------------------------------------------------
    // UART Pins
    //------------------------------------------------------------

    output logic         uart_tx,

    input  logic         uart_rx,

    //------------------------------------------------------------
    // Register Outputs
    //------------------------------------------------------------

    output logic [7:0]   rx_data,

    output logic         tx_busy,

    output logic         rx_valid,

    output logic         tx_fifo_full,

    output logic         tx_fifo_empty,

    output logic         rx_fifo_full,

    output logic         rx_fifo_empty,

    output logic         uart_irq_pending,

    output logic         uart_irq
);

    import uart_pkg::*;

    //------------------------------------------------------------
    // Baud Generator
    //------------------------------------------------------------

    logic [15:0] baud_counter;

    logic        baud_tick;

    //------------------------------------------------------------
    // TX FIFO
    //------------------------------------------------------------

   // logic [7:0] tx_fifo [0:TX_FIFO_DEPTH-1];

    logic [3:0] tx_wr_ptr;

    logic [3:0] tx_rd_ptr;

    logic [4:0] tx_count;

    //------------------------------------------------------------
    // RX FIFO
    //------------------------------------------------------------

   // logic [7:0] rx_fifo [0:RX_FIFO_DEPTH-1];

    logic [3:0] rx_wr_ptr;

    logic [3:0] rx_rd_ptr;

    logic [4:0] rx_count;

    //------------------------------------------------------------
    // UART State Machines
    //------------------------------------------------------------

    uart_tx_state_e tx_state;

    uart_rx_state_e rx_state;

    //------------------------------------------------------------
    // Shift Registers
    //------------------------------------------------------------

    logic [7:0] tx_shift;

    logic [7:0] rx_shift;

    logic [2:0] tx_bit_cnt;

    logic [2:0] rx_bit_cnt;

    //------------------------------------------------------------
    // Interrupt
    //------------------------------------------------------------

    logic irq_pending_reg;
	
	    //------------------------------------------------------------
    // Baud Generator
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            baud_counter <= '0;

            baud_tick    <= 1'b0;

        end
        else
        begin

            //----------------------------------------------------
            // Default
            //----------------------------------------------------

            baud_tick <= 1'b0;

            //----------------------------------------------------
            // UART Enabled
            //----------------------------------------------------

            if(uart_control[UART_ENABLE_BIT])
            begin

                //------------------------------------------------
                // Baud Divider Protection
                //------------------------------------------------

                if(uart_baud != 32'd0)
                begin

                    if(baud_counter == uart_baud - 1)
                    begin

                        baud_counter <= '0;

                        baud_tick <= 1'b1;

                    end
                    else
                    begin

                        baud_counter <= baud_counter + 1'b1;

                    end

                end
                else
                begin

                    baud_counter <= '0;

                end

            end
            else
            begin

                baud_counter <= '0;

            end

        end

    end
	
	    //------------------------------------------------------------
    // TX FIFO Controller
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

            //----------------------------------------------------
            // CPU Write into TX FIFO
            //----------------------------------------------------

            if(uart_tx_write && !tx_fifo_full)
            begin

                //------------------------------------------------
                // Write into FIFO RAM
                //------------------------------------------------

                // fifo_wr_en   <= 1'b1;
                // fifo_wr_addr <= tx_wr_ptr;
                // fifo_wr_data <= uart_tx_data;

                tx_wr_ptr <= tx_wr_ptr + 1'b1;

                tx_count  <= tx_count + 1'b1;

            end

            //----------------------------------------------------
            // TX State Machine Reads FIFO
            //----------------------------------------------------

            if((tx_state == UART_TX_IDLE) &&
               (tx_count != 0) &&
               baud_tick)
            begin

                //------------------------------------------------
                // Read from FIFO RAM
                //------------------------------------------------

                // fifo_rd_en   <= 1'b1;
                // fifo_rd_addr <= tx_rd_ptr;

                tx_rd_ptr <= tx_rd_ptr + 1'b1;

                tx_count  <= tx_count - 1'b1;

            end

        end

    end

    //------------------------------------------------------------
    // TX FIFO Status
    //------------------------------------------------------------

    assign tx_fifo_full  = (tx_count == TX_FIFO_DEPTH);

    assign tx_fifo_empty = (tx_count == 0);
	
	    //------------------------------------------------------------
    // RX FIFO Controller
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

            //----------------------------------------------------
            // RX State Machine writes received byte into FIFO
            //----------------------------------------------------

            if((rx_state == UART_RX_STOP) &&
               baud_tick &&
               !rx_fifo_full)
            begin

                //------------------------------------------------
                // Write into FIFO RAM
                //------------------------------------------------

                // fifo_wr_en   <= 1'b1;
                // fifo_wr_addr <= rx_wr_ptr;
                // fifo_wr_data <= rx_shift;

                rx_wr_ptr <= rx_wr_ptr + 1'b1;

                rx_count  <= rx_count + 1'b1;

            end

            //----------------------------------------------------
            // CPU reads received data
            //----------------------------------------------------

            if(uart_rx_read &&(rx_count != 0))
              begin

                //------------------------------------------------
                // Read from FIFO RAM
                //------------------------------------------------

                // fifo_rd_en   <= 1'b1;
                // fifo_rd_addr <= rx_rd_ptr;

                // rx_data <= fifo_rd_data;

                rx_rd_ptr <= rx_rd_ptr + 1'b1;

                rx_count  <= rx_count - 1'b1;

              end

        end

    end

    //------------------------------------------------------------
    // RX FIFO Status
    //------------------------------------------------------------

    assign rx_fifo_full  = (rx_count == RX_FIFO_DEPTH);

    assign rx_fifo_empty = (rx_count == 0);
	
	    //------------------------------------------------------------
    // TX State Machine
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            tx_state   <= UART_TX_IDLE;

            tx_shift   <= '0;

            tx_bit_cnt <= '0;

            uart_tx    <= 1'b1;      // UART Idle Line

            tx_busy    <= 1'b0;

        end
        else
        begin

            if(baud_tick)
            begin

                case(tx_state)

                    //------------------------------------------------
                    // IDLE
                    //------------------------------------------------

                    UART_TX_IDLE :
                    begin

                        uart_tx <= 1'b1;

                        tx_busy <= 1'b0;

                        if(tx_count != 0)
                        begin

                            //----------------------------------------
                            // Read next byte from FIFO
                            //----------------------------------------

                            // tx_shift <= fifo_rd_data;

                            tx_shift <= uart_tx_data;   // Temporary

                            tx_bit_cnt <= 3'd0;

                            tx_busy <= 1'b1;

                            tx_state <= UART_TX_START;

                        end

                    end

                    //------------------------------------------------
                    // START BIT
                    //------------------------------------------------

                    UART_TX_START :
                    begin

                        uart_tx <= 1'b0;

                        tx_state <= UART_TX_DATA;

                    end

                    //------------------------------------------------
                    // DATA BITS
                    //------------------------------------------------

                    UART_TX_DATA :
                    begin

                        uart_tx <= tx_shift[0];

                        tx_shift <= {1'b0, tx_shift[7:1]};

                        if(tx_bit_cnt == 3'd7)

                            tx_state <= UART_TX_STOP;

                        else

                            tx_bit_cnt <= tx_bit_cnt + 1'b1;

                    end

                    //------------------------------------------------
                    // STOP BIT
                    //------------------------------------------------

                    UART_TX_STOP :
                    begin

                        uart_tx <= 1'b1;

                        tx_busy <= 1'b0;

                        tx_state <= UART_TX_IDLE;

                    end

                    //------------------------------------------------
                    // Default
                    //------------------------------------------------

                    default :

                        tx_state <= UART_TX_IDLE;

                endcase

            end

        end

    end
	
	    //------------------------------------------------------------
    // RX State Machine
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            rx_state   <= UART_RX_IDLE;

            rx_shift   <= '0;

            rx_bit_cnt <= '0;

           // rx_valid   <= 1'b0;

        end
        else
        begin

            //----------------------------------------------------
            // Default
            //----------------------------------------------------

           // rx_valid <= 1'b0;

            if(baud_tick)
            begin

                case(rx_state)

                    //------------------------------------------------
                    // IDLE
                    //------------------------------------------------

                    UART_RX_IDLE :
                    begin

                        if(uart_rx == 1'b0)
                        begin

                            rx_bit_cnt <= '0;

                            rx_state <= UART_RX_START;

                        end

                    end

                    //------------------------------------------------
                    // START BIT
                    //------------------------------------------------

                    UART_RX_START :
                    begin

                        if(uart_rx == 1'b0)

                            rx_state <= UART_RX_DATA;

                        else

                            rx_state <= UART_RX_IDLE;

                    end

                    //------------------------------------------------
                    // DATA BITS
                    //------------------------------------------------

                    UART_RX_DATA :
                    begin

                        rx_shift <= {uart_rx, rx_shift[7:1]};

                        if(rx_bit_cnt == 3'd7)

                            rx_state <= UART_RX_STOP;

                        else

                            rx_bit_cnt <= rx_bit_cnt + 1'b1;

                    end

                    //------------------------------------------------
                    // STOP BIT
                    //------------------------------------------------

                    UART_RX_STOP :
                    begin

                        if(uart_rx == 1'b1)
                        begin

                            //----------------------------------------
                            // Valid UART Frame
                            //----------------------------------------

                            // FIFO Write will occur in
                            // RX FIFO Controller

                          //  rx_valid <= 1'b1;

                        end

                        rx_state <= UART_RX_IDLE;

                    end

                    //------------------------------------------------
                    // Default
                    //------------------------------------------------

                    default :

                        rx_state <= UART_RX_IDLE;

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

            //----------------------------------------------------
            // Clear Interrupt
            //----------------------------------------------------

            if(uart_int_clear)
            begin

                irq_pending_reg <= 1'b0;

            end

            //----------------------------------------------------
            // RX Interrupt
            //----------------------------------------------------

            else if(rx_valid &&
                    uart_control[UART_RX_IRQ_EN_BIT])
            begin

                irq_pending_reg <= 1'b1;

            end

            //----------------------------------------------------
            // TX Interrupt
            //----------------------------------------------------

            else if(tx_fifo_empty &&
                    !tx_busy &&
                    uart_control[UART_TX_IRQ_EN_BIT])
            begin

                irq_pending_reg <= 1'b1;

            end

        end

    end

    //------------------------------------------------------------
    // Interrupt Outputs
    //------------------------------------------------------------

    assign uart_irq_pending = irq_pending_reg;

    assign uart_irq = irq_pending_reg;
	
	

    // Software sees data available while FIFO is not empty
    assign rx_valid      = !rx_fifo_empty;
	
	`ifndef SYNTHESIS

//----------------------------------------------
// TX FIFO Overflow
//----------------------------------------------

assert property
(
    @(posedge clk)

    disable iff(!rst_n)

    !(uart_tx_write && tx_fifo_full)
);

//----------------------------------------------
// RX FIFO Overflow
//----------------------------------------------

assert property
(
    @(posedge clk)

    disable iff(!rst_n)

    !(rx_fifo_full &&
      (rx_state==UART_RX_STOP))
);

//----------------------------------------------
// Baud Divider
//----------------------------------------------

assert property
(
    @(posedge clk)

    disable iff(!rst_n)

    uart_control[UART_ENABLE_BIT]
        |->
    (uart_baud!=0)
);

`endif

endmodule

