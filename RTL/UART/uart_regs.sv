
module uart_regs
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic                    clk,
    input  logic                    rst_n,

    //------------------------------------------------------------
    // APB Register Interface
    //------------------------------------------------------------

    input  logic                    wr_en,
    input  logic                    rd_en,

    input  logic [31:0]             addr,
    input  logic [31:0]             wr_data,

    output logic [31:0]             rd_data,

    //------------------------------------------------------------
    // Hardware Inputs
    //------------------------------------------------------------

    input  logic [7:0]              rx_data,

    input  logic                    tx_busy,

    input  logic                    rx_valid,

    input  logic                    tx_fifo_full,

    input  logic                    tx_fifo_empty,

    input  logic                    rx_fifo_full,

    input  logic                    rx_fifo_empty,

    input  logic                    uart_irq_pending,

    //------------------------------------------------------------
    // Register Outputs
    //------------------------------------------------------------

    output logic [31:0]             uart_control,

    output logic [31:0]             uart_baud,

    output logic [7:0]              uart_tx_data,

    output logic                    uart_tx_write,

    output logic                    uart_int_clear,
	
	output logic                    uart_rx_read
);

    import uart_pkg::*;

    //------------------------------------------------------------
    // Internal Registers
    //------------------------------------------------------------

    logic [31:0] control_reg;

    logic [31:0] baud_reg;

    logic [7:0]  txdata_reg;

    logic [31:0] status_reg;

    logic        tx_write_reg;

    logic        int_clear_reg;
	
	logic        rx_read_reg;

    //------------------------------------------------------------
    // Register Write Logic
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            control_reg   <= RESET_UART_CONTROL;

            baud_reg      <= RESET_UART_BAUD;

            txdata_reg    <= RESET_UART_TXDATA[7:0];

            tx_write_reg  <= 1'b0;

            int_clear_reg <= 1'b0;
			
			rx_read_reg <= 1'b0;

        end
        else
        begin

            //----------------------------------------------------
            // Pulse Registers
            //----------------------------------------------------

            tx_write_reg  <= 1'b0;

            int_clear_reg <= 1'b0;
			
			rx_read_reg <= 1'b0;

            //----------------------------------------------------
            // APB Write
            //----------------------------------------------------

            if(wr_en)
            begin

                unique case(addr)

                    UART_CONTROL_ADDR :
                        control_reg <= wr_data;

                    UART_BAUD_ADDR :
                        baud_reg <= wr_data;

                    UART_TXDATA_ADDR :
                    begin

                        txdata_reg   <= wr_data[7:0];

                        tx_write_reg <= 1'b1;

                    end

                    UART_INT_CLEAR_ADDR :
                    begin

                        if(wr_data[0])

                            int_clear_reg <= 1'b1;

                    end

                    default :
                        ;

                endcase

            end

        end

    end
	
	    //------------------------------------------------------------
    // Status Register Generation
    //------------------------------------------------------------

    always_comb
    begin

        status_reg = 32'd0;

        status_reg[UART_TX_BUSY_BIT]       = tx_busy;

        status_reg[UART_RX_VALID_BIT]      = rx_valid;

        status_reg[UART_TX_FIFO_FULL_BIT]  = tx_fifo_full;

        status_reg[UART_TX_FIFO_EMPTY_BIT] = tx_fifo_empty;

        status_reg[UART_RX_FIFO_FULL_BIT]  = rx_fifo_full;

        status_reg[UART_RX_FIFO_EMPTY_BIT] = rx_fifo_empty;

    end

    //------------------------------------------------------------
    // Register Read Logic
    //------------------------------------------------------------

    always_comb
    begin

        rd_data = 32'd0;

        if(rd_en)
        begin

            unique case(addr)

                //------------------------------------------------
                // Read Only Registers
                //------------------------------------------------

                UART_ID_ADDR :
                    rd_data = UART_ID;

                UART_VERSION_ADDR :
                    rd_data = UART_VERSION;

                UART_RXDATA_ADDR :
                    rd_data = {24'd0, rx_data};

                UART_STATUS_ADDR :
                    rd_data = status_reg;

                UART_INT_STATUS_ADDR :
                    rd_data = {{31{1'b0}}, uart_irq_pending};

                //------------------------------------------------
                // Read / Write Registers
                //------------------------------------------------

                UART_CONTROL_ADDR :
                    rd_data = control_reg;

                UART_BAUD_ADDR :
                    rd_data = baud_reg;

                default :
                    rd_data = 32'hDEAD_BEEF;

            endcase

        end

    end
	
	always_ff @(posedge clk or negedge rst_n)
      begin
        if(!rst_n)
          rx_read_reg <= 1'b0;
        else
        begin
          rx_read_reg <= 1'b0;

        if(rd_en && (addr == UART_RXDATA_ADDR))
            rx_read_reg <= 1'b1;
        end
      end

    //------------------------------------------------------------
    // Register Outputs
    //------------------------------------------------------------

    assign uart_control   = control_reg;

    assign uart_baud      = baud_reg;

    assign uart_tx_data   = txdata_reg;

    assign uart_tx_write  = tx_write_reg;

    assign uart_int_clear = int_clear_reg;
	
	assign uart_rx_read = rx_read_reg;

`ifndef SYNTHESIS

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    // Valid Address Check

    property p_valid_access;

        @(posedge clk)

        disable iff(!rst_n)

        (wr_en || rd_en)
            |->
        is_valid_address(addr);

    endproperty

    assert property(p_valid_access)
    else
        $error("UART_REGS : Invalid register address.");

    //------------------------------------------------------------

    // Address Alignment

    property p_addr_alignment;

        @(posedge clk)

        disable iff(!rst_n)

        (wr_en || rd_en)
            |->
        (addr[1:0] == 2'b00);

    endproperty

    assert property(p_addr_alignment)
    else
        $error("UART_REGS : Address alignment error.");

    //------------------------------------------------------------

    // Read Only Register Protection

    property p_ro_write;

        @(posedge clk)

        disable iff(!rst_n)

        wr_en
            |->
        !is_read_only(addr);

    endproperty

    assert property(p_ro_write)
    else
        $error("UART_REGS : Write attempted to Read-Only register.");

`endif

endmodule

`default_nettype wire