module spi_top
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
    // SPI Interface
    //------------------------------------------------------------
    output logic         spi_sclk,
    output logic         spi_mosi,
    input  logic         spi_miso,
    output logic         spi_cs_n,

    //------------------------------------------------------------
    // Interrupt
    //------------------------------------------------------------
    output logic         spi_irq
);

import spi_pkg::*;

//------------------------------------------------------------
// Register Interface
//------------------------------------------------------------

logic [31:0] spi_control;
logic [31:0] spi_clkdiv;

logic [15:0] spi_tx_data;
logic [15:0] rx_data;

logic        spi_tx_write;
logic        spi_rx_read;
logic        spi_int_clear;

//------------------------------------------------------------
// Status
//------------------------------------------------------------

logic spi_busy;

logic tx_fifo_full;
logic tx_fifo_empty;

logic rx_fifo_full;
logic rx_fifo_empty;

logic spi_irq_pending;

//------------------------------------------------------------
// Register Block
//------------------------------------------------------------

spi_regs
u_spi_regs
(
    .clk              (clk),
    .rst_n            (rst_n),

    .wr_en            (wr_en),
    .rd_en            (rd_en),

    .addr             (addr),
    .wr_data          (wr_data),
    .rd_data          (rd_data),

    .rx_data          (rx_data),

    .spi_busy         (spi_busy),

    .tx_fifo_full     (tx_fifo_full),
    .tx_fifo_empty    (tx_fifo_empty),

    .rx_fifo_full     (rx_fifo_full),
    .rx_fifo_empty    (rx_fifo_empty),

    .spi_irq_pending  (spi_irq_pending),

    .spi_control      (spi_control),
    .spi_clkdiv       (spi_clkdiv),

    .spi_tx_data      (spi_tx_data),

    .spi_tx_write     (spi_tx_write),

    .spi_rx_read      (spi_rx_read),

    .spi_int_clear    (spi_int_clear)
);

//------------------------------------------------------------
// SPI Logic
//------------------------------------------------------------

spi_logic
u_spi_logic
(
    .clk              (clk),
    .rst_n            (rst_n),

    .spi_control      (spi_control),
    .spi_clkdiv       (spi_clkdiv),

    .spi_tx_data      (spi_tx_data),

    .spi_tx_write     (spi_tx_write),

    .spi_rx_read      (spi_rx_read),

    .spi_int_clear    (spi_int_clear),

    .spi_sclk         (spi_sclk),
    .spi_mosi         (spi_mosi),
    .spi_miso         (spi_miso),
    .spi_cs_n         (spi_cs_n),

    .rx_data          (rx_data),

    .spi_busy         (spi_busy),

    .tx_fifo_full     (tx_fifo_full),
    .tx_fifo_empty    (tx_fifo_empty),

    .rx_fifo_full     (rx_fifo_full),
    .rx_fifo_empty    (rx_fifo_empty),

    .spi_irq_pending  (spi_irq_pending),

    .spi_irq          (spi_irq)
);

endmodule
