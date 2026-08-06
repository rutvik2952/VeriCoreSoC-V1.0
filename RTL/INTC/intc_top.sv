
module intc_top
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
    // Interrupt Inputs
    //------------------------------------------------------------
    input  logic [7:0]   irq_in,

    //------------------------------------------------------------
    // CPU Interrupt Output
    //------------------------------------------------------------
    output logic         cpu_irq
);

import intc_pkg::*;

//------------------------------------------------------------
// Internal Signals
//------------------------------------------------------------

logic [7:0] irq_enable;
logic [7:0] irq_priority;
logic [7:0] irq_clear;
logic [7:0] pending_irq;

//------------------------------------------------------------
// Register Block
//------------------------------------------------------------

intc_regs u_intc_regs
(
    .clk          (clk),
    .rst_n        (rst_n),

    .wr_en        (wr_en),
    .rd_en        (rd_en),

    .addr         (addr),
    .wr_data      (wr_data),
    .rd_data      (rd_data),

    .pending_irq  (pending_irq),

    .irq_enable   (irq_enable),
    .irq_priority (irq_priority),

    .irq_clear    (irq_clear)
);

//------------------------------------------------------------
// Interrupt Logic
//------------------------------------------------------------

intc_logic u_intc_logic
(
    .clk          (clk),
    .rst_n        (rst_n),

    .irq_in       (irq_in),
    .irq_enable   (irq_enable),

    .irq_clear    (irq_clear),

    .pending_irq  (pending_irq),

    .cpu_irq      (cpu_irq)
);

endmodule
