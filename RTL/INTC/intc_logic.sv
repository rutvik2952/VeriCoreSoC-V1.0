module intc_logic
(
    input  logic        clk,
    input  logic        rst_n,

    input  logic [7:0]  irq_in,
    input  logic [7:0]  irq_enable,
    input  logic [7:0]  irq_clear,

    output logic [7:0]  pending_irq,
    output logic        cpu_irq
);

logic [7:0] pending_reg;

//------------------------------------------------------------
// Pending Interrupt Register
//------------------------------------------------------------

always_ff @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        pending_reg <= 8'h00;
    end
    else
    begin

        // Capture enabled interrupts
        pending_reg <= pending_reg | (irq_in & irq_enable);

        // Software Clear
        pending_reg <= (pending_reg | (irq_in & irq_enable))
                       & ~irq_clear;

    end
end

//------------------------------------------------------------
// Outputs
//------------------------------------------------------------

assign pending_irq = pending_reg;

// Generate CPU Interrupt

assign cpu_irq = |pending_reg;

endmodule
