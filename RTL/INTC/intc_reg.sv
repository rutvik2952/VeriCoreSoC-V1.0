module intc_regs
(
    input  logic         clk,
    input  logic         rst_n,

    // APB Interface
    input  logic         wr_en,
    input  logic         rd_en,
    input  logic [31:0]  addr,
    input  logic [31:0]  wr_data,
    output logic [31:0]  rd_data,

    // Hardware Inputs
    input  logic [7:0]   pending_irq,

    // Register Outputs
    output logic [7:0]   irq_enable,
    output logic [7:0]   irq_priority,

    // Control
    output logic [7:0]   irq_clear
);

import intc_pkg::*;

logic [7:0] enable_reg;
logic [7:0] priority_reg;
logic [7:0] clear_reg;

always_ff @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        enable_reg   <= RESET_INT_ENABLE;
        priority_reg <= RESET_INT_PRIORITY;
        clear_reg    <= 8'h00;
    end
    else
    begin
        clear_reg <= 8'h00;

        if(wr_en)
        begin
            case(addr)

                INTC_ENABLE_ADDR :
                    enable_reg <= wr_data[7:0];

                INTC_PRIORITY_ADDR :
                    priority_reg <= wr_data[7:0];

                INTC_CLEAR_ADDR :
                    clear_reg <= wr_data[7:0];

            endcase
        end
    end
end

always_comb
begin
    rd_data = 32'h0;

    case(addr)

        INTC_ID_ADDR       : rd_data = INTC_ID;
        INTC_VERSION_ADDR  : rd_data = INTC_VERSION;
        INTC_ENABLE_ADDR   : rd_data = {24'h0, enable_reg};
        INTC_PENDING_ADDR  : rd_data = {24'h0, pending_irq};
        INTC_PRIORITY_ADDR : rd_data = {24'h0, priority_reg};

        default :
            rd_data = 32'h0;

    endcase
end

assign irq_enable   = enable_reg;
assign irq_priority = priority_reg;
assign irq_clear    = clear_reg;

endmodule

`default_nettype wire