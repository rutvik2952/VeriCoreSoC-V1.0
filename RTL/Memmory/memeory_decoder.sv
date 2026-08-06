module memory_decoder
#(
    parameter ADDR_WIDTH = 32
)
(
    //------------------------------------------------------------
    // Shared System Bus
    //------------------------------------------------------------

    input  logic                     psel,
    input  logic [ADDR_WIDTH-1:0]    paddr,

    //------------------------------------------------------------
    // Memory Select Outputs
    //------------------------------------------------------------

    output logic                     bootrom_sel,
    output logic                     imem_sel,
    output logic                     dmem_sel,
    output logic                     dma_ram_sel,

    //------------------------------------------------------------
    // Status
    //------------------------------------------------------------

    output logic                     decode_error
);

    //------------------------------------------------------------
    // Memory Address Map
    //------------------------------------------------------------

    localparam logic [31:0] BOOTROM_BASE = 32'h0000_0000;
    localparam logic [31:0] BOOTROM_SIZE = 32'h0000_1000;   // 4 KB

    localparam logic [31:0] IMEM_BASE    = 32'h0001_0000;
    localparam logic [31:0] IMEM_SIZE    = 32'h0001_0000;   // 64 KB

    localparam logic [31:0] DMEM_BASE    = 32'h0002_0000;
    localparam logic [31:0] DMEM_SIZE    = 32'h0001_0000;   // 64 KB

    localparam logic [31:0] DMA_RAM_BASE = 32'h0003_0000;
    localparam logic [31:0] DMA_RAM_SIZE = 32'h0001_0000;   // 64 KB

    //------------------------------------------------------------
    // Address Decode
    //------------------------------------------------------------

    always_comb
    begin

        bootrom_sel   = 1'b0;
        imem_sel      = 1'b0;
        dmem_sel      = 1'b0;
        dma_ram_sel   = 1'b0;
        decode_error  = 1'b0;

        if (psel)
        begin

            if ((paddr >= BOOTROM_BASE) &&
                (paddr < (BOOTROM_BASE + BOOTROM_SIZE)))
            begin
                bootrom_sel = 1'b1;
            end

            else if ((paddr >= IMEM_BASE) &&
                     (paddr < (IMEM_BASE + IMEM_SIZE)))
            begin
                imem_sel = 1'b1;
            end

            else if ((paddr >= DMEM_BASE) &&
                     (paddr < (DMEM_BASE + DMEM_SIZE)))
            begin
                dmem_sel = 1'b1;
            end

            else if ((paddr >= DMA_RAM_BASE) &&
                     (paddr < (DMA_RAM_BASE + DMA_RAM_SIZE)))
            begin
                dma_ram_sel = 1'b1;
            end

            else
            begin
                decode_error = 1'b1;
            end

        end

    end

`ifndef SYNTHESIS

    //------------------------------------------------------------
    // One-Hot Decode Check
    //------------------------------------------------------------

    assert property
    (
        @(posedge psel)
        $onehot0({bootrom_sel,
                  imem_sel,
                  dmem_sel,
                  dma_ram_sel})
    )
    else
        $error("MEMORY_DECODER : Multiple memories selected.");

`endif

endmodule
