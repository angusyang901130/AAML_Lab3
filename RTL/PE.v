
module PE(
    input           clk;
    input           rst_n;

    input [7:0]     row_in;
    input [7:0]     north_in;

    output reg [7:0]    row_out;
    output reg [7:0]    south_out;
    output reg [31:0]   result;   
);

wire [31:0] mult_res;

assign mult_res = row_in * north_in;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        row_out <= 8'b0;
        south_out <= 8'b0;
        result <= 32'b0;
    end
    else begin
        row_out <= row_in;
        south_out <= north_in;
        result <= result + mult_res;
    end
end

endmodule