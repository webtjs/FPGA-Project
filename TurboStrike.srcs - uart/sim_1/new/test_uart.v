`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2024 03:45:06 PM
// Design Name: 
// Module Name: test_uart
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


module test_uart(

    );
    
    reg clk;
    reg [7:0] data;
    reg transmit;
    reg reset;
    wire TxD;
    wire [7:0] RData;
    
    
    uart_tx uart_tx_1(clk, data, transmit, reset, TxD);
    uart_rx uart_rx_1(clk, TxD, reset, RData);
    
        initial begin
            clk = 0;
            data = 8'b10101010;
            transmit = 1;
            reset = 1;
            #10 reset = 0;
        end
        
        always begin
            #5 clk = ~clk;
        end
    
endmodule
