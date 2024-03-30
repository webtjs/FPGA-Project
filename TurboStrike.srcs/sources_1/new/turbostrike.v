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
    input btnU,
    input btnD,
    input btnL,
    input btnR,
    input JA1,
    output JA5
);

    localparam UP = 8'h55;
    localparam DOWN = 8'h44;
    localparam LEFT = 8'h4C;
    localparam RIGHT = 8'h32;

    reg [7:0] tx_data = 0;
    reg [7:0] rx_data = 0;
    reg uart_transmit = 0;
    reg uart_reset = 0;

    uart_tx tx(.clk(clk), .data(tx_data), .transmit(uart_transmit), .reset(reset), .TxD(JA5));
    uart_rx rx(.clk(clk), .RxD(JA1), .reset(reset), .data(rx_data));

    //control block for TX
    always @(posedge clk) begin
        if (reset) begin
            tx_data <= 0;
            transmit <= 0;
        end
        else if (btnU) begin
            tx_data <= UP;
            transmit <= 1;
        end
        else if (btnD) begin
            tx_data <= DOWN;
            transmit <= 1;
        end
        else if (btnL) begin
            tx_data <= LEFT;
            transmit <= 1;
        end
        else if (btnR) begin
            tx_data <= RIGHT;
            transmit <= 1;
        end
        else begin
            transmit <= 0;
        end
    end

    //control block for RX
    always @(posedge clk) begin
        if (reset) begin
            rx_data <= 0;
        end
        else if (rx_data == UP) begin
            //do something
        end
        else if (rx_data == DOWN) begin
            //do something
        end
        else if (rx_data == LEFT) begin
            //do something
        end
        else if (rx_data == RIGHT) begin
            //do something
        end
        else begin
            //do something
        end
    end
endmodule
