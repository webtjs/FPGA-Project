`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2024 09:43:07 AM
// Design Name: 
// Module Name: Main
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


module Main(input basys3_clk, btnC, btnL, btnU, btnR, player2_C, player2_L, player2_U, player2_R, output [7:0] JC);

    reg [15:0] background [0:6143];
    initial begin
        $readmemh("background_mem.mem", background);
    end

    // 6.25MHz clock for Oled
    wire clk_6p25m;
    slow_clock clock_6p25m(basys3_clk, 7, clk_6p25m);
    
    // 25MHz clock for operation
    wire clk_25m;
    slow_clock clock_25m(basys3_clk, 1, clk_25m);
    
    // 1kHz clock for pushbutton detection
    wire clk_1k;
    slow_clock clock_1k(basys3_clk, 49999, clk_1k);
    
    // Clocks for square animation
    wire clk_45hz, clk_30hz, clk_15hz, clk_3hz;
    slow_clock clock_45hz(basys3_clk, 1111110, clk_45hz);
    slow_clock clock_30hz(basys3_clk, 1666665, clk_30hz);
    slow_clock clock_15hz(basys3_clk, 3333332, clk_15hz);
    slow_clock clock_3hz(basys3_clk, 16666665, clk_3hz);
    
    // Oled display module instantiation
    reg [15:0] pixel_data = 16'b00000_000000_00000;
    wire frame_begin, sending_pixels, sample_pixel;
    wire [12:0] pixel_index;
    
    Oled_Display unit_oled(
        .clk(clk_6p25m),
        .reset(0),
        .frame_begin(frame_begin),
        .sending_pixels(sending_pixels),
        .sample_pixel(sample_pixel),
        .pixel_index(pixel_index),
        .pixel_data(pixel_data),
        .cs(JC[0]),
        .sdin(JC[1]),
        .sclk(JC[3]),
        .d_cn(JC[4]),
        .resn(JC[5]),
        .vccen(JC[6]),
        .pmoden(JC[7]));
    
    // Coordinates module instantiation
    wire [7:0] x, y;
    get_coordinates coordinates(pixel_index, x, y);
    
    // Centre push button detector module instantiation
    wire initialised, btnU_d, u2;
    reg inAir, inAir2 = 0;
    centre_button_detector cbd(.slow_clk(clk_1k), .btnC(btnC), .btnC_pressed(initialised));
    button_press ub1(clk_1k, btnU, inAir, 500, btnU_d);
    button_press ub2(clk_1k, btnU, inAir2, 500, u2);
    //button_press rb(clk_1k, btnR, 0, btnR_d);
    //button_press ub(clk_1k, btnU, 0, btnU_d);
      
    
    
    // Movement state module instantiation
    wire [2:0] move_state_p1;
    wire [2:0] move_state_p2;
    movement_state sq_move_state(
        .slow_clk(clk_1k),
        .initialised(initialised),
        .btnC(btnC),
        .btnL(btnL),
        .btnU(btnU_d),
        .btnR(btnR),
        .movement_state(move_state_p1));
    
    movement_state p2(
        .slow_clk(clk_1k),
        .initialised(initialised),
        .btnC(player2_C),
        .btnL(player2_L),
        .btnU(player2_U),
        .btnR(player2_R),
        .movement_state(move_state_p2));
    
    // Update square pos module instantiation
    wire [7:0] p1_xpos, p1_ypos,
    p2_xpos, p2_ypos,
    square_xpos_45hz, square_ypos_45hz,
    p1_xpos_30hz, p1_ypos_30hz,
    p2_xpos_30hz, p2_ypos_30hz,
    square_xpos_15hz, square_ypos_15hz;
    
//    update_square_pos square_updater_45hz(
//        .slow_clk(clk_45hz),
//        .movement_state(move_state),
//        .curr_xstart(square_xpos),
//        .curr_ystart(square_ypos),
//        .new_xstart(square_xpos_45hz),
//        .new_ystart(square_ypos_45hz));
    update_square_pos p1_pos_30hz(
        .slow_clk(clk_30hz),
        .movement_state(move_state_p1),
        .curr_xstart(p1_xpos),
        .curr_ystart(p1_ypos),
        .new_xstart(p1_xpos_30hz),
        .new_ystart(p1_ypos_30hz));
    
     p2_pos p2_pos_30hz(
       .slow_clk(clk_30hz),
       .movement_state(move_state_p2),
       .curr_xstart(p2_xpos),
       .curr_ystart(p2_ypos),
       .new_xstart(p2_xpos_30hz),
       .new_ystart(p2_ypos_30hz));
    
//    update_square_pos square_updater_15hz(
//        .slow_clk(clk_15hz),
//        .movement_state(move_state),
//        .curr_xstart(square_xpos),
//        .curr_ystart(square_ypos),
//        .new_xstart(square_xpos_15hz),
//        .new_ystart(square_ypos_15hz));
    
    assign p1_xpos = p1_xpos_30hz;
    assign p1_ypos = p1_ypos_30hz;
    assign p2_xpos = p2_xpos_30hz;
    assign p2_ypos = p2_ypos_30hz;
    
    always @ (posedge clk_25m) begin
        if ((x >= p1_xpos && x <= p1_xpos + 9 && y >= p1_ypos && y <= p1_ypos + 18) || 
            (x >= p2_xpos && x <= p2_xpos + 9 && y >= p2_ypos && y <= p2_ypos + 18)) begin
            pixel_data <= (initialised) ? 16'b11111_111111_11111 : 16'b00000_000000_11111;
        end
        else begin
            pixel_data <= background[pixel_index];
        end
        
        
        if (p1_ypos < 45) begin
            inAir <= 1;
        end else begin
            inAir <= 0;
        end
        
        if (p2_ypos < 45) begin
            inAir2 <= 1;
        end else begin
            inAir2 <= 0;
        end
    end
    
endmodule