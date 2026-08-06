
module apb_mux
#(
    parameter int DATA_WIDTH = 32,
    parameter int NUM_SLAVES = 16
)
(
    //------------------------------------------------------------
    // Slave Select
    //------------------------------------------------------------
    input  logic [NUM_SLAVES-1:0]                 slave_sel,

    //------------------------------------------------------------
    // Slave Responses
    //------------------------------------------------------------
    input  logic [NUM_SLAVES-1:0][DATA_WIDTH-1:0] slave_prdata,
    input  logic [NUM_SLAVES-1:0]                 slave_pready,
    input  logic [NUM_SLAVES-1:0]                 slave_pslverr,

    //------------------------------------------------------------
    // Default Slave Response
    //------------------------------------------------------------
    input  logic [DATA_WIDTH-1:0]                 default_prdata,
    input  logic                                  default_pready,
    input  logic                                  default_pslverr,

    input  logic                                  decode_error,

    //------------------------------------------------------------
    // Master Response
    //------------------------------------------------------------
    output logic [DATA_WIDTH-1:0]                 prdata,
    output logic                                  pready,
    output logic                                  pslverr
);

    integer i;

    //------------------------------------------------------------
    // Response Multiplexer
    //------------------------------------------------------------

    always_comb
    begin

        //----------------------------------------
        // Default Outputs
        //----------------------------------------

        prdata  = default_prdata;
        pready  = default_pready;
        pslverr = default_pslverr;

        //----------------------------------------
        // Valid Decode
        //----------------------------------------

        if(!decode_error)
        begin

            for(i=0;i<NUM_SLAVES;i++)
            begin

                if(slave_sel[i])
                begin

                    prdata  = slave_prdata[i];
                    pready  = slave_pready[i];
                    pslverr = slave_pslverr[i];

                end

            end

        end

    end
	    //------------------------------------------------------------
    // Selected Slave Index
    //------------------------------------------------------------

    logic [$clog2(NUM_SLAVES)-1:0] selected_slave;

    always_comb
    begin

        selected_slave = '0;

        for(int j=0; j<NUM_SLAVES; j++)
        begin
            if(slave_sel[j])
                selected_slave = j[$clog2(NUM_SLAVES)-1:0];
        end

    end

    //------------------------------------------------------------
    // Number of Selected Slaves
    //------------------------------------------------------------

    logic [$clog2(NUM_SLAVES+1)-1:0] selected_count;

    always_comb
    begin

        selected_count = '0;

        for(int j=0; j<NUM_SLAVES; j++)
            selected_count += slave_sel[j];

    end

`ifndef SYNTHESIS

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    // Only one slave can be selected
    property p_onehot_slave_select;
        @(posedge pready)
        $onehot0(slave_sel);
    endproperty

    assert property(p_onehot_slave_select)
        else
            $error("APB_MUX : Multiple slave selects detected.");

    // Decode error implies no slave selected
    property p_decode_error;
        @(posedge pready)
        decode_error |-> (selected_count == 0);
    endproperty

    assert property(p_decode_error)
        else
            $error("APB_MUX : Decode error with valid slave selected.");

    // Valid decode implies one slave selected
    property p_valid_decode;
        @(posedge pready)
        (!decode_error) |-> (selected_count == 1);
    endproperty

    assert property(p_valid_decode)
        else
            $error("APB_MUX : Invalid number of selected slaves.");

`endif

endmodule

