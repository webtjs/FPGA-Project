`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2024 10:04:26 AM
// Design Name: 
// Module Name: update_square_pos
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


module update_square_pos(input slow_clk, input [2:0] movement_state, input [7:0] curr_xstart, curr_ystart,
output reg [7:0] new_xstart = 6, new_ystart = 45);
    

    always @ (posedge slow_clk) begin
        if (movement_state[0] == 1) begin
            new_xstart <= (curr_xstart >= 86) ? 86 : curr_xstart + 1;
        end else if (movement_state[2] == 1) begin
            new_xstart <= (curr_xstart == 0) ? 0 : curr_xstart - 1;
        end else begin
            new_xstart <= new_xstart;
        end
        
        if (movement_state[1] == 1) begin
            new_ystart <= (curr_ystart == 29) ? 29 : curr_ystart - 1;
        end else begin
            new_ystart <= (curr_ystart >= 45) ? 45 : curr_ystart + 1;
        end
 
    end
endmodule
