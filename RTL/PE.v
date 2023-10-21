
module PE(
    input           clk,
    input           rst_n,
    input           done,

    input [7:0]     west_in,
    input [7:0]     north_in,

    output reg [7:0]    east_out,
    output reg [7:0]    south_out,
    output reg [31:0]   result
);

reg [31:0] mult_res;

always @(negedge clk or negedge rst_n) begin
    if(!rst_n || done) begin
        east_out <= 8'b0;
        south_out <= 8'b0;
        result <= 32'b0;
        mult_res <= 32'b0;
    end
    else begin
        mult_res <= west_in * north_in;
        result <= result + mult_res;
        east_out <= west_in;
        south_out <= north_in;
    end
end

endmodule