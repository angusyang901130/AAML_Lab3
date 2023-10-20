
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
integer i;

// Row in
reg [7:0]  west_in_00, west_in_10, west_in_20, west_in_30;

// Column in
reg [7:0]  north_in_00, north_in_01, north_in_02, north_in_03;

// Row out
wire [7:0]  east_out_00, east_out_01, east_out_02, east_out_03;
wire [7:0]  east_out_10, east_out_11, east_out_12, east_out_13;
wire [7:0]  east_out_20, east_out_21, east_out_22, east_out_23;
wire [7:0]  east_out_30, east_out_31, east_out_32, east_out_33;

wire [7:0]  south_out_00, south_out_01, south_out_02, south_out_03;
wire [7:0]  south_out_10, south_out_11, south_out_12, south_out_13;
wire [7:0]  south_out_20, south_out_21, south_out_22, south_out_23;
wire [7:0]  south_out_30, south_out_31, south_out_32, south_out_33;

wire [127:0] result[4];

// Register to store input data
reg [31:0] A_data_reg [4];
reg [31:0] B_data_reg [4];

// Counter
reg [7:0] counter;

/* PE */

// First Row
PE P00(clk, rst_n, A_data_reg[0][7:0], B_data_reg[0][7:0], east_out_00, south_out_00, result[0][127:96]);
PE P01(clk, rst_n, east_out_00, B_data_reg[1][7:0], east_out_01, south_out_01, result[0][95:64]);
PE P02(clk, rst_n, east_out_01, B_data_reg[2][7:0], east_out_02, south_out_02, result[0][63:32]);
PE P03(clk, rst_n, east_out_02, B_data_reg[3][7:0], east_out_03, south_out_03, result[0][31:0]);

// Second Row
PE P10(clk, rst_n, A_data_reg[1][7:0], south_out_00, east_out_10, south_out_10, result[1][127:96]);
PE P11(clk, rst_n, east_out_10, south_out_01, east_out_11, south_out_11, result[1][95:64]);
PE P12(clk, rst_n, east_out_11, south_out_02, east_out_12, south_out_12, result[1][63:32]);
PE P13(clk, rst_n, east_out_12, south_out_03, east_out_13, south_out_13, result[1][31:0]);

// Third Row
PE P20(clk, rst_n, A_data_reg[2][7:0], south_out_10, east_out_20, south_out_20, result[2][127:96]);
PE P21(clk, rst_n, east_out_20, south_out_11, east_out_21, south_out_21, result[2][95:64]);
PE P22(clk, rst_n, east_out_21, south_out_12, east_out_22, south_out_22, result[2][63:32]);
PE P23(clk, rst_n, east_out_22, south_out_13, east_out_23, south_out_23, result[2][31:0]);

// Fourth Row
PE P30(clk, rst_n, A_data_reg[3][7:0], south_out_20, east_out_30, south_out_30, result[3][127:96]);
PE P31(clk, rst_n, east_out_30, south_out_21, east_out_31, south_out_31, result[3][95:64]);
PE P32(clk, rst_n, east_out_31, south_out_22, east_out_32, south_out_32, result[3][63:32]);
PE P33(clk, rst_n, east_out_32, south_out_23, east_out_33, south_out_33, result[3][31:0]);


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

        counter <= 8'b0;

        west_in_00 <= 8'b0;
        west_in_01 <= 8'b0;
        west_in_10 <= 8'b0;
        west_in_11 <= 8'b0;

        north_in_00 <= 8'b0;
        north_in_01 <= 8'b0;
        north_in_10 <= 8'b0;
        north_in_11 <= 8'b0;

        for(i=0; i<4; i=i+1) begin
            A_data_reg[i] <= 8'b0;
            B_data_reg[i] <= 8'b0;
        end

    end
    else begin

        for(i=0; i<4; i=i+1) begin
            A_data_reg[i] <= A_data_reg[i] >> 8;
            if(counter < K) begin
                A_data_reg[i][i*8+7: i*8] <= A_data_out[i*8+7: i*8];
            end

            B_data_reg[i] <= B_data_reg[i] >> 8;
            if(counter < K) begin
                B_data_reg[i][i*8+7: i*8] <= B_data_out[i*8+7: i*8];
            end

        end

        if(counter < K) begin
            A_index <= counter;
            B_index <= counter;
        end
        else begin
            A_index <= 16'b0;
            B_index <= 16'b0;
        end

        counter <= counter + 1;
        
        if(counter >= M+K) begin
            C_wr_en <= 1'b1;
            C_index <= counter - M - K;
            C_data_in <= result[counter-M-K];
        end
    end
end



endmodule