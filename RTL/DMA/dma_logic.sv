module dma_logic
(
    input  logic         clk,
    input  logic         rst_n,

    input  logic [31:0]  dma_control,
    input  logic [31:0]  dma_src_addr,
    input  logic [31:0]  dma_dst_addr,
    input  logic [31:0]  dma_length,

    input  logic         dma_start,
    input  logic         dma_int_clear,

    // Simple Memory Interface
    output logic [31:0]  mem_rd_addr,
    input  logic [31:0]  mem_rd_data,

    output logic [31:0]  mem_wr_addr,
    output logic [31:0]  mem_wr_data,
    output logic         mem_wr_en,

    output logic         dma_busy,
    output logic         dma_done,

    output logic         dma_irq_pending,
    output logic         dma_irq
);

import dma_pkg::*;

logic [31:0] src_addr;
logic [31:0] dst_addr;
logic [31:0] transfer_cnt;

logic [31:0] data_buffer;

logic irq_pending_reg;

dma_state_e state;

always_ff @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        state <= DMA_IDLE;

        dma_busy <= 1'b0;
        dma_done <= 1'b0;

        mem_wr_en <= 1'b0;

        irq_pending_reg <= 1'b0;
    end
    else
    begin

        mem_wr_en <= 1'b0;

        if(dma_int_clear)
            irq_pending_reg <= 1'b0;

        case(state)

            //--------------------------------------------------
            DMA_IDLE:
            begin
                dma_done <= 1'b0;

                if(dma_start)
                begin
                    src_addr     <= dma_src_addr;
                    dst_addr     <= dma_dst_addr;
                    transfer_cnt <= dma_length;

                    dma_busy <= 1'b1;

                    state <= DMA_READ;
                end
            end

            //--------------------------------------------------
            DMA_READ:
            begin
                mem_rd_addr <= src_addr;

                data_buffer <= mem_rd_data;

                state <= DMA_WRITE;
            end

            //--------------------------------------------------
            DMA_WRITE:
            begin
                mem_wr_addr <= dst_addr;

                mem_wr_data <= data_buffer;

                mem_wr_en <= 1'b1;

                state <= DMA_CHECK;
            end

            //--------------------------------------------------
            DMA_CHECK:
            begin
                src_addr <= src_addr + 4;

                dst_addr <= dst_addr + 4;

                transfer_cnt <= transfer_cnt - 1;

                if(transfer_cnt == 1)

                    state <= DMA_DONE;

                else

                    state <= DMA_READ;
            end

            //--------------------------------------------------
            DMA_DONE:
            begin
                dma_busy <= 1'b0;

                dma_done <= 1'b1;

                if(dma_control[DMA_IRQ_EN_BIT])

                    irq_pending_reg <= 1'b1;

                state <= DMA_IDLE;
            end

            default :

                state <= DMA_IDLE;

        endcase

    end

end

assign dma_irq_pending = irq_pending_reg;

assign dma_irq = irq_pending_reg;

endmodule