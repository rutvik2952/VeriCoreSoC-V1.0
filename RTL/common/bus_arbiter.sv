module bus_arbiter
(
    //------------------------------------------------------------
    // CPU APB Master Interface
    //------------------------------------------------------------

    input  logic        cpu_req,

    input  logic        cpu_psel,
    input  logic        cpu_penable,
    input  logic        cpu_pwrite,

    input  logic [31:0] cpu_paddr,
    input  logic [31:0] cpu_pwdata,

    output logic [31:0] cpu_prdata,
    output logic        cpu_pready,
    output logic        cpu_pslverr,

    //------------------------------------------------------------
    // External APB Master Interface
    //------------------------------------------------------------

    input  logic        apb_req,

    input  logic        apb_psel,
    input  logic        apb_penable,
    input  logic        apb_pwrite,

    input  logic [31:0] apb_paddr,
    input  logic [31:0] apb_pwdata,

    output logic [31:0] apb_prdata,
    output logic        apb_pready,
    output logic        apb_pslverr,

    //------------------------------------------------------------
    // Shared System Bus
    //------------------------------------------------------------

    output logic        sys_psel,
    output logic        sys_penable,
    output logic        sys_pwrite,

    output logic [31:0] sys_paddr,
    output logic [31:0] sys_pwdata,

    input  logic [31:0] sys_prdata,
    input  logic        sys_pready,
    input  logic        sys_pslverr,

    //------------------------------------------------------------
    // Arbitration Status
    //------------------------------------------------------------

    output logic        cpu_grant,
    output logic        apb_grant,
    output logic        arb_error
);

        //------------------------------------------------------------
    // Arbitration Logic
    //------------------------------------------------------------

    always_comb
    begin

        cpu_grant = 1'b0;
        apb_grant = 1'b0;
        arb_error = 1'b0;

        unique case ({cpu_req, apb_req})

            // No Request
            2'b00 :
            begin
                cpu_grant = 1'b0;
                apb_grant = 1'b0;
            end

            // CPU Request
            2'b10 :
            begin
                cpu_grant = 1'b1;
                apb_grant = 1'b0;
            end

            // APB Request
            2'b01 :
            begin
                cpu_grant = 1'b0;
                apb_grant = 1'b1;
            end

            // Both Request -> Reject
            2'b11 :
            begin
                cpu_grant = 1'b0;
                apb_grant = 1'b0;
                arb_error = 1'b1;
            end

        endcase

    end

    //------------------------------------------------------------
    // System Bus Multiplexer
    //------------------------------------------------------------

    always_comb
    begin

        sys_psel    = 1'b0;
        sys_penable = 1'b0;
        sys_pwrite  = 1'b0;

        sys_paddr   = 32'h0000_0000;
        sys_pwdata  = 32'h0000_0000;

        if(cpu_grant)
        begin

            sys_psel    = cpu_psel;
            sys_penable = cpu_penable;
            sys_pwrite  = cpu_pwrite;

            sys_paddr   = cpu_paddr;
            sys_pwdata  = cpu_pwdata;

        end
        else if(apb_grant)
        begin

            sys_psel    = apb_psel;
            sys_penable = apb_penable;
            sys_pwrite  = apb_pwrite;

            sys_paddr   = apb_paddr;
            sys_pwdata  = apb_pwdata;

        end

    end
	
	    //------------------------------------------------------------
    // Response Routing
    //------------------------------------------------------------

    always_comb
    begin

        //--------------------------------------------------------
        // Default Outputs
        //--------------------------------------------------------

        cpu_prdata  = 32'h0000_0000;
        cpu_pready  = 1'b0;
        cpu_pslverr = 1'b0;

        apb_prdata  = 32'h0000_0000;
        apb_pready  = 1'b0;
        apb_pslverr = 1'b0;

        //--------------------------------------------------------
        // Route Response to CPU
        //--------------------------------------------------------

        if(cpu_grant)
        begin

            cpu_prdata  = sys_prdata;
            cpu_pready  = sys_pready;
            cpu_pslverr = sys_pslverr;

        end

        //--------------------------------------------------------
        // Route Response to APB Master
        //--------------------------------------------------------

        else if(apb_grant)
        begin

            apb_prdata  = sys_prdata;
            apb_pready  = sys_pready;
            apb_pslverr = sys_pslverr;

        end

    end

endmodule