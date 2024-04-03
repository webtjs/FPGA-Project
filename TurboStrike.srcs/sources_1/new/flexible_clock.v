`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2024 06:58:20 PM
// Design Name: 
// Module Name: flexible_clock
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


module flexible_clock(input basys_clock, input [31:0] m_count, output reg slow_clock = 0);
    reg [31:0] count = 0;
    
    always @ (posedge basys_clock) begin
        count <= (count == m_count) ? 0 : count + 1;
        slow_clock <= (count == 0) ? ~slow_clock : slow_clock;
    end
endmodule