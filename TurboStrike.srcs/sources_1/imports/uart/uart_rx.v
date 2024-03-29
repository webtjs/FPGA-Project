`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2024 02:40:37 PM
// Design Name: 
// Module Name: top_student
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
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 100 MHz Clock, 115200 baud UART
// (100000000)/(115200) = 870
//////////////////////////////////////////////////////////////////////////////////


module uart_rx(
    input clk,
    input RxD,
    input reset,
    output [7:0] data
    );

    reg shift = 0;
    reg state = 0;
    reg next_state = 0;
    reg [3:0] bit_counter = 0; //count number of bits
    reg [1:0] sample_counter = 0; //counter for oversampling (4 times the baud rate)
    reg [16:0] baud_counter = 0; //for baud rate of 115200
    reg [9:0] shift_left_register = 0; //data bits [8:1]

    //control bit and sample counter
    reg clear_bit = 0;
    reg incre_bit = 0;
    reg clear_sample = 0;
    reg incre_sample = 0;

    localparam IDLE = 1'b0;
    localparam RECEIVE = 1'b1;
    localparam CLKS_PER_BIT = 12'h366;

    localparam clk_freq = 100_000_000;
    localparam baud_rate = 115_200;
    localparam div_sample = 4;
    localparam div_counter = clk_freq / (baud_rate * div_sample); //counter bound
    localparam mid_sample = div_sample / 2; //take a sample over mid data
    localparam div_bit = 10;

    assign data = shift_left_register[8:1];

    always @ (posedge clk) begin
        if (reset) begin
            state <= IDLE;
            bit_counter <= 0;
            baud_counter <= 0;
            sample_counter <= 0;
        end
        else begin
            baud_counter <= baud_counter + 1;
            if (baud_counter >= div_counter - 1) begin //reach baud rate with sampling
                baud_counter <= 0;
                state <= next_state; //ready to save data or switch to receive state

                if (shift) begin
                    shift_left_register = {RxD, shift_left_register[9:1]};
                    shift <= 0;
                end

                if (clear_sample) begin
                    sample_counter <= 0;
                    clear_sample <= 0;
                end

                if (incre_sample) begin
                    sample_counter <= sample_counter + 1;
                    incre_sample <= 0;
                end

                if (clear_bit) begin
                    bit_counter <= 0;
                    clear_bit <= 0;
                end

                if (incre_bit) begin
                    bit_counter <= bit_counter + 1;
                end

            end
        end
    end

    //FSM
    always @ (posedge clk) begin
        if (reset) begin
            state <= IDLE;
            next_state <= IDLE;
        end
        else begin
            case (state)
            IDLE : begin
                if (RxD) begin //input is asserted 1, no data
                    next_state <= IDLE;
                end
                else begin 
                    next_state <= RECEIVE;
                    clear_bit <= 1;
                    clear_sample <= 1;
                end
            end

            RECEIVE : begin
                next_state <= RECEIVE;
                if (sample_counter == mid_sample - 1) begin
                    shift <= 1;
                end
                if (sample_counter == div_sample - 1) begin //4th sample
                    if (bit_counter == div_bit - 1) begin //if last bit
                        next_state <= IDLE;
                    end
                    incre_bit <= 1;
                    clear_sample <= 1;
                end
                else begin
                    incre_sample <= 1;
                end
            end
            
            default : begin
                next_state <= IDLE;
            end
            endcase
        end

    end
endmodule
