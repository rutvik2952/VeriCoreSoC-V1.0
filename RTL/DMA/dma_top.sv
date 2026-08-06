
module dma_top
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
    // Memory Interface
    //------------------------------------------------------------
    output logic [31:0]  mem_rd_addr,
    input  logic [31:0]  mem_rd_data,

    output logic [31:0]  mem_wr_addr,
    output logic [31:0]  mem_wr_data,
    output logic         mem_wr_en,

    //------------------------------------------------------------
    // Interrupt
    //------------------------------------------------------------
    output logic         dma_irq
);

import dma_pkg::*;

//------------------------------------------------------------
// Internal Signals
//------------------------------------------------------------

logic [31:0] dma_control;
logic [31:0] dma_src_addr;
logic [31:0] dma_dst_addr;
logic [31:0] dma_length;

logic dma_start;
logic dma_int_clear;

logic dma_busy;
logic dma_done;

logic dma_irq_pending;

//------------------------------------------------------------
// Register Block
//------------------------------------------------------------

dma_regs u_dma_regs
(
    .clk             (clk),
    .rst_n           (rst_n),

    .wr_en           (wr_en),
    .rd_en           (rd_en),

    .addr            (addr),
    .wr_data         (wr_data),
    .rd_data         (rd_data),

    .dma_busy        (dma_busy),
    .dma_done        (dma_done),
    .dma_irq_pending (dma_irq_pending),

    .dma_control     (dma_control),
    .dma_src_addr    (dma_src_addr),
    .dma_dst_addr    (dma_dst_addr),
    .dma_length      (dma_length),

    .dma_start       (dma_start),
    .dma_int_clear   (dma_int_clear)
);

//------------------------------------------------------------
// DMA Logic
//------------------------------------------------------------

dma_logic u_dma_logic
(
    .clk             (clk),
    .rst_n           (rst_n),

    .dma_control     (dma_control),
    .dma_src_addr    (dma_src_addr),
    .dma_dst_addr    (dma_dst_addr),
    .dma_length      (dma_length),

    .dma_start       (dma_start),
    .dma_int_clear   (dma_int_clear),

    .mem_rd_addr     (mem_rd_addr),
    .mem_rd_data     (mem_rd_data),

    .mem_wr_addr     (mem_wr_addr),
    .mem_wr_data     (mem_wr_data),
    .mem_wr_en       (mem_wr_en),

    .dma_busy        (dma_busy),
    .dma_done        (dma_done),

    .dma_irq_pending (dma_irq_pending),
    .dma_irq         (dma_irq)
);

endmodule
