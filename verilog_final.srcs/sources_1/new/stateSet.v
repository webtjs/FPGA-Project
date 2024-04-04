`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2024 17:28:32
// Design Name: 
// Module Name: stateSet
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


module stateSet(
    input clock,
    input reset,
    input c_signal,
    input player1_select,
    input player2_select,
    output reg [4:0] stage = 0,
    input move_time

    );

    localparam START = 5'b00000;
    localparam SELECT = 5'b00001;
    localparam BACKGROUND = 5'b00010;
    localparam ANIMATION = 5'b00011;
    localparam GOAL_ANIMATION = 5'b00100;
    
    reg [10:0] count = 0; 
    reg [20:0] s_count = 0;
    
    always @(posedge clock) begin
        if (reset) begin
            s_count = 0;
            count = 0;
            stage = START;
        end
        else begin
            s_count = s_count + 1;

            if (s_count >= 4000) begin
                s_count = 5000;
            end
            
            
            if (move_time == 0) begin
                count = 0;
            end
            if (move_time == 1) begin
                if (count > 0) begin
                    count = count - 1;
                end
                else begin
                    count = 0;
                end
            end
            
            if ((s_count >= 4000)) begin
                if (c_signal && (stage == START) && (count <= 0)) begin
                    stage <= SELECT;
                    count = 2000;
                end
                else if (c_signal && (stage == SELECT) && (count <= 0) && player1_select && player2_select) begin
                    stage <= BACKGROUND;
                    count = 2000;
                end
                else if (c_signal && (stage == BACKGROUND) && (count <= 0)) begin
                    stage <= ANIMATION;
                    count = 2000;
                end
                else begin
                    stage <= stage;
                end
            end
       end
    end
endmodule
