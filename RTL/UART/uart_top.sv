
module uart_top
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
    // UART Pins
    //------------------------------------------------------------

    output logic         uart_tx,
    input  logic         uart_rx,

    //------------------------------------------------------------
    // Interrupt
    //------------------------------------------------------------

    output logic         uart_irq
);

    import uart_pkg::*;
	
	//------------------------------------------------------------
    // Register Interface
    //------------------------------------------------------------

    logic [31:0] uart_control;

    logic [31:0] uart_baud;

    logic [7:0]  uart_tx_data;

    logic        uart_tx_write;

    logic        uart_rx_read;

    logic        uart_int_clear;

    //------------------------------------------------------------
    // Hardware Status
    //------------------------------------------------------------

    logic [7:0]  rx_data;

    logic        tx_busy;

    logic        rx_valid;

    logic        tx_fifo_full;

    logic        tx_fifo_empty;

    logic        rx_fifo_full;

    logic        rx_fifo_empty;

    logic        uart_irq_pending;
	
	    //------------------------------------------------------------
    // UART Registers
    //------------------------------------------------------------

    uart_regs
    u_uart_regs
    (
        .clk              (clk),
        .rst_n            (rst_n),

        .wr_en            (wr_en),
        .rd_en            (rd_en),

        .addr             (addr),
        .wr_data          (wr_data),
        .rd_data          (rd_data),

        .rx_data          (rx_data),

        .tx_busy          (tx_busy),
        .rx_valid         (rx_valid),

        .tx_fifo_full     (tx_fifo_full),
        .tx_fifo_empty    (tx_fifo_empty),

        .rx_fifo_full     (rx_fifo_full),
        .rx_fifo_empty    (rx_fifo_empty),

        .uart_irq_pending (uart_irq_pending),

        .uart_control     (uart_control),
        .uart_baud        (uart_baud),

        .uart_tx_data     (uart_tx_data),
        .uart_tx_write    (uart_tx_write),

        .uart_rx_read     (uart_rx_read),

        .uart_int_clear   (uart_int_clear)
    );
	
	    //------------------------------------------------------------
    // UART Logic
    //------------------------------------------------------------

    uart_logic
    u_uart_logic
    (
        .clk              (clk),
        .rst_n            (rst_n),

        .uart_control     (uart_control),
        .uart_baud        (uart_baud),

        .uart_tx_data     (uart_tx_data),
        .uart_tx_write    (uart_tx_write),

        .uart_rx_read     (uart_rx_read),

        .uart_int_clear   (uart_int_clear),

        .uart_tx          (uart_tx),
        .uart_rx          (uart_rx),

        .rx_data          (rx_data),

        .tx_busy          (tx_busy),
        .rx_valid         (rx_valid),

        .tx_fifo_full     (tx_fifo_full),
        .tx_fifo_empty    (tx_fifo_empty),

        .rx_fifo_full     (rx_fifo_full),
        .rx_fifo_empty    (rx_fifo_empty),

        .uart_irq_pending (uart_irq_pending),

        .uart_irq         (uart_irq)
    );

endmodule
