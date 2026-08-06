module dma_regs
(
    input  logic         clk,
    input  logic         rst_n,

    // APB Interface
    input  logic         wr_en,
    input  logic         rd_en,
    input  logic [31:0]  addr,
    input  logic [31:0]  wr_data,
    output logic [31:0]  rd_data,

    // Status Inputs
    input  logic         dma_busy,
    input  logic         dma_done,
    input  logic         dma_irq_pending,

    // Register Outputs
    output logic [31:0]  dma_control,
    output logic [31:0]  dma_src_addr,
    output logic [31:0]  dma_dst_addr,
    output logic [31:0]  dma_length,

    // Control Pulses
    output logic         dma_start,
    output logic         dma_int_clear
);

import dma_pkg::*;

logic [31:0] control_reg;
logic [31:0] src_reg;
logic [31:0] dst_reg;
logic [31:0] len_reg;

always_ff @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        control_reg <= RESET_DMA_CONTROL;
        src_reg     <= 32'h0;
        dst_reg     <= 32'h0;
        len_reg     <= RESET_DMA_LENGTH;

        dma_start     <= 1'b0;
        dma_int_clear <= 1'b0;
    end
    else
    begin
        dma_start     <= 1'b0;
        dma_int_clear <= 1'b0;

        if(wr_en)
        begin
            case(addr)

                DMA_CONTROL_ADDR :
                    control_reg <= wr_data;

                DMA_SRC_ADDR :
                    src_reg <= wr_data;

                DMA_DST_ADDR :
                    dst_reg <= wr_data;

                DMA_LENGTH_ADDR :
                begin
                    len_reg    <= wr_data;
                    dma_start  <= 1'b1;
                end

                DMA_INT_CLEAR_ADDR :
                    dma_int_clear <= 1'b1;

            endcase
        end
    end
end

always_comb
begin
    rd_data = 32'h0;

    case(addr)

        DMA_ID_ADDR         : rd_data = DMA_ID;
        DMA_VERSION_ADDR    : rd_data = DMA_VERSION;
        DMA_CONTROL_ADDR    : rd_data = control_reg;
        DMA_SRC_ADDR        : rd_data = src_reg;
        DMA_DST_ADDR        : rd_data = dst_reg;
        DMA_LENGTH_ADDR     : rd_data = len_reg;

        DMA_STATUS_ADDR :
        begin
            rd_data[DMA_BUSY_BIT] = dma_busy;
            rd_data[DMA_DONE_BIT] = dma_done;
        end

        DMA_INT_STATUS_ADDR :
            rd_data[0] = dma_irq_pending;

        default :
            rd_data = 32'h0;

    endcase
end

assign dma_control  = control_reg;
assign dma_src_addr = src_reg;
assign dma_dst_addr = dst_reg;
assign dma_length   = len_reg;

endmodule
