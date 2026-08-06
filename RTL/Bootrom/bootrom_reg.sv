

module bootrom_regs
(
    input  logic         rd_en,
    input  logic [31:0]  addr,

    output logic [31:0]  rd_data
);

import bootrom_pkg::*;

always_comb
begin
    rd_data = 32'h0;

    case(addr)

        BOOTROM_BASE_ADDR + 32'h00 :
            rd_data = BOOTROM_ID;

        BOOTROM_BASE_ADDR + 32'h04 :
            rd_data = BOOTROM_VERSION;

        default :
            rd_data = 32'h0;

    endcase
end

endmodule

