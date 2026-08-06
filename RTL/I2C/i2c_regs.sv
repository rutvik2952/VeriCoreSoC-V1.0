
module i2c_regs
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
    input  logic [7:0]   rx_data,
    input  logic         i2c_busy,
    input  logic         i2c_ack,
    input  logic         i2c_irq_pending,

    // Register Outputs
    output logic [31:0]  i2c_control,
    output logic [31:0]  i2c_clkdiv,
    output logic [6:0]   i2c_addr,
    output logic [7:0]   i2c_tx_data,

    // Control Pulses
    output logic         i2c_start,
    output logic         i2c_int_clear
);

import i2c_pkg::*;

logic [31:0] control_reg;
logic [31:0] clkdiv_reg;
logic [6:0]  addr_reg;
logic [7:0]  txdata_reg;

always_ff @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        control_reg <= RESET_I2C_CONTROL;
        clkdiv_reg  <= RESET_I2C_CLKDIV;
        addr_reg    <= RESET_I2C_ADDR;
        txdata_reg  <= '0;

        i2c_start     <= 1'b0;
        i2c_int_clear <= 1'b0;
    end
    else
    begin
        i2c_start     <= 1'b0;
        i2c_int_clear <= 1'b0;

        if(wr_en)
        begin
            case(addr)

                I2C_CONTROL_ADDR:
                    control_reg <= wr_data;

                I2C_CLKDIV_ADDR:
                    clkdiv_reg <= wr_data;

                I2C_ADDRESS_ADDR:
                    addr_reg <= wr_data[6:0];

                I2C_TXDATA_ADDR:
                begin
                    txdata_reg <= wr_data[7:0];
                    i2c_start  <= 1'b1;
                end

                I2C_INT_CLEAR_ADDR:
                    i2c_int_clear <= 1'b1;

            endcase
        end
    end
end

always_comb
begin
    rd_data = 32'h0;

    case(addr)

        I2C_ID_ADDR         : rd_data = I2C_ID;
        I2C_VERSION_ADDR    : rd_data = I2C_VERSION;
        I2C_CONTROL_ADDR    : rd_data = control_reg;
        I2C_CLKDIV_ADDR     : rd_data = clkdiv_reg;
        I2C_ADDRESS_ADDR    : rd_data = {25'h0, addr_reg};
        I2C_RXDATA_ADDR     : rd_data = {24'h0, rx_data};

        I2C_STATUS_ADDR:
        begin
            rd_data[I2C_BUSY_BIT] = i2c_busy;
            rd_data[I2C_ACK_BIT]  = i2c_ack;
        end

        I2C_INT_STATUS_ADDR:
            rd_data[0] = i2c_irq_pending;

        default:
            rd_data = 32'h0;

    endcase
end

assign i2c_control = control_reg;
assign i2c_clkdiv  = clkdiv_reg;
assign i2c_addr    = addr_reg;
assign i2c_tx_data = txdata_reg;

endmodule
