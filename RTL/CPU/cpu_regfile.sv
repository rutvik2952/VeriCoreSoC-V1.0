
module cpu_regfile
#(
    parameter int REG_WIDTH = 32,
    parameter int REG_COUNT = 16,
    parameter int ADDR_WIDTH = $clog2(REG_COUNT)
)
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic                     clk,
    input  logic                     rst_n,

    //------------------------------------------------------------
    // Read Port-1
    //------------------------------------------------------------

    input  logic                     rd1_en,
    input  logic [ADDR_WIDTH-1:0]    rd1_addr,

    output logic [REG_WIDTH-1:0]     rd1_data,

    //------------------------------------------------------------
    // Read Port-2
    //------------------------------------------------------------

    input  logic                     rd2_en,
    input  logic [ADDR_WIDTH-1:0]    rd2_addr,

    output logic [REG_WIDTH-1:0]     rd2_data,

    //------------------------------------------------------------
    // Write Port
    //------------------------------------------------------------

    input  logic                     wr_en,
    input  logic [ADDR_WIDTH-1:0]    wr_addr,
    input  logic [REG_WIDTH-1:0]     wr_data,

    //------------------------------------------------------------
    // Debug Port
    //------------------------------------------------------------

    input  logic                     dbg_rd_en,
    input  logic [ADDR_WIDTH-1:0]    dbg_rd_addr,

    output logic [REG_WIDTH-1:0]     dbg_rd_data
);

    //------------------------------------------------------------
    // Register File
    //------------------------------------------------------------

    logic [REG_WIDTH-1:0] reg_mem [0:REG_COUNT-1];

    integer i;

    //------------------------------------------------------------
    // Register Reset / Write
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            for(i=0;i<REG_COUNT;i++)
                reg_mem[i] <= '0;

        end
        else
        begin

            //----------------------------------------
            // R0 is Hardwired to Zero
            //----------------------------------------

            reg_mem[0] <= '0;

            //----------------------------------------
            // Register Write
            //----------------------------------------

            if(wr_en && (wr_addr != '0))
            begin

                reg_mem[wr_addr] <= wr_data;

            end

        end

    end

    //------------------------------------------------------------
    // Read Port-1
    //------------------------------------------------------------

    always_comb
    begin

        if(rd1_en)
            rd1_data = reg_mem[rd1_addr];
        else
            rd1_data = '0;

    end

    //------------------------------------------------------------
    // Read Port-2
    //------------------------------------------------------------

    always_comb
    begin

        if(rd2_en)
            rd2_data = reg_mem[rd2_addr];
        else
            rd2_data = '0;

    end

    //------------------------------------------------------------
    // Debug Read
    //------------------------------------------------------------

    always_comb
    begin

        if(dbg_rd_en)
            dbg_rd_data = reg_mem[dbg_rd_addr];
        else
            dbg_rd_data = '0;

    end
	
	    //------------------------------------------------------------
    // Performance Counters
    //------------------------------------------------------------

    logic [31:0] rd1_count;
    logic [31:0] rd2_count;
    logic [31:0] wr_count;
    logic [31:0] dbg_read_count;

    logic [31:0] r0_write_attempts;

    //------------------------------------------------------------
    // Register Statistics
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            rd1_count         <= '0;
            rd2_count         <= '0;
            wr_count          <= '0;
            dbg_read_count    <= '0;

            r0_write_attempts <= '0;

        end
        else
        begin

            //----------------------------------------
            // Read Port Statistics
            //----------------------------------------

            if(rd1_en)
                rd1_count <= rd1_count + 1'b1;

            if(rd2_en)
                rd2_count <= rd2_count + 1'b1;

            //----------------------------------------
            // Write Statistics
            //----------------------------------------

            if(wr_en && (wr_addr != '0))
                wr_count <= wr_count + 1'b1;

            //----------------------------------------
            // R0 Write Attempt
            //----------------------------------------

            if(wr_en && (wr_addr == '0))
                r0_write_attempts <= r0_write_attempts + 1'b1;

            //----------------------------------------
            // Debug Read Statistics
            //----------------------------------------

            if(dbg_rd_en)
                dbg_read_count <= dbg_read_count + 1'b1;

        end

    end

`ifndef SYNTHESIS

    //------------------------------------------------------------
    // Register Dump Task
    //------------------------------------------------------------

    task automatic dump_registers();

        integer idx;

        begin

            $display("--------------------------------------------");
            $display(" TinyCPU Register File");
            $display("--------------------------------------------");

            for(idx=0; idx<REG_COUNT; idx++)
                $display("R%0d = 0x%08h", idx, reg_mem[idx]);

            $display("--------------------------------------------");

        end

    endtask

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    // R0 must always remain zero

    property p_r0_constant;

        @(posedge clk)
        disable iff(!rst_n)

        reg_mem[0] == '0;

    endproperty

    assert property(p_r0_constant)
        else
            $error("CPU_REGFILE : R0 modified.");

    //------------------------------------------------------------

    // Read data should never contain X

    property p_rd1_known;

        @(posedge clk)
        disable iff(!rst_n)

        rd1_en |-> !$isunknown(rd1_data);

    endproperty

    assert property(p_rd1_known)
        else
            $error("CPU_REGFILE : RD1 contains X.");

    //------------------------------------------------------------

    property p_rd2_known;

        @(posedge clk)
        disable iff(!rst_n)

        rd2_en |-> !$isunknown(rd2_data);

    endproperty

    assert property(p_rd2_known)
        else
            $error("CPU_REGFILE : RD2 contains X.");

    //------------------------------------------------------------

    property p_dbg_known;

        @(posedge clk)
        disable iff(!rst_n)

        dbg_rd_en |-> !$isunknown(dbg_rd_data);

    endproperty

    assert property(p_dbg_known)
        else
            $error("CPU_REGFILE : Debug read contains X.");

`endif

endmodule
