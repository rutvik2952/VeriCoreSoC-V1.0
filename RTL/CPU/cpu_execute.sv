module cpu_execute
(
    //------------------------------------------------------------
    // Global Signals
    //------------------------------------------------------------

    input  logic                           clk,
    input  logic                           rst_n,

    //------------------------------------------------------------
    // Decode Stage
    //------------------------------------------------------------

    input  cpu_pkg::decode_packet_t        decode_packet,

    input  logic                           reg_write,
    input  logic                           mem_read,
    input  logic                           mem_write,

    input  logic                           branch,
    input  logic                           jump,

    input  logic                           apb_access,

    input  cpu_pkg::alu_opcode_e           alu_operation,

    //------------------------------------------------------------
    // Register File Inputs
    //------------------------------------------------------------

    input  logic [31:0]                    rs1_data,
    input  logic [31:0]                    rs2_data,

    //------------------------------------------------------------
    // Data Memory Interface
    //------------------------------------------------------------

    output logic                           dmem_cs,
    output logic                           dmem_we,
    output logic                           dmem_re,

    output logic [31:0]                    dmem_addr,
    output logic [31:0]                    dmem_wdata,

    input  logic [31:0]                    dmem_rdata,
    input  logic                           dmem_ready,

    //------------------------------------------------------------
    // Write Back
    //------------------------------------------------------------

    output logic                           wb_valid,

    output logic [3:0]                     wb_rd,

    output logic [31:0]                    wb_data,

    //------------------------------------------------------------
    // Branch Control
    //------------------------------------------------------------

    output logic                           branch_taken,

    output logic [31:0]                    branch_target
);

    //------------------------------------------------------------
    // ALU Signals
    //------------------------------------------------------------

    logic [31:0] alu_result;

    logic        zero_flag;
    logic        negative_flag;
    logic        carry_flag;
    logic        overflow_flag;

    //------------------------------------------------------------
    // ALU Instance
    //------------------------------------------------------------

    cpu_alu
    u_cpu_alu
    (
        .alu_op          (alu_operation),

        .operand_a       (rs1_data),
        .operand_b       (rs2_data),

        .result          (alu_result),

        .zero_flag       (zero_flag),
        .negative_flag   (negative_flag),
        .carry_flag      (carry_flag),
        .overflow_flag   (overflow_flag)
    );

    //------------------------------------------------------------
    // Data Memory Interface
    //------------------------------------------------------------

    assign dmem_cs    = mem_read | mem_write;

    assign dmem_we    = mem_write;

    assign dmem_re    = mem_read;

    assign dmem_addr  = alu_result;

    assign dmem_wdata = rs2_data;
	
	    //------------------------------------------------------------
    // Write Back Logic
    //------------------------------------------------------------

    always_comb
    begin

        //----------------------------------------
        // Defaults
        //----------------------------------------

        wb_valid = 1'b0;

        wb_rd    = decode_packet.rd;

        wb_data  = alu_result;

        //----------------------------------------
        // Register Write
        //----------------------------------------

        if(reg_write)
        begin

            wb_valid = 1'b1;

            if(mem_read)
                wb_data = dmem_rdata;
            else
                wb_data = alu_result;

        end

    end

    //------------------------------------------------------------
    // Branch Logic
    //------------------------------------------------------------

    always_comb
    begin

        //----------------------------------------
        // Defaults
        //----------------------------------------

        branch_taken  = 1'b0;

        branch_target = alu_result;

        //----------------------------------------
        // BEQ
        //----------------------------------------

        if(branch &&
           (decode_packet.opcode == cpu_pkg::OP_BEQ))
        begin

            if(zero_flag)
                branch_taken = 1'b1;

        end

        //----------------------------------------
        // BNE
        //----------------------------------------

        else if(branch &&
                (decode_packet.opcode == cpu_pkg::OP_BNE))
        begin

            if(!zero_flag)
                branch_taken = 1'b1;

        end

        //----------------------------------------
        // JMP / CALL / RET
        //----------------------------------------

        if(jump)
        begin

            branch_taken = 1'b1;

            branch_target = decode_packet.immediate;

        end

    end

    //------------------------------------------------------------
    // APB Placeholder
    //------------------------------------------------------------

    // APB transactions will be generated by
    // cpu_apb_master.sv in the next phase.

    //------------------------------------------------------------
    // Performance Counters
    //------------------------------------------------------------

    logic [31:0] execute_count;

    logic [31:0] memory_count;

    logic [31:0] branch_count;

    logic [31:0] writeback_count;

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            execute_count   <= '0;

            memory_count    <= '0;

            branch_count    <= '0;

            writeback_count <= '0;

        end
        else
        begin

            execute_count <= execute_count + 1'b1;

            if(mem_read || mem_write)
                memory_count <= memory_count + 1'b1;

            if(branch_taken)
                branch_count <= branch_count + 1'b1;

            if(wb_valid)
                writeback_count <= writeback_count + 1'b1;

        end

    end

`ifndef SYNTHESIS

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    // Writeback destination shall never be X

    property p_wb_addr_known;

        @(posedge clk)
        disable iff(!rst_n)

        wb_valid |-> !$isunknown(wb_rd);

    endproperty

    assert property(p_wb_addr_known)
        else
            $error("CPU_EXECUTE : Writeback register unknown.");

    //------------------------------------------------------------

    // Writeback data shall never be X

    property p_wb_data_known;

        @(posedge clk)
        disable iff(!rst_n)

        wb_valid |-> !$isunknown(wb_data);

    endproperty

    assert property(p_wb_data_known)
        else
            $error("CPU_EXECUTE : Writeback data unknown.");

    //------------------------------------------------------------

    // Branch target must be word aligned

    property p_branch_alignment;

        @(posedge clk)
        disable iff(!rst_n)

        branch_taken |-> (branch_target[1:0] == 2'b00);

    endproperty

    assert property(p_branch_alignment)
        else
            $error("CPU_EXECUTE : Branch target misaligned.");

`endif

endmodule
