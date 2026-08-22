`ifndef SOC_REG_BLOCK_MODEL_SV
`define SOC_REG_BLOCK_MODEL_SV

class soc_reg_block_model extends uvm_reg_block;
  
   sysctrl_reg_block  sysctrl_reg_model;
   intc_reg_block     intc_reg_model;
   timer_reg_block    timer_reg_model;
   gpio_reg_block     gpio_reg_model;
   uart_reg_block     uart_reg_model;
   spi_reg_block      spi_reg_model;

   `uvm_object_utils(soc_reg_block_model)

   function new(string name="soc_reg_block_model");  
     super.new(name,UVM_NO_COVERAGE);
   endfunction


   function void build();
     sysctrl_reg_model = sysctrl_reg_block::type_id::create("sysctrl_reg_model");
     intc_reg_model    = intc_reg_block::type_id::create("intc_reg_model");
     timer_reg_model   = timer_reg_block::type_id::create("timer_reg_model");
     gpio_reg_model    = gpio_reg_block::type_id::create("gpio_reg_model");
     uart_reg_model    = uart_reg_block::type_id::create("uart_reg_model");
     spi_reg_model     = spi_reg_block::type_id::create("spi_reg_model");

     sysctrl_reg_model.build();
     intc_reg_model.build();
     timer_reg_model.build();
     gpio_reg_model.build();
     uart_reg_model.build();
     spi_reg_model.build();
 

     lock_model();
   endfunction   

endclass

`endif //SOC_REG_BLOCK_MODEL_SV
