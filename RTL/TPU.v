
module TPU(
    clk,
    rst_n,

    in_valid,
    K,
    M,
    N,
    busy,

    A_wr_en,
    A_index,
    A_data_in,
    A_data_out,

    B_wr_en,
    B_index,
    B_data_in,
    B_data_out,

    C_wr_en,
    C_index,
    C_data_in,
    C_data_out
);


input               clk;
input               rst_n;
input               in_valid;
input [7:0]         K;
input [7:0]         M;
input [7:0]         N;
output reg          busy;

output reg          A_wr_en;
output reg [15:0]   A_index;
output reg [31:0]   A_data_in;
input      [31:0]   A_data_out;

output reg          B_wr_en;
output reg [15:0]   B_index;
output reg [31:0]   B_data_in;
input      [31:0]   B_data_out;

output reg          C_wr_en;
output reg [15:0]   C_index;
output reg [127:0]  C_data_in;
input      [127:0]  C_data_out;


//* Implement your design here

// Row in
wire [7:0]  west_in_00, west_in_10, west_in_20, west_in_30;

// Column in
wire [7:0]  north_in_00, north_in_01, north_in_02, north_in_03;

// Row out
wire [7:0]  east_out_00, east_out_01, east_out_02, east_out_03;
wire [7:0]  east_out_10, east_out_11, east_out_12, east_out_13;
wire [7:0]  east_out_20, east_out_21, east_out_22, east_out_23;
wire [7:0]  east_out_30, east_out_31, east_out_32, east_out_33;

wire [7:0]  south_out_00, south_out_01, south_out_02, south_out_03;
wire [7:0]  south_out_10, south_out_11, south_out_12, south_out_13;
wire [7:0]  south_out_20, south_out_21, south_out_22, south_out_23;
wire [7:0]  south_out_30, south_out_31, south_out_32, south_out_33;

wire [31:0] result_00, result_01, result_02, result_03;
wire [31:0] result_10, result_11, result_12, result_13;
wire [31:0] result_20, result_21, result_22, result_23;
wire [31:0] result_30, result_31, result_32, result_33;


/* PE */

// First Row
PE P00(clk, rst_n, west_in_00, north_in_00, east_out_00, south_out_00, result_00);
PE P01(clk, rst_n, east_out_00, north_in_01, east_out_01, south_out_01, result_01);
PE P02(clk, rst_n, east_out_01, north_in_02, east_out_02, south_out_02, result_02);
PE P03(clk, rst_n, east_out_02, north_in_03, east_out_03, south_out_03, result_03);

// Second Row
PE P10(clk, rst_n, west_in_10, south_out_00, east_out_10, south_out_10, result_10);
PE P11(clk, rst_n, east_out_10, south_out_01, east_out_11, south_out_11, result_11);
PE P12(clk, rst_n, east_out_11, south_out_02, east_out_12, south_out_12, result_12);
PE P13(clk, rst_n, east_out_12, south_out_03, east_out_13, south_out_13, result_13);

// Third Row
PE P20(clk, rst_n, west_in_20, south_out_10, east_out_20, south_out_20, result_20);
PE P21(clk, rst_n, east_out_20, south_out_11, east_out_21, south_out_21, result_21);
PE P22(clk, rst_n, east_out_21, south_out_12, east_out_22, south_out_22, result_22);
PE P23(clk, rst_n, east_out_22, south_out_13, east_out_23, south_out_23, result_23);

// Fourth Row
PE P30(clk, rst_n, west_in_30, south_out_20, east_out_30, south_out_30, result_30);
PE P31(clk, rst_n, east_out_30, south_out_21, east_out_31, south_out_31, result_31);
PE P32(clk, rst_n, east_out_31, south_out_22, east_out_32, south_out_32, result_32);
PE P33(clk, rst_n, east_out_32, south_out_23, east_out_33, south_out_33, result_33);


always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        busy <= 1'b0;
        
        A_wr_en <= 1'b0;
        A_index <= 16'b0;
        A_data_in <= 32'b0;

        B_wr_en <= 1'b0;
        B_index <= 16'b0;
        B_data_in <= 32'b0;

        C_wr_en <= 1'b0;
        C_index <= 16'b0;
        C_data_in <= 128'b0;
    end
    else begin
        
    end
end


endmodule