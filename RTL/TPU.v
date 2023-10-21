`include "PE.v"

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
integer i, j;

// Tell PE is done
reg     done;

// Row out
wire [7:0]      east_out[3:0][3:0];

// Col out
wire [7:0]      south_out[3:0][3:0];

wire [127:0]    result[3:0];

// Register to store input data
reg [7:0] A_data_reg [3:0][3:0];
reg [7:0] B_data_reg [3:0][3:0];

// Counter
reg [15:0] counter;

// register for size
reg [7:0] K_reg, M_reg, N_reg;

/* PE */

// First Row
PE P00(clk, rst_n, done, A_data_reg[0][0], B_data_reg[0][0], east_out[0][0], south_out[0][0], result[0][127:96]);
PE P01(clk, rst_n, done, east_out[0][0], B_data_reg[1][0], east_out[0][1], south_out[0][1], result[0][95:64]);
PE P02(clk, rst_n, done, east_out[0][1], B_data_reg[2][0], east_out[0][2], south_out[0][2], result[0][63:32]);
PE P03(clk, rst_n, done, east_out[0][2], B_data_reg[3][0], east_out[0][3], south_out[0][3], result[0][31:0]);

// Second Row
PE P10(clk, rst_n, done, A_data_reg[1][0], south_out[0][0], east_out[1][0], south_out[1][0], result[1][127:96]);
PE P11(clk, rst_n, done, east_out[1][0], south_out[0][1], east_out[1][1], south_out[1][1], result[1][95:64]);
PE P12(clk, rst_n, done, east_out[1][1], south_out[0][2], east_out[1][2], south_out[1][2], result[1][63:32]);
PE P13(clk, rst_n, done, east_out[1][2], south_out[0][3], east_out[1][3], south_out[1][3], result[1][31:0]);

// Third Row
PE P20(clk, rst_n, done, A_data_reg[2][0], south_out[1][0], east_out[2][0], south_out[2][0], result[2][127:96]);
PE P21(clk, rst_n, done, east_out[2][0], south_out[1][1], east_out[2][1], south_out[2][1], result[2][95:64]);
PE P22(clk, rst_n, done, east_out[2][1], south_out[1][2], east_out[2][2], south_out[2][2], result[2][63:32]);
PE P23(clk, rst_n, done, east_out[2][2], south_out[1][3], east_out[2][3], south_out[2][3], result[2][31:0]);

// Fourth Row
PE P30(clk, rst_n, done, A_data_reg[3][0], south_out[2][0], east_out[3][0], south_out[3][0], result[3][127:96]);
PE P31(clk, rst_n, done, east_out[3][0], south_out[2][1], east_out[3][1], south_out[3][1], result[3][95:64]);
PE P32(clk, rst_n, done, east_out[3][1], south_out[2][2], east_out[3][2], south_out[3][2], result[3][63:32]);
PE P33(clk, rst_n, done, east_out[3][2], south_out[2][3], east_out[3][3], south_out[3][3], result[3][31:0]);


always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        busy <= 1'b0;
        done <= 1'b0;
        
        A_wr_en <= 1'b0;
        A_index <= 16'b0;
        A_data_in <= 32'b0;

        B_wr_en <= 1'b0;
        B_index <= 16'b0;
        B_data_in <= 32'b0;

        C_wr_en <= 1'b0;
        C_index <= 16'b0;
        C_data_in <= 128'b0;

        counter <= 16'b0;

        K_reg <= 8'b0;
        M_reg <= 8'b0;
        N_reg <= 8'b0;

        for(i=0; i<4; i=i+1) begin
            for(j=0; j<4; j=j+1) begin
                A_data_reg[i][j] <= 8'b0;
                B_data_reg[i][j] <= 8'b0;
            end
        end

        // $display("A_data_out:\n");
        // $display("%3d %3d %3d %3d\n", A_data_out[127:96], A_data_out[95:64], A_data_out[63:32], A_data_out[31:0]);

        // $display("B_data_reg:\n");
        // $display("%3d %3d %3d %3d\n", B_data_out[127:96], B_data_out[95:64], B_data_out[63:32], B_data_out[31:0]);

    end
    else if(in_valid) begin
        busy <= 1'b1;
        done <= 1'b0;
        // $display("Counter= %d, in_valid => busy\n", counter);
        // $display("M= %d, K= %d, N= %d", M, K, N);
        M_reg <= M;
        K_reg <= K;
        N_reg <= N;
    end
    else if(busy) begin

        // $display("Counter: %d\n", counter);

        for(i=0; i<4; i=i+1) begin
            A_data_reg[i][0] = A_data_reg[i][1];
            A_data_reg[i][1] = A_data_reg[i][2];
            A_data_reg[i][2] = A_data_reg[i][3];
            A_data_reg[i][3] = 8'b0;

            B_data_reg[i][0] = B_data_reg[i][1];
            B_data_reg[i][1] = B_data_reg[i][2];
            B_data_reg[i][2] = B_data_reg[i][3];
            B_data_reg[i][3] = 8'b0;
        end
        
        if(counter < K_reg) begin
            A_data_reg[0][0] = A_data_out[31: 24];
            A_data_reg[1][1] = A_data_out[23: 16];
            A_data_reg[2][2] = A_data_out[15: 8];
            A_data_reg[3][3] = A_data_out[7: 0];

            B_data_reg[0][0] = B_data_out[31: 24];
            B_data_reg[1][1] = B_data_out[23: 16];
            B_data_reg[2][2] = B_data_out[15: 8];
            B_data_reg[3][3] = B_data_out[7: 0];
        end

        // $display("A_data_reg:\n");
        // for(i=0; i<4; i=i+1) 
        //     $display("%3d %3d %3d %3d\n", A_data_reg[i][3], A_data_reg[i][2], A_data_reg[i][1], A_data_reg[i][0]);

        // $display("B_data_reg:\n");
        // for(i=3; i>=0; i=i-1)
        //     $display("%3d %3d %3d %3d\n", B_data_reg[0][i], B_data_reg[1][i], B_data_reg[2][i], B_data_reg[3][i]);

        if(counter < K_reg) begin
            A_index <= A_index + 1;
            B_index <= B_index + 1;
        end
        else begin
            A_index <= 16'b0;
            B_index <= 16'b0;
        end

        // $display("Result:\n");
        // $display("%10d %10d %10d %10d\n", result[0][127:96], result[0][95:64], result[0][63:32], result[0][31:0]);
        // $display("%10d %10d %10d %10d\n", result[1][127:96], result[1][95:64], result[1][63:32], result[1][31:0]);
        // $display("%10d %10d %10d %10d\n", result[2][127:96], result[2][95:64], result[2][63:32], result[2][31:0]);
        // $display("%10d %10d %10d %10d\n", result[3][127:96], result[3][95:64], result[3][63:32], result[3][31:0]);

        // $display("South out:\n");
        // $display("%10d %10d %10d %10d\n", south_out[0][0], south_out[0][1], south_out[0][2], south_out[0][3]);
        // $display("%10d %10d %10d %10d\n", south_out[1][0], south_out[1][1], south_out[1][2], south_out[1][3]);
        // $display("%10d %10d %10d %10d\n", south_out[2][0], south_out[2][1], south_out[2][2], south_out[2][3]);
        // $display("%10d %10d %10d %10d\n", south_out[3][0], south_out[3][1], south_out[3][2], south_out[3][3]);

        // $display("East out:\n");
        // $display("%10d %10d %10d %10d\n", east_out[0][0], east_out[0][1], east_out[0][2], east_out[0][3]);
        // $display("%10d %10d %10d %10d\n", east_out[1][0], east_out[1][1], east_out[1][2], east_out[1][3]);
        // $display("%10d %10d %10d %10d\n", east_out[2][0], east_out[2][1], east_out[2][2], east_out[2][3]);
        // $display("%10d %10d %10d %10d\n", east_out[3][0], east_out[3][1], east_out[3][2], east_out[3][3]);
        
        if(counter >= K_reg + N_reg) begin
            C_wr_en = 1'b1;
            C_index = counter - K_reg - N_reg;
            C_data_in = result[C_index];
        end
        else begin
            C_wr_en = 1'b0;
            C_index = 16'b0;
        end

        counter <= counter + 1;

        if(counter == K_reg + M_reg + N_reg) begin
            // $display("Counter: %3d, K_reg: %3d, M_reg: %3d, N_reg: %3d\n", counter, K_reg, M_reg, N_reg);
            busy <= 1'b0;
            done <= 1'b1;
            counter <= 8'b0;
        end

    end
end

endmodule