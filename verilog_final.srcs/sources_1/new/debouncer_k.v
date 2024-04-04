`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/03/2024 08:04:36 PM
// Design Name: 
// Module Name: debouncer_k
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


module debouncer_k(
input clk,
input btn,
output reg btn_D
    );
    
    parameter clock_freq = 100000000,
              debounce_time = 1000,
              initial_value = 1'b0;

    localparam timerlim = clock_freq / debounce_time;
			  
	`ifdef SIMULATION
		localparam s_initial = "s_initial",
				   s_zero = "s_zero",
				   s_zero_to_one = "s_zero_to_one",
				   s_one = "s_one",
				   s_one_to_zero = "s_one_to_zero";			   
		reg [13*8-1 : 0] state = s_initial;
		
	`else
		localparam s_initial = 3'b000,
				   s_zero = 3'b001,
				   s_zero_to_one = 3'b010,
				   s_one = 3'b011,
				   s_one_to_zero = 3'b100;				   
		reg [2:0] state = s_initial;		
	`endif

    reg [16:0] timer = 17'b0;
	reg timer_en = 1'b0, timer_tick = 1'b0;
    
    always@ (posedge clk) begin
    
        case (state)
        
            s_initial: begin
                if (initial_value == 1'b0)
                    state = s_zero;
                else
                    state = s_one;
            end
                    
            s_zero: begin
                btn_D <= 1'b0;
                
                if (btn == 1'b1)
                    state <= s_zero_to_one;
            end
                  
            s_zero_to_one: begin
                btn_D <= 1'b0;
                timer_en <= 1'b1;
                
                if (timer_tick == 1'b1) begin
                    state <= s_one;
                    timer_en <= 1'b0;
                end
                
                if (btn == 1'b0) begin
                    state <= s_zero;
                    timer_en <= 1'b0;
                end
            end
            
            s_one: begin
                btn_D <= 1'b1;
                
                if (btn == 1'b0)
                    state <= s_one_to_zero;
            end
            
            s_one_to_zero: begin
                btn_D <= 1'b1;
                timer_en <= 1'b1;
                
                if (timer_tick == 1'b1) begin
                    state <= s_zero;
                    timer_en <= 1'b0;
                end
                
                if (btn == 1'b1) begin
                    state <= s_one;
                    timer_en <= 1'b0;
                end
            end
            
        endcase
        
        if (timer_en == 1'b1) begin
            if (timer == (timerlim - 1)) begin
                timer_tick <= 1'b1;
                timer <= 17'b0;
            end    
            else begin
                timer_tick <= 1'b0;
                timer <= timer + 17'b1;
            end
        end       
        else begin
            timer <= 17'b0;
            timer_tick <= 1'b0;
        end    
            
    end 
                      
endmodule
