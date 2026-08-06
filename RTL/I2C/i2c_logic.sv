module i2c_logic
(
    input  logic         clk,
    input  logic         rst_n,

    input  logic [31:0]  i2c_control,
    input  logic [31:0]  i2c_clkdiv,

    input  logic [6:0]   i2c_addr,
    input  logic [7:0]   i2c_tx_data,

    input  logic         i2c_start,
    input  logic         i2c_int_clear,

    inout  wire          scl,
    inout  wire          sda,

    output logic [7:0]   rx_data,

    output logic         i2c_busy,
    output logic         i2c_ack,

    output logic         i2c_irq_pending,
    output logic         i2c_irq
);

import i2c_pkg::*;

//------------------------------------------------------------
// Internal Signals
//------------------------------------------------------------

logic [15:0] clk_cnt;
logic        i2c_tick;

logic        scl_out;
logic        sda_out;

logic [7:0] shift_reg;

logic [3:0] bit_cnt;

logic irq_pending_reg;

i2c_state_e state;

//------------------------------------------------------------
// Open Drain
//------------------------------------------------------------

assign scl = (scl_out) ? 1'bz : 1'b0;

assign sda = (sda_out) ? 1'bz : 1'b0;

//------------------------------------------------------------
// Clock Divider
//------------------------------------------------------------

always_ff @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        clk_cnt  <= 0;
        i2c_tick <= 0;
    end
    else
    begin
        i2c_tick <= 0;

        if(clk_cnt >= i2c_clkdiv)
        begin
            clk_cnt  <= 0;
            i2c_tick <= 1'b1;
        end
        else
            clk_cnt <= clk_cnt + 1'b1;
    end
end;

//------------------------------------------------------------
// I2C State Machine
//------------------------------------------------------------

always_ff @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        state     <= I2C_IDLE;
        i2c_busy  <= 0;
        scl_out   <= 1'b1;
        sda_out   <= 1'b1;
        bit_cnt   <= 7;
        shift_reg <= 0;
        rx_data   <= 0;
        i2c_ack   <= 0;
    end
    else if(i2c_tick)
    begin
        case(state)

            I2C_IDLE:
            begin
                if(i2c_start)
                begin
                    i2c_busy <= 1'b1;
                    state <= I2C_START;
                end
            end

            I2C_START:
            begin
                sda_out <= 1'b0;
                shift_reg <= i2c_tx_data;
                bit_cnt <= 7;
                state <= I2C_DATA;
            end

            I2C_DATA:
            begin
                sda_out <= shift_reg[bit_cnt];

                if(bit_cnt==0)
                    state <= I2C_STOP;
                else
                    bit_cnt <= bit_cnt-1;
            end

            I2C_STOP:
            begin
                sda_out <= 1'b1;
                scl_out <= 1'b1;

                i2c_busy <= 1'b0;
                i2c_ack  <= 1'b1;

                rx_data <= shift_reg;

                state <= I2C_IDLE;
            end

            default:
                state <= I2C_IDLE;

        endcase
    end
end;

//------------------------------------------------------------
// Interrupt
//------------------------------------------------------------

always_ff @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        irq_pending_reg <= 0;
    else
    begin
        if(i2c_int_clear)
            irq_pending_reg <= 0;
        else if((state==I2C_STOP) && i2c_control[I2C_IRQ_EN_BIT])
            irq_pending_reg <= 1'b1;
    end
end;

assign i2c_irq_pending = irq_pending_reg;

assign i2c_irq = irq_pending_reg;

endmodule

