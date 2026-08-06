
module cpu_fetch
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic                     clk,
    input  logic                     rst_n,

    //------------------------------------------------------------
    // CPU Control
    //------------------------------------------------------------

    input  logic                     stall,
    input  logic                     flush,

    //------------------------------------------------------------
    // Program Counter
    //------------------------------------------------------------

    input  logic [31:0]              pc,

    //------------------------------------------------------------
    // Instruction Memory Interface
    //------------------------------------------------------------

    output logic                     imem_fetch,

    output logic [31:0]              imem_addr,

    input  logic [31:0]              imem_instr,

    input  logic                     imem_ready,

    input  logic                     imem_error,

    //------------------------------------------------------------
    // Fetch Pipeline Output
    //------------------------------------------------------------

    output cpu_pkg::fetch_packet_t   fetch_packet
);

    //------------------------------------------------------------
    // Instruction Memory Request
    //------------------------------------------------------------

    assign imem_fetch = !stall;

    assign imem_addr  = pc;

    //------------------------------------------------------------
    // Fetch Pipeline Register
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            fetch_packet.valid       <= 1'b0;
            fetch_packet.pc          <= cpu_pkg::RESET_VECTOR;
            fetch_packet.instruction <= 32'd0;

        end
        else if(flush)
        begin

            fetch_packet.valid       <= 1'b0;
            fetch_packet.pc          <= pc;
            fetch_packet.instruction <= 32'd0;

        end
        else if(stall)
        begin

            fetch_packet <= fetch_packet;

        end
        else if(imem_ready)
        begin

            fetch_packet.valid       <= 1'b1;
            fetch_packet.pc          <= pc;
            fetch_packet.instruction <= imem_instr;

        end
        else
        begin

            fetch_packet.valid <= 1'b0;

        end

    end
	
	    //------------------------------------------------------------
    // Performance Counters
    //------------------------------------------------------------

    logic [31:0] fetch_count;
    logic [31:0] stall_count;
    logic [31:0] flush_count;
    logic [31:0] fetch_error_count;

    //------------------------------------------------------------
    // Statistics
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            fetch_count       <= '0;
            stall_count       <= '0;
            flush_count       <= '0;
            fetch_error_count <= '0;

        end
        else
        begin

            //----------------------------------------
            // Successful Fetch
            //----------------------------------------

            if(imem_ready && !stall)
                fetch_count <= fetch_count + 1'b1;

            //----------------------------------------
            // Stall Counter
            //----------------------------------------

            if(stall)
                stall_count <= stall_count + 1'b1;

            //----------------------------------------
            // Flush Counter
            //----------------------------------------

            if(flush)
                flush_count <= flush_count + 1'b1;

            //----------------------------------------
            // Memory Error Counter
            //----------------------------------------

            if(imem_error)
                fetch_error_count <= fetch_error_count + 1'b1;

        end

    end

/*
`ifndef SYNTHESIS

    //------------------------------------------------------------
    // Debug Task
    //------------------------------------------------------------

    task automatic display_fetch_status();

        begin

            $display("------------------------------------------");
            $display("FETCH STAGE");
            $display("------------------------------------------");
            $display("PC          : %08h", fetch_packet.pc);
            $display("Instruction : %08h", fetch_packet.instruction);
            $display("Valid       : %0b", fetch_packet.valid);
            $display("IMEM Ready  : %0b", imem_ready);
            $display("IMEM Error  : %0b", imem_error);
            $display("------------------------------------------");

        end

    endtask

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    // PC must be word aligned
    property p_pc_alignment;

        @(posedge clk)
        disable iff(!rst_n)

        imem_fetch |-> (imem_addr[1:0] == 2'b00);

    endproperty

    assert property(p_pc_alignment)
        else
            $error("CPU_FETCH : PC is not word aligned.");

    //------------------------------------------------------------

    // Valid fetch should not contain unknown instruction
    property p_instruction_valid;

        @(posedge clk)
        disable iff(!rst_n)

        fetch_packet.valid |-> !$isunknown(fetch_packet.instruction);

    endproperty

    assert property(p_instruction_valid)
        else
            $error("CPU_FETCH : Instruction contains X.");

    //------------------------------------------------------------

    // Memory error should invalidate fetch packet
    property p_fetch_error;

        @(posedge clk)
        disable iff(!rst_n)

        imem_error |=> !fetch_packet.valid;

    endproperty

    assert property(p_fetch_error)
        else
            $error("CPU_FETCH : Fetch packet remained valid after IMEM error.");

`endif
*/
endmodule
