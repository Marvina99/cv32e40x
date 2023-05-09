
module cv32e40x_register
#(
    parameter WORD_WIDTH  = 0,
    parameter RESET_VALUE = 0
)
(
    input   logic                        clk,
    input   logic                        clock_enable,
    input   logic                        rst_n,
    input   logic    [WORD_WIDTH-1:0]    data_in,
    output  reg     [WORD_WIDTH-1:0]    data_out
);

    initial begin
        data_out = RESET_VALUE;
    end

    always @(posedge clk, negedge rst_n) begin
        if (clock_enable == 1'b1) begin
            data_out <= data_in;
        end

        if (rst_n == 1'b0) begin
            data_out <= RESET_VALUE;
        end
    end

endmodule