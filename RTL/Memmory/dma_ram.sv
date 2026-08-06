module dma_ram
#(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 13,
    parameter int DEPTH      = (1<<ADDR_WIDTH)
)
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic                     clk,
    input  logic                     rst_n,

    //------------------------------------------------------------
    // DMA Interface
    //------------------------------------------------------------

    input  logic                     dma_cs,
    input  logic                     dma_we,
    input  logic                     dma_re,

    input  logic [ADDR_WIDTH-1:0]    dma_addr,

    input  logic [DATA_WIDTH-1:0]    dma_wdata,

    input  logic [(DATA_WIDTH/8)-1:0] dma_be,

    output logic [DATA_WIDTH-1:0]    dma_rdata,

    output logic                     dma_ready,

    output logic                     dma_error,

    //------------------------------------------------------------
    // Future CPU Port (Reserved)
    //------------------------------------------------------------

    input  logic                     cpu_cs,
    input  logic                     cpu_we,
    input  logic                     cpu_re,

    input  logic [ADDR_WIDTH-1:0]    cpu_addr,

    input  logic [DATA_WIDTH-1:0]    cpu_wdata,

    input  logic [(DATA_WIDTH/8)-1:0] cpu_be,

    output logic [DATA_WIDTH-1:0]    cpu_rdata,

    output logic                     cpu_ready,

    output logic                     cpu_error
);

    //------------------------------------------------------------
    // Internal Signals
    //------------------------------------------------------------

    logic [DATA_WIDTH-1:0] ram_rdata;

    logic ram_cs;
    logic ram_we;
    logic ram_re;

    logic [ADDR_WIDTH-1:0] ram_addr;
    logic [DATA_WIDTH-1:0] ram_wdata;
    logic [(DATA_WIDTH/8)-1:0] ram_be;

    //------------------------------------------------------------
    // Port Arbitration
    //------------------------------------------------------------
    // Current implementation:
    // DMA has higher priority than CPU.
    // In a future enhancement, this can be replaced
    // with a round-robin arbiter or true dual-port RAM.
    //------------------------------------------------------------

    always_comb
    begin

        if(dma_cs)
        begin

            ram_cs    = dma_cs;
            ram_we    = dma_we;
            ram_re    = dma_re;

            ram_addr  = dma_addr;
            ram_wdata = dma_wdata;
            ram_be    = dma_be;

        end
        else
        begin

            ram_cs    = cpu_cs;
            ram_we    = cpu_we;
            ram_re    = cpu_re;

            ram_addr  = cpu_addr;
            ram_wdata = cpu_wdata;
            ram_be    = cpu_be;

        end

    end

    //------------------------------------------------------------
    // Generic RAM
    //------------------------------------------------------------

    generic_ram
    #(
        .DATA_WIDTH     (DATA_WIDTH),
        .ADDR_WIDTH     (ADDR_WIDTH),
        .DEPTH          (DEPTH),
        .READ_ONLY      (1'b0),
        .OUTPUT_REG     (1'b1),
        .MEM_INIT_FILE  (1'b0),
        .INIT_FILE      ("")
    )
    u_dma_ram
    (
        .clk        (clk),
        .rst_n      (rst_n),

        .cs         (ram_cs),
        .we         (ram_we),
        .re         (ram_re),

        .addr       (ram_addr),

        .wdata      (ram_wdata),

        .be         (ram_be),

        .rdata      (ram_rdata),

        .ready      (),
        .error      ()
    );

    //------------------------------------------------------------
    // Return Data
    //------------------------------------------------------------

    assign dma_rdata = ram_rdata;
    assign cpu_rdata = ram_rdata;

    assign dma_ready = dma_cs;
    assign cpu_ready = cpu_cs;

    assign dma_error = 1'b0;
    assign cpu_error = 1'b0;
	
	    //------------------------------------------------------------
    // Performance Counters
    //------------------------------------------------------------

    logic [31:0] dma_read_count;
    logic [31:0] dma_write_count;

    logic [31:0] cpu_read_count;
    logic [31:0] cpu_write_count;

    logic [31:0] arbitration_count;
    logic [31:0] collision_count;

    //------------------------------------------------------------
    // Collision Detection
    //------------------------------------------------------------

    logic access_collision;

    assign access_collision =
            dma_cs &&
            cpu_cs;

    //------------------------------------------------------------
    // Statistics
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            dma_read_count  <= '0;
            dma_write_count <= '0;

            cpu_read_count  <= '0;
            cpu_write_count <= '0;

            arbitration_count <= '0;
            collision_count   <= '0;

        end
        else
        begin

            //------------------------------------
            // DMA Statistics
            //------------------------------------

            if(dma_cs && dma_re)
                dma_read_count <= dma_read_count + 1'b1;

            if(dma_cs && dma_we)
                dma_write_count <= dma_write_count + 1'b1;

            //------------------------------------
            // CPU Statistics
            //------------------------------------

            if(cpu_cs && !dma_cs && cpu_re)
                cpu_read_count <= cpu_read_count + 1'b1;

            if(cpu_cs && !dma_cs && cpu_we)
                cpu_write_count <= cpu_write_count + 1'b1;

            //------------------------------------
            // Arbitration Statistics
            //------------------------------------

            if(access_collision)
            begin

                arbitration_count <= arbitration_count + 1'b1;
                collision_count   <= collision_count + 1'b1;

            end

        end

    end

`ifndef SYNTHESIS

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    // DMA has priority during simultaneous access
    property p_dma_priority;

        @(posedge clk)
        disable iff(!rst_n)

        access_collision |-> ram_addr == dma_addr;

    endproperty

    assert property(p_dma_priority)
        else
            $error("DMA_RAM : DMA priority arbitration failed.");

    //------------------------------------------------------------

    // CPU transactions are blocked during DMA ownership
    property p_cpu_blocked;

        @(posedge clk)
        disable iff(!rst_n)

        dma_cs && cpu_cs |-> !cpu_we && !cpu_re;

    endproperty

    assert property(p_cpu_blocked)
        else
            $warning("DMA_RAM : CPU request present during DMA ownership.");

    //------------------------------------------------------------

    // Read and write cannot occur together on selected port
    property p_rw_exclusive;

        @(posedge clk)
        disable iff(!rst_n)

        !(ram_we && ram_re);

    endproperty

    assert property(p_rw_exclusive)
        else
            $error("DMA_RAM : Read and Write active simultaneously.");

    //------------------------------------------------------------

    // Read data should never contain X
    property p_rdata_valid;

        @(posedge clk)
        disable iff(!rst_n)

        ram_re |-> !$isunknown(ram_rdata);

    endproperty

    assert property(p_rdata_valid)
        else
            $error("DMA_RAM : Read data contains unknown.");

`endif

endmodule

