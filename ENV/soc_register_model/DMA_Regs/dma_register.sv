`ifndef DMA_REGISTER_SV
`define DMA_REGISTER_SV

 class dma_id_reg extends uvm_reg;
   
    rand uvm_reg_field DMA_ID;
   
   `uvm_object_utils(dma_id_reg)

   function new(string name="dma_id_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     DMA_ID = uvm_reg_field::type_id::create("DAM_ID");
     DMA_ID.configure(this,32,0,"RO",0,'h444D_4120,1,1,1);
   endfunction

 endclass

 class dma_version_reg extends uvm_reg;

   rand uvm_reg_field DMA_VERSION;

   `uvm_object_utils(dma_version_reg)

   function new(string name = "dma_version_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     DMA_VERSION = uvm_reg_field::type_id::create("DMA_VERSION");
     DMA_VERSION.configure(this,32,0,"RO",0,'h0001_0000,1,1,1);
   endfunction

 endclass

 class dma_control_reg extends uvm_reg;

    rand uvm_reg_field DMA_ENABLE;
    rand uvm_reg_field DMA_START;
    rand uvm_reg_field DMA_IRQ_EN;
 
   `uvm_object_utils(dma_control_reg)

   function new(string name="dma_control_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     DMA_ENABLE = uvm_reg_field::type_id::create("DMA_ENABLE");
     DMA_ENABLE.configure(this,1,0,"RW",0,0,1,1,1);

     DMA_START = uvm_reg_field::type_id::create("DMA_START");
     DMA_START.configure(this,1,1,"RW",0,0,1,1,1);

     DMA_IRQ_EN = uvm_reg_field::type_id::create("DMA_IRQ_EN");
     DMA_IRQ_EN.configure(this,1,2,"RW",0,0,1,1,1); 

   endfunction

 endclass

 class dma_src_reg extends uvm_reg;

   rand uvm_reg_field DMA_SRC_ADDR;

   `uvm_object_utils(dma_src_reg)

   function new(string name="dma_src_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     DMA_SRC_ADDR = uvm_reg_field::type_id::create("DMA_SRC_ADDR");
     DMA_SRC_ADDR.configure(this,32,0,"RW",0,0,1,1,1);
     
   endfunction

 endclass

 class dma_dst_reg extends uvm_reg;

   rand uvm_reg_field DMA_DST_ADDR;
   
   `uvm_object_utils(dma_dst_reg)

   function new(string name="dma_dst_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
    DMA_DST_ADDR = uvm_reg_field::type_id::create("DMA_DST_ADDR"); 
    DMA_DST_ADDR.configure(this,32,0,"RW",0,0,1,1,1); 
   endfunction

 endclass

 class dma_length_reg extends uvm_reg;

   rand uvm_reg_field DMA_LENGTH;
 
   `uvm_object_utils(dma_length_reg)

   function new(string name="dma_length_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
     DMA_LENGTH = uvm_reg_field::type_id::create("DMA_LENGTH");
     DMA_LENGTH.configure(this,32,0,"RW",0,0,1,1,1);

   endfunction

 endclass

 class dma_status_reg extends uvm_reg;

    rand uvm_reg_field DMA_BUSY;
    rand uvm_reg_field DMA_DONE;
    
    `uvm_object_utils(dma_status_reg)

    function new(string name="dma_status_reg");
     super.new(name,32,UVM_NO_COVERAGE);
    endfunction

    function void build();
      DMA_BUSY = uvm_reg_field::type_id::create("DMA_BUSY");
      DMA_BUSY.configure(this,1,0,"RO",0,0,1,1,1);
     
      DMA_BUSY = uvm_reg_field::type_id::create("DMA_BUSY");
      DMA_BUSY.configure(this,1,1,"RO",0,0,1,1,1);
    endfunction

 endclass

 class dma_int_status_reg extends uvm_reg;

    rand uvm_reg_field DMA_IRQ_PENDING;
     
    `uvm_object_utils(dma_int_status_reg)

    function new(string name ="dma_int_status_reg");
      super.new(name,32,UVM_NO_COVERAGE);
    endfunction

    function void build();
      DMA_IRQ_PENDING = uvm_reg_field::type_id::create("DMA_IRQ_PENDING");
      DMA_IRQ_PENDING.configure(this,1,0,"RO",0,0,1,1,1);      
    endfunction

 endclass

class dma_int_clear_reg extends uvm_reg;
   rand uvm_reg_field DMA_IRQ_CLEAR;

   `uvm_object_utils(dma_int_clear_reg)

   function new(string name="dma_int_clear_reg");
     super.new(name,32,UVM_NO_COVERAGE);
   endfunction

   function void build();
      DMA_IRQ_CLEAR = uvm_reg_field::type_id::create("DMA_IRQ_CLEAR");
      DMA_IRQ_CLEAR.configure(this,32,0,"WO",0,0,1,1,1);
   endfunction

endclass

`endif //DMA_REGISTER_SV

