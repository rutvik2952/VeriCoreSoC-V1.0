
module cpu_alu
(
    //------------------------------------------------------------
    // Inputs
    //------------------------------------------------------------

    input  cpu_pkg::alu_opcode_e    alu_op,

    input  logic [31:0]             operand_a,
    input  logic [31:0]             operand_b,

    //------------------------------------------------------------
    // Outputs
    //------------------------------------------------------------

    output logic [31:0]             result,

    output logic                    zero_flag,
    output logic                    negative_flag,
    output logic                    carry_flag,
    output logic                    overflow_flag
);

    //------------------------------------------------------------
    // Internal Signals
    //------------------------------------------------------------

    logic [32:0] add_result;
    logic [32:0] sub_result;

    //------------------------------------------------------------
    // Arithmetic
    //------------------------------------------------------------

    always_comb
    begin

        add_result = {1'b0, operand_a} + {1'b0, operand_b};

        sub_result = {1'b0, operand_a} - {1'b0, operand_b};

    end

    //------------------------------------------------------------
    // ALU
    //------------------------------------------------------------

    always_comb
    begin

        //----------------------------------------
        // Defaults
        //----------------------------------------

        result         = '0;

        carry_flag     = 1'b0;

        overflow_flag  = 1'b0;

        unique case(alu_op)

            //------------------------------------
            // NOP
            //------------------------------------

            cpu_pkg::ALU_NOP :
            begin
                result = operand_a;
            end

            //------------------------------------
            // ADD
            //------------------------------------

            cpu_pkg::ALU_ADD :
            begin

                result = add_result[31:0];

                carry_flag = add_result[32];

                overflow_flag =
                    (~operand_a[31] & ~operand_b[31] & result[31]) |
                    ( operand_a[31] &  operand_b[31] & ~result[31]);

            end

            //------------------------------------
            // SUB
            //------------------------------------

            cpu_pkg::ALU_SUB :
            begin

                result = sub_result[31:0];

                carry_flag = sub_result[32];

                overflow_flag =
                    (~operand_a[31] & operand_b[31] & result[31]) |
                    ( operand_a[31] & ~operand_b[31] & ~result[31]);

            end

            //------------------------------------
            // AND
            //------------------------------------

            cpu_pkg::ALU_AND :
                result = operand_a & operand_b;

            //------------------------------------
            // OR
            //------------------------------------

            cpu_pkg::ALU_OR :
                result = operand_a | operand_b;

            //------------------------------------
            // XOR
            //------------------------------------

            cpu_pkg::ALU_XOR :
                result = operand_a ^ operand_b;

            //------------------------------------
            // NOT
            //------------------------------------

            cpu_pkg::ALU_NOT :
                result = ~operand_a;

            //------------------------------------
            // Shift Left
            //------------------------------------

            cpu_pkg::ALU_SLL :
                result = operand_a << operand_b[4:0];

            //------------------------------------
            // Shift Right Logical
            //------------------------------------

            cpu_pkg::ALU_SRL :
                result = operand_a >> operand_b[4:0];

            //------------------------------------
            // Shift Right Arithmetic
            //------------------------------------

            cpu_pkg::ALU_SRA :
                result = $signed(operand_a) >>> operand_b[4:0];

            //------------------------------------
            // Compare
            //------------------------------------

            cpu_pkg::ALU_CMP :
                result = (operand_a == operand_b);

            //------------------------------------
            // PASS A
            //------------------------------------

            cpu_pkg::ALU_PASS_A :
                result = operand_a;

            //------------------------------------
            // PASS B
            //------------------------------------

            cpu_pkg::ALU_PASS_B :
                result = operand_b;

            default :
                result = '0;

        endcase
    end
	
	    //------------------------------------------------------------
    // ALU Flags
    //------------------------------------------------------------

    assign zero_flag     = (result == 32'd0);

    assign negative_flag = result[31];
/*
    //------------------------------------------------------------
    // Performance Counters
    //------------------------------------------------------------

    logic [31:0] total_operations;
    logic [31:0] arithmetic_operations;
    logic [31:0] logical_operations;
    logic [31:0] shift_operations;
    logic [31:0] compare_operations;

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
        begin

            total_operations      <= '0;
            arithmetic_operations <= '0;
            logical_operations    <= '0;
            shift_operations      <= '0;
            compare_operations    <= '0;

        end
        else
        begin

            total_operations <= total_operations + 1'b1;

            case(alu_op)

                //----------------------------------------
                // Arithmetic
                //----------------------------------------

                cpu_pkg::ALU_ADD,
                cpu_pkg::ALU_SUB :
                    arithmetic_operations <= arithmetic_operations + 1'b1;

                //----------------------------------------
                // Logical
                //----------------------------------------

                cpu_pkg::ALU_AND,
                cpu_pkg::ALU_OR,
                cpu_pkg::ALU_XOR,
                cpu_pkg::ALU_NOT :
                    logical_operations <= logical_operations + 1'b1;

                //----------------------------------------
                // Shift
                //----------------------------------------

                cpu_pkg::ALU_SLL,
                cpu_pkg::ALU_SRL,
                cpu_pkg::ALU_SRA :
                    shift_operations <= shift_operations + 1'b1;

                //----------------------------------------
                // Compare
                //----------------------------------------

                cpu_pkg::ALU_CMP :
                    compare_operations <= compare_operations + 1'b1;

                default : ;

            endcase

        end

    end
*/
/*`ifndef SYNTHESIS

    //------------------------------------------------------------
    // Debug Task
    //------------------------------------------------------------

    task automatic display_alu_status();

        begin

            $display("------------------------------------------");
            $display("ALU OP        : %0d", alu_op);
            $display("Operand A     : %08h", operand_a);
            $display("Operand B     : %08h", operand_b);
            $display("Result        : %08h", result);
            $display("Zero          : %0b", zero_flag);
            $display("Negative      : %0b", negative_flag);
            $display("Carry         : %0b", carry_flag);
            $display("Overflow      : %0b", overflow_flag);
            $display("------------------------------------------");

        end

    endtask

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    // Result shall never contain X

    property p_result_known;

        @(posedge clk)
        disable iff(!rst_n)

        !$isunknown(result);

    endproperty

    assert property(p_result_known)
        else
            $error("CPU_ALU : Result contains unknown.");

    //------------------------------------------------------------

    // Zero flag consistency

    property p_zero_flag;

        @(posedge clk)
        disable iff(!rst_n)

        (result == 32'd0) |-> zero_flag;

    endproperty

    assert property(p_zero_flag)
        else
            $error("CPU_ALU : Zero flag mismatch.");

    //------------------------------------------------------------

    // Negative flag consistency

    property p_negative_flag;

        @(posedge clk)
        disable iff(!rst_n)

        negative_flag == result[31];

    endproperty

    assert property(p_negative_flag)
        else
            $error("CPU_ALU : Negative flag mismatch.");

`endif
*/
endmodule
