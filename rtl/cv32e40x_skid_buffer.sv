

module cv32e40x_skid_buffer import cv32e40x_pkg::*;
#(
   
   // Global Parameters   
   parameter DWIDTH    =  32                                // Data width
                                                          
) 

(
   input  logic                clk             ,           // Clock
   input  logic                rst_n           ,           // Active-low synchronous reset
   
   // Input Interface   
   input  data_resp_t          i_data          ,           // Data in
   input  logic                i_valid         ,           // Data in valid
   output logic                o_ready         ,           // Ready out

   // Output Interface
   output data_resp_t          o_data          ,            // Data out
   output logic                o_valid         ,            // Data out valid
   input  logic                i_ready                      // Ready in
) ;


/*-------------------------------------------------------------------------------------------------------------------------------
   Internal Registers/Signals
-------------------------------------------------------------------------------------------------------------------------------*/
logic                ready_rg   ;        // Ready 
data_resp_t          data_rg    ;        // Data buffer
logic                bypass_rg  ;        // Bypass signal to data and data valid muxes


/*-------------------------------------------------------------------------------------------------------------------------------
   Synchronous logic
-------------------------------------------------------------------------------------------------------------------------------*/
always @(posedge clk, negedge rst_n) begin
   
   // Reset  
   if (rst_n == 0) begin
      
      // Internal Registers
      ready_rg  <= 1'b0 ;
      data_rg   <= '0   ;     
      bypass_rg <= 1'b1 ;

   end
   
   // Out of reset
   else begin
      
      // Bypass state      
      if (bypass_rg) begin
         
         ready_rg <= 1'b1;

         if (!i_ready && i_valid && ready_rg) begin
            ready_rg  <= 1'b0   ;            
            data_rg   <= i_data ;        // Data skid happened, store to buffer
            bypass_rg <= 1'b0   ;        // To skid mode  
         end 

      end
      
      // Skid state
      else begin
         
         if (i_ready) begin
            ready_rg  <= 1'b1   ;            
            bypass_rg <= 1'b1   ;        // Back to bypass mode           
         end

      end      

   end

end


/*-------------------------------------------------------------------------------------------------------------------------------
   Continuous Assignments
-------------------------------------------------------------------------------------------------------------------------------*/
assign o_ready = ready_rg                                   ;        
assign o_data  = bypass_rg ? i_data  : data_rg              ;        // Data mux
assign o_valid = bypass_rg ? (i_valid & ready_rg) : 1'b1    ;        // Data valid mux

endmodule

