`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2024 23:14:45
// Design Name: 
// Module Name: turbostrike
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module turbostrike(
    input clk,
    input [4:0] sw,
    input [2:0] RX,
    output reg [2:0] TX = 0,
    output reg [4:0] led = 0
);

    localparam UP = 3'b001;     // 1 in binary
    localparam DOWN = 3'b010;   // 2 in binary
    localparam LEFT = 3'b011;   // 3 in binary
    localparam RIGHT = 3'b100;  // 4 in binary
    localparam CENTER = 3'b101; // 5 in binary

    localparam BLUE = 3'b001;     // 1 in binary
    localparam GREEN = 3'b010;   // 2 in binary
    localparam RED = 3'b011;   // 3 in binary
    localparam GREY = 3'b100;  // 4 in binary



    reg [2:0] player1 = 0;
    reg [2:0] player2 = 0;
    
    //control block for TX
    always @(posedge clk) begin
        if (sw[0]) begin
            TX <= 0;
        end
        else if (sw[1]) begin
            TX <= UP;
        end
        else if (sw[2]) begin
            TX <= DOWN;
        end
        else if (sw[3]) begin
            TX <= LEFT;
        end
        else if (sw[4]) begin
            TX <= RIGHT;
        end
        else if (sw[5]) begin
            TX <= CENTER;
        end
        else begin
            TX <= 0;
        end
    end

    //control block for RX
    always @(posedge clk) begin
        if (RX == UP) begin
            led <= 5'b00001;
        end
        else if (RX == DOWN) begin
            led <= 5'b00010;
        end
        else if (RX == LEFT) begin
            led <= 5'b00100;
        end
        else if (RX == RIGHT) begin
            led <= 5'b01000;
        end
        else if (RX == CENTER) begin
            led <= 5'b10000;
        end
        else begin
            led <= 0;
        end
    end

endmodule
