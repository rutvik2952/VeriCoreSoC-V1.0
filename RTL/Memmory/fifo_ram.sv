module fifo_ram
#(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 64,
    parameter int ADDR_WIDTH = $clog2(DEPTH),

    parameter int ALMOST_FULL_LEVEL  = DEPTH-4,
    parameter int ALMOST_EMPTY_LEVEL = 4
)
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic                  clk,
    input  logic                  rst_n,

    //------------------------------------------------------------
    // Write Interface
    //------------------------------------------------------------

    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] wr_data,

    //------------------------------------------------------------
    // Read Interface
    //------------------------------------------------------------

    input  logic                  rd_en,

    output logic [DATA_WIDTH-1:0] rd_data,

    //------------------------------------------------------------
    // Status
    //------------------------------------------------------------

    output logic                  full,
    output logic                  empty,

    output logic                  almost_full,
    output logic                  almost_empty,

    output logic                  overflow,
    output logic                  underflow,

    output logic [ADDR_WIDTH:0]   occupancy
);

    //------------------------------------------------------------
    // Internal Pointers
    //------------------------------------------------------------

    logic [ADDR_WIDTH-1:0] wr_ptr;
    logic [ADDR_WIDTH-1:0] rd_ptr;

    logic                  ram_cs;
    logic                  ram_we;
    logic                  ram_re;

    //------------------------------------------------------------
    // Generic RAM
    //------------------------------------------------------------

    generic_ram
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DEPTH(DEPTH)
    )
    u_fifo_ram
    (
        .clk    (clk),
        .rst_n  (rst_n),

        .cs     (ram_cs),

        .we     (ram_we),

        .re     (ram_re),

        .addr   (ram_we ? wr_ptr : rd_ptr),

        .wdata  (wr_data),

        .be     ('1),

        .rdata  (rd_data),

        .ready  (),

        .error  ()
    );

    //------------------------------------------------------------
    // RAM Control
    //------------------------------------------------------------

    assign ram_cs = wr_en | rd_en;

    assign ram_we = wr_en & !full;

    assign ram_re = rd_en & !empty;
	
	    //------------------------------------------------------------
    // Pointer Management
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            wr_ptr <= '0;
            rd_ptr <= '0;

        end
        else
        begin

            //------------------------------------
            // Write Pointer
            //------------------------------------

            if(ram_we)
                wr_ptr <= wr_ptr + 1'b1;

            //------------------------------------
            // Read Pointer
            //------------------------------------

            if(ram_re)
                rd_ptr <= rd_ptr + 1'b1;

        end

    end

    //------------------------------------------------------------
    // Occupancy Counter
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            occupancy <= '0;

        end
        else
        begin

            unique case ({ram_we,ram_re})

                //--------------------------------
                // Write Only
                //--------------------------------

                2'b10 :
                    occupancy <= occupancy + 1'b1;

                //--------------------------------
                // Read Only
                //--------------------------------

                2'b01 :
                    occupancy <= occupancy - 1'b1;

                //--------------------------------
                // No Change
                //--------------------------------

                default :
                    occupancy <= occupancy;

            endcase

        end

    end

    //------------------------------------------------------------
    // FIFO Status
    //------------------------------------------------------------

    assign full         = (occupancy == DEPTH);

    assign empty        = (occupancy == 0);

    assign almost_full  = (occupancy >= ALMOST_FULL_LEVEL);

    assign almost_empty = (occupancy <= ALMOST_EMPTY_LEVEL);

    //------------------------------------------------------------
    // Overflow / Underflow Detection
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            overflow  <= 1'b0;
            underflow <= 1'b0;

        end
        else
        begin

            overflow  <= wr_en && full;

            underflow <= rd_en && empty;

        end

    end
	
	    //------------------------------------------------------------
    // Performance Counters
    //------------------------------------------------------------

    logic [31:0] write_count;
    logic [31:0] read_count;
    logic [31:0] overflow_count;
    logic [31:0] underflow_count;

    logic [ADDR_WIDTH:0] high_watermark;
    logic [ADDR_WIDTH:0] low_watermark;

    //------------------------------------------------------------
    // Statistics
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            write_count     <= '0;
            read_count      <= '0;
            overflow_count  <= '0;
            underflow_count <= '0;

            high_watermark  <= '0;
            low_watermark   <= DEPTH;

        end
        else
        begin

            //------------------------------------
            // Read/Write Statistics
            //------------------------------------

            if(ram_we)
                write_count <= write_count + 1'b1;

            if(ram_re)
                read_count <= read_count + 1'b1;

            //------------------------------------
            // Error Statistics
            //------------------------------------

            if(overflow)
                overflow_count <= overflow_count + 1'b1;

            if(underflow)
                underflow_count <= underflow_count + 1'b1;

            //------------------------------------
            // High Water Mark
            //------------------------------------

            if(occupancy > high_watermark)
                high_watermark <= occupancy;

            //------------------------------------
            // Low Water Mark
            //------------------------------------

            if(occupancy < low_watermark)
                low_watermark <= occupancy;

        end

    end

`ifndef SYNTHESIS

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    // Occupancy shall never exceed DEPTH

    property p_fifo_depth;

        @(posedge clk)
        disable iff(!rst_n)

        occupancy <= DEPTH;

    endproperty

    assert property(p_fifo_depth)
        else
            $error("FIFO_RAM : Occupancy exceeded FIFO depth.");

    //------------------------------------------------------------

    // Empty and Full shall never be asserted together

    property p_full_empty;

        @(posedge clk)
        disable iff(!rst_n)

        !(full && empty);

    endproperty

    assert property(p_full_empty)
        else
            $error("FIFO_RAM : FULL and EMPTY asserted simultaneously.");

    //------------------------------------------------------------

    // Read when empty

    property p_no_read_empty;

        @(posedge clk)
        disable iff(!rst_n)

        rd_en && empty |-> underflow;

    endproperty

    assert property(p_no_read_empty)
        else
            $error("FIFO_RAM : Underflow not detected.");

    //------------------------------------------------------------

    // Write when full

    property p_no_write_full;

        @(posedge clk)
        disable iff(!rst_n)

        wr_en && full |-> overflow;

    endproperty

    assert property(p_no_write_full)
        else
            $error("FIFO_RAM : Overflow not detected.");

    //------------------------------------------------------------

    // Read Data shall never be X

    property p_rdata_valid;

        @(posedge clk)
        disable iff(!rst_n)

        ram_re |-> !$isunknown(rd_data);

    endproperty

    assert property(p_rdata_valid)
        else
            $error("FIFO_RAM : Read data contains unknown.");

`endif

endmodule
