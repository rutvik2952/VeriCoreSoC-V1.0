
module gpio_logic
(
    //------------------------------------------------------------
    // Register Inputs
    //------------------------------------------------------------

    input  logic [gpio_pkg::GPIO_WIDTH-1:0] gpio_data_out,

    input  logic [gpio_pkg::GPIO_WIDTH-1:0] gpio_direction,

    input  logic [gpio_pkg::GPIO_WIDTH-1:0] gpio_output_enable,

    input  logic [gpio_pkg::GPIO_WIDTH-1:0] gpio_in,

    //------------------------------------------------------------
    // GPIO Pin Outputs
    //------------------------------------------------------------

    output logic [gpio_pkg::GPIO_WIDTH-1:0] gpio_out,

    output logic [gpio_pkg::GPIO_WIDTH-1:0] gpio_oe
);

    import gpio_pkg::*;

    //------------------------------------------------------------
    // GPIO Output Logic
    //------------------------------------------------------------

    genvar i;

    generate

        for(i=0; i<GPIO_WIDTH; i++)
        begin : GEN_GPIO

            //----------------------------------------------------
            // Output Enable Logic
            //----------------------------------------------------

            assign gpio_oe[i] =
                    gpio_direction[i] &
                    gpio_output_enable[i];

            //----------------------------------------------------
            // Output Data Logic
            //----------------------------------------------------

            assign gpio_out[i] =
                    gpio_data_out[i];

        end

    endgenerate
	
	    //------------------------------------------------------------
    // Future Interrupt Logic Placeholder
    //------------------------------------------------------------
    //
    // Interrupt detection (edge/level) will be implemented
    // in a future TinySoC revision. The GPIO interrupt
    // registers already exist to maintain a stable register map.
    //
    //------------------------------------------------------------

`ifndef SYNTHESIS

    //------------------------------------------------------------
    // Debug Task
    //------------------------------------------------------------

    task automatic display_gpio_status();

        begin

            $display("------------------------------------------");
            $display("GPIO STATUS");
            $display("------------------------------------------");

            $display("GPIO IN  : %h", gpio_in);
            $display("GPIO OUT : %h", gpio_out);
            $display("GPIO OE  : %h", gpio_oe);

            $display("------------------------------------------");

        end

    endtask

    //------------------------------------------------------------
    // Assertions
    //------------------------------------------------------------

    // Output Enable must never be asserted for an input pin

   // generate

   //     genvar j;

   //     for(j=0; j<GPIO_WIDTH; j++)
   //     begin : GEN_ASSERTIONS

   //         property p_gpio_oe;

   //             gpio_oe[j] |-> gpio_direction[j];

   //         endproperty

   //         assert property(p_gpio_oe)
   //             else
   //                 $error("GPIO_LOGIC : gpio_oe[%0d] asserted while GPIO is configured as input.", j);

   //     end

   // endgenerate

   // //------------------------------------------------------------

   // // GPIO output should always reflect the DATA_OUT register

   // generate

   //     genvar k;

   //     for(k=0; k<GPIO_WIDTH; k++)
   //     begin : GEN_OUTPUT_ASSERTIONS

   //         property p_gpio_out;

   //             gpio_out[k] == gpio_data_out[k];

   //         endproperty

   //         assert property(p_gpio_out)
   //             else
   //                 $error("GPIO_LOGIC : gpio_out[%0d] mismatch.", k);

   //     end

   // endgenerate

`endif

endmodule
