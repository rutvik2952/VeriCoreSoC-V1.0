
module cpu_pc
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic         clk,
    input  logic         rst_n,

    //------------------------------------------------------------
    // CPU Control
    //------------------------------------------------------------

    input  logic         stall,
    input  logic         flush,

    input  logic         branch_taken,
    input  logic         jump_taken,
    input  logic         interrupt_taken,

    //------------------------------------------------------------
    // Target Addresses
    //------------------------------------------------------------

    input  logic [31:0]  branch_addr,
    input  logic [31:0]  jump_addr,
    input  logic [31:0]  interrupt_vector,

    //------------------------------------------------------------
    // Program Counter
    //------------------------------------------------------------

    output logic [31:0]  pc,
    output logic [31:0]  next_pc
);

    //------------------------------------------------------------
    // Next PC Logic
    //------------------------------------------------------------

    always_comb
    begin

        //----------------------------------------
        // Default
        //----------------------------------------

        next_pc = pc + 32'd4;

        //----------------------------------------
        // Interrupt has highest priority
        //----------------------------------------

        if(interrupt_taken)
        begin

            next_pc = interrupt_vector;

        end

        //----------------------------------------
        // Jump
        //----------------------------------------

        else if(jump_taken)
        begin

            next_pc = jump_addr;

        end

        //----------------------------------------
        // Branch
        //----------------------------------------

        else if(branch_taken)
        begin

            next_pc = branch_addr;

        end

    end

    //------------------------------------------------------------
    // Program Counter Register
    //------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            pc <= cpu_pkg::RESET_VECTOR;

        end
		        else if(stall)
        begin

            //----------------------------------------
            // Hold Current PC
            //----------------------------------------

            pc <= pc;

        end
        else if(flush)
        begin

            //----------------------------------------
            // Pipeline Flush
            //----------------------------------------

            pc <= next_pc;

        end
        else
        begin

            //----------------------------------------
            // Normal PC Update
            //----------------------------------------

            pc <= next_pc;

        end

    end

    //------------------------------------------------------------
    // Performance Counters
    //------------------------------------------------------------

    logic [31:0] instruction_count;
    logic [31:0] branch_count;
    logic [31:0] jump_count;
    logic [31:0] interrupt_count;
    logic [31:0] stall_count;

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            instruction_count <= '0;
            branch_count      <= '0;
            jump_count        <= '0;
            interrupt_count   <= '0;
            stall_count       <= '0;

        end
        else
        begin

            if(!stall)
                instruction_count <= instruction_count + 1'b1;

            if(branch_taken)
                branch_count <= branch_count + 1'b1;

            if(jump_taken)
                jump_count <= jump_count + 1'b1;

            if(interrupt_taken)
                interrupt_count <= interrupt_count + 1'b1;

            if(stall)
                stall_count <= stall_count + 1'b1;

        end

    end

`ifndef SYNTHESIS

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    // PC shall always be word aligned

    property p_pc_alignment;

        @(posedge clk)
        disable iff(!rst_n)

        pc[1:0] == 2'b00;

    endproperty

    assert property(p_pc_alignment)
        else
            $error("CPU_PC : PC is not word aligned.");

    //------------------------------------------------------------

    // Stall holds the PC

    property p_stall_hold;

        @(posedge clk)
        disable iff(!rst_n)

        stall |=> $stable(pc);

    endproperty

    assert property(p_stall_hold)
        else
            $error("CPU_PC : PC changed during stall.");

    //------------------------------------------------------------

    // Interrupt has highest priority

    property p_interrupt_priority;

        @(posedge clk)
        disable iff(!rst_n)

        interrupt_taken |=> (pc == interrupt_vector);

    endproperty

    assert property(p_interrupt_priority)
        else
            $error("CPU_PC : Interrupt vector not loaded.");

    //------------------------------------------------------------

    // PC must never contain X

    property p_pc_known;

        @(posedge clk)
        disable iff(!rst_n)

        !$isunknown(pc);

    endproperty

    assert property(p_pc_known)
        else
            $error("CPU_PC : PC contains unknown value.");

`endif

endmodule
