
module cv32e40x_skid_buffer_sva 
    import uvm_pkg::*;
    import cv32e40x_pkg::*; 
#(
    parameter DWIDTH    = 32    // data width  
)
(
   input  logic                clk,             // Clock
   input  logic                rst_n,           // Active-low synchronous reset

   // Input Interface  
   input  logic [DWIDTH-1 : 0] i_data,          // Data in
   input  logic                i_valid,         // Data in valid
   input  logic                o_ready,         // Ready out

   // Output Interfac
   input  logic [DWIDTH-1 : 0] o_data,          // Data out
   input  logic                o_valid,         // Data out valid
   input  logic                i_ready,         // Ready in

   // Internal signals from the skid_buffer
   input  logic                ready_rg_i,        // Ready 
   input  logic [DWIDTH-1 : 0] data_rg_i,         // Data buffer
   input  logic                bypass_rg_i        // Bypass signal to data and data valid muxes
);

    // Check if the reset state is correct   
    property p_reset_clears_reg;
        @(posedge clk) !rst_n |=> !ready_rg_i && (data_rg_i == '0) && bypass_rg_i;
    endproperty

    assert property(p_reset_clears_reg);


    // Want to check that every time LSU is not ready to receive data, 
    // the valid signal needs to continue into the next clock cycle and
    // the data is not allowed to change (i_data)
    property p_data_held_when_not_ready;
        @(posedge clk) disable iff (!rst_n)
        i_valid && !o_ready |=> i_valid && $stable(i_data);
    endproperty 

    assert property(p_data_held_when_not_ready);

    
    // Reset property
    property reset_property;
        @(posedge clk)
        !rst_n |=> !ready_rg_i && !o_valid;
    endproperty

    assert property(reset_property);
    
   
    // once output valid signal (o_valid) goes high, the output data (o_data)
    // cannot change until the clock cycle after inpur ready signal (i_ready)
    property p_data_stable_after_o_valid;
        @(posedge clk) disable iff (!rst_n)
        o_valid && !i_ready |=> (o_valid && $stable(o_data));
    endproperty

    assert property(p_data_stable_after_o_valid);

    
    // All incoming data must either pass through directly to the output port
    // or be stored in the buffer
    property p_passthrough_or_store;
        @(posedge clk) disable iff (!rst_n)
        (!i_ready && i_valid && ready_rg_i) |=> (data_rg_i == $past(i_data));
    endproperty

    assert property(p_passthrough_or_store);

   
    // o_valid should become idle after the last transaction
    property p_o_valid_idle_after_transaction;
        @(posedge clk) disable iff (!rst_n)
        i_ready |=> (o_valid == i_valid);
    endproperty

    assert property(p_o_valid_idle_after_transaction);

    
    // ready_rg and bypass_rg must deassert in the next clock after a skid has happened 
    property p_r_valid_deassert_after_transaction;
        @(posedge clk) disable iff (!rst_n)
        !i_ready && i_valid && ready_rg_i |=> !ready_rg_i && !bypass_rg_i;
    endproperty

    assert property(p_r_valid_deassert_after_transaction);

endmodule // cv32e40x_skid_buffer_sva