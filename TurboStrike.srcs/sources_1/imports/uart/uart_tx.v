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


module uart_tx(
    input clk,
    input [7:0] data,
    input transmit,
    input reset,
    output reg TxD = 1
);

    reg [3:0] bit_counter = 0; // count 10 bits: 1-8-1
    reg [9:0] baud_counter = 0;
    reg [9:0] shift_right_register = 0;
    reg state = 0;
    reg next_state = 0;
    reg shift = 0;  // shift signal
    reg load = 0;   // load signal
    reg clear = 0; // reset counter

    parameter IDLE = 1'b0;
    parameter TRANSMIST = 1'b1;
    parameter CLKS_PER_BIT = 12'h366;

    always @ (posedge clk) begin
        if (reset) begin
            state <= IDLE;
            bit_counter <= 0;
            baud_counter <= 0;
            shift_right_register <= 0;
            TxD <= 1'b1; // Idle state for TxD
            load <= 0;
            shift <= 0;
            clear <= 0;
        end
        else begin
            if (baud_counter >= CLKS_PER_BIT) begin 
                baud_counter <= 0;
                state <= next_state;
                
                if (load) begin
                    shift_right_register <= {1'b1, data, 1'b0}; // start bit, data bits, stop bit
                    load <= 0; // Reset load after loading data
                end

                if (shift) begin
                    shift_right_register <= shift_right_register >> 1;
                    bit_counter <= bit_counter + 1;
                    TxD <= shift_right_register[0];
                    shift <= 0; // Reset shift after shifting
                end

                if (clear) begin
                    bit_counter <= 0;
                    clear <= 0; // Reset clear after clearing the counter
                end
            end
            else begin
                baud_counter <= baud_counter + 1;
            end
        end
    end

    // FSM for controlling the transmission process
    always @ (posedge clk) begin
        if (reset) begin
            next_state <= IDLE;
        end
        else begin
            case(state)
                IDLE : begin
                    if (transmit) begin
                        next_state <= TRANSMIST;
                        load <= 1;
                        shift <= 0;
                        clear <= 0;
                    end
                    else begin
                        next_state <= IDLE;
                    end
                end

                TRANSMIST : begin
                    if (bit_counter >= 10) begin // Check if all bits have been sent
                        next_state <= IDLE;
                        clear <= 1; // To clear the bit_counter for the next transmission
                    end
                    else begin
                        next_state <= TRANSMIST;
                        shift <= 1; // Continue shifting for transmission
                    end
                end

                default : begin
                    next_state <= IDLE;
                end
            endcase
        end
    end
endmodule

