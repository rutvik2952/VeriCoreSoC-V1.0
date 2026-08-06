module i2c_top
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
    // I2C Pins
    //------------------------------------------------------------
    inout  wire          scl,
    inout  wire          sda,

    //------------------------------------------------------------
    // Interrupt
    //------------------------------------------------------------
    output logic         i2c_irq
);

import i2c_pkg::*;

//------------------------------------------------------------
// Internal Signals
//------------------------------------------------------------

logic [31:0] control;
logic [31:0] clkdiv;

logic [6:0]  slave_addr;

logic [7:0] tx_data;
logic [7:0] rx_data;

logic start_pulse;
logic int_clear;

logic busy;
logic ack;

logic irq_pending;

//------------------------------------------------------------
// Register Block
//------------------------------------------------------------

i2c_regs u_i2c_regs
(
    .clk             (clk),
    .rst_n           (rst_n),

    .wr_en           (wr_en),
    .rd_en           (rd_en),

    .addr            (addr),
    .wr_data         (wr_data),
    .rd_data         (rd_data),

    .rx_data         (rx_data),

    .i2c_busy        (busy),
    .i2c_ack         (ack),
    .i2c_irq_pending (irq_pending),

    .i2c_control     (control),
    .i2c_clkdiv      (clkdiv),

    .i2c_addr        (slave_addr),
    .i2c_tx_data     (tx_data),

    .i2c_start       (start_pulse),
    .i2c_int_clear   (int_clear)
);

//------------------------------------------------------------
// I2C Logic
//------------------------------------------------------------

i2c_logic u_i2c_logic
(
    .clk             (clk),
    .rst_n           (rst_n),

    .i2c_control     (control),
    .i2c_clkdiv      (clkdiv),

    .i2c_addr        (slave_addr),
    .i2c_tx_data     (tx_data),

    .i2c_start       (start_pulse),
    .i2c_int_clear   (int_clear),

    .scl             (scl),
    .sda             (sda),

    .rx_data         (rx_data),

    .i2c_busy        (busy),
    .i2c_ack         (ack),

    .i2c_irq_pending (irq_pending),
    .i2c_irq         (i2c_irq)
);

endmodule