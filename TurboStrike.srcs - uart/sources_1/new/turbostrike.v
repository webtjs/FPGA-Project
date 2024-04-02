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
    input btnC,
    input sw0,
    input JA1,
    output JA5,
    output reg [4:0] led = 0
);

    localparam UP = 8'h55;
    localparam DOWN = 8'h44;
    localparam LEFT = 8'h4C;
    localparam RIGHT = 8'h32;
    localparam CENTER = 8'h58;
    
    parameter CLK_HZ = 100_000_000;
    parameter BIT_RATE =   9600;
    parameter PAYLOAD_BITS = 8;

    wire [7:0]  uart_rx_data;
    wire        uart_rx_valid;
    wire        uart_rx_break;

    wire        uart_tx_busy;
    reg [7:0]  uart_tx_data = 0;
    reg        uart_tx_en = 0;


    // UART RX
    uart_rx #(.BIT_RATE(BIT_RATE), .PAYLOAD_BITS(PAYLOAD_BITS), .CLK_HZ  (CLK_HZ  )) i_uart_rx(
    .clk          (clk          ), // Top level system clock input.
    .resetn       (sw0         ), // Asynchronous active low reset.
    .uart_rxd     (JA1     ), // UART Recieve pin.
    .uart_rx_en   (1'b1         ), // Recieve enable
    .uart_rx_break(uart_rx_break), // Did we get a BREAK message?
    .uart_rx_valid(uart_rx_valid), // Valid data recieved and available.
    .uart_rx_data (uart_rx_data )  // The recieved data.
    );

    //
    // UART Transmitter module.
    //
    uart_tx #(.BIT_RATE(BIT_RATE), .PAYLOAD_BITS(PAYLOAD_BITS), .CLK_HZ  (CLK_HZ  )) i_uart_tx(
    .clk          (clk          ),
    .resetn       (sw0         ),
    .uart_txd     (JA5     ),
    .uart_tx_en   (uart_tx_en   ),
    .uart_tx_busy (uart_tx_busy ),
    .uart_tx_data (uart_tx_data ) 
    );

    //control block for TX
    always @(posedge clk) begin
        if (sw0) begin
            uart_tx_data <= 0;
            uart_tx_en <= 0;
        end
        else if (btnU) begin
            uart_tx_data <= UP;
            uart_tx_en <= 1;
        end
        else if (btnD) begin
            uart_tx_data <= DOWN;
            uart_tx_en <= 1;
        end
        else if (btnL) begin
            uart_tx_data <= LEFT;
            uart_tx_en <= 1;
        end
        else if (btnR) begin
            uart_tx_data <= RIGHT;
            uart_tx_en <= 1;
        end
        else if (btnC) begin
            uart_tx_data <= CENTER;
            uart_tx_en <= 1;
        end
        else begin
            uart_tx_data <= 0;
            uart_tx_en <= 0;
        end
    end

    //control block for RX
    always @(posedge clk) begin
        if (uart_rx_data == UP) begin
            led <= 5'b00001;
        end
        else if (uart_rx_data == DOWN) begin
            led <= 5'b00010;
        end
        else if (uart_rx_data == LEFT) begin
            led <= 5'b00100;
        end
        else if (uart_rx_data == RIGHT) begin
            led <= 5'b01000;
        end
        else if (uart_rx_data == CENTER) begin
            led <= 5'b10000;
        end
        else begin
            led <= 5'b00000;
        end
    end
endmodule
