`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.04.2024 15:02:49
// Design Name: 
// Module Name: TopStudent
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


 module TopStudent(
    input clk,
    input sw0,//reset
    input btnC,
    input btnL,
    input btnR,
    input btnD,
    input btnU,
    output reg [6:0] seg = 7'b1111111,
    output reg [3:0] an = 4'b1111,
    input [2:0] RX,
    output reg [2:0] TX = 0,
    output reg [7:0] JC = 0
    );
    
    //register for player information
    reg [2:0] player1 = 0;//player1 is the current player
    reg [2:0] player2 = 0;//player2 is the opponent player
    reg [2:0] player2_button = 0;

    wire player2_C, player2_L, player2_U, player2_R;

    assign player2_C = player2_button[2] && ~player2_button[1] && player2_button[0];
    assign player2_L = ~player2_button[2] && player2_button[1] && player2_button[0];
    assign player2_U = ~player2_button[2] && ~player2_button[1] && player2_button[0];
    assign player2_R = player2_button[2] && ~player2_button[1] && ~player2_button[0];


    localparam UP = 3'b001;
    localparam DOWN = 3'b010;  
    localparam LEFT = 3'b011;   
    localparam RIGHT = 3'b100;  
    localparam CENTER = 3'b101;

    localparam BLUE = 3'b001;  
    localparam GREEN = 3'b010;  
    localparam RED = 3'b011;   
    localparam GREY = 3'b100;  
    localparam START = 4'b0000;
    localparam SELECT = 4'b0001;
    localparam BACKGROUND = 4'b0010;
    localparam ANIMATION = 4'b0011;
    localparam GOAL_ANIMATION = 4'b0100;

    wire btnC_D, btnU_D, btnR_D, btnL_D, btnD_D;

    debouncer_k debouncer_btnC(
        .clk(clk),
        .btn(btnC),
        .btn_D(btnC_D)
    );

    debouncer_k debouncer_btnU(
        .clk(clk),
        .btn(btnU),
        .btn_D(btnU_D)
    );

    debouncer_k debouncer_btnR(
        .clk(clk),
        .btn(btnR),
        .btn_D(btnR_D)
    );

    debouncer_k debouncer_btnL(
        .clk(clk),
        .btn(btnL),
        .btn_D(btnL_D)
    );

    debouncer_k debouncer_btnD(
        .clk(clk),
        .btn(btnD),
        .btn_D(btnD_D)
    );

    wire s_clock, fb, send_p, samp_p;
    wire [12:0] p_index, x, y;
    
    // Read memory file
    reg [15:0] test_mem [0:6143];
    reg [15:0] start_page_mem [0:6143];
    reg [15:0] background [0:6143];
    reg [15:0] ani0_mem [0:6143];
    reg [15:0] ani1_mem [0:6143];
    reg [15:0] ani2_mem [0:6143];
    reg [15:0] ani3_mem [0:6143];
    reg [15:0] ani4_mem [0:6143];
    reg [15:0] ani5_mem [0:6143];
    
    initial begin
        $readmemh("test.mem", test_mem);
        $readmemh("start_page.mem", start_page_mem);
        $readmemh("background_mem.mem", background);
        $readmemh("ani0.mem", ani0_mem);
        $readmemh("ani1.mem", ani1_mem);
        $readmemh("ani2.mem", ani2_mem);
        $readmemh("ani3.mem", ani3_mem);
        $readmemh("ani4.mem", ani4_mem);
        $readmemh("ani5.mem", ani5_mem);
    end

    wire [7:0] JC_GAME;

    Main engine(.basys3_clk(clk), .btnC(btnC_D), .btnL(btnL_D), .btnU(btnU_D), .btnR(btnR_D), .player2_C(player2_C), .player2_L(player2_L), .player2_U(player2_U), .player2_R(player2_R), .JC(JC_GAME));
                
    // 6.25MHz clock for Oled
    wire clk_6p25m;
    my_clock clock_6p25m(clk, 7, clk_6p25m);
                
    // 25MHz clock for operation
    wire clk_25m;
    my_clock clock_25m(clk, 1, clk_25m);
    
    wire clk_1000;
    my_clock my_1000hz_clk(clk, 49999, clk_1000);
    
    wire l_signal, r_signal, c_signal;
    wire l_move_time, r_move_time, c_move_time;
                
    // Oled display module instantiation
    reg [15:0] oled_data = 16'b00000_000000_00000;
    wire frame_begin, sending_pixels, sample_pixel;
    wire [12:0] pixel_index;
    wire [4:0] place;
    
    wire [4:0] stage;
    
    debouncer my_left_debounce (clk, btnL, l_signal, l_move_time);
    debouncer my_right_debounce(clk, btnR, r_signal, r_move_time);
    debouncer my_centre_debounce(clk, btnC, c_signal, c_move_time);

    reg player1_select = 0;
    reg player2_select = 0;
    
    placement my_placement (clk_1000, place, l_signal, r_signal, l_move_time, r_move_time);
    stateSet my_state(.clock(clk_1000), .reset(sw0), .c_signal(c_signal), .player1_select(player1_select), .player2_select(player2_select), .stage(stage), .move_time(c_move_time));



    //control block for TX and RX
    always @(posedge clk) begin
        if (sw0) begin
            TX <= 0;
        end
        else if (stage == SELECT) begin
            if (btnC_D) begin
                TX <= {2'b0, player1_select};
                player2_select <= RX[0];
            end
        end
        else if (stage >= BACKGROUND) begin
            player2_button <= RX;
                if (btnC_D) begin
                    TX <= CENTER;
                end
                else if (btnU_D) begin
                    TX <= UP;
                end
                else if (btnD_D) begin
                    TX <= DOWN;
                end
                else if (btnL_D) begin
                    TX <= RIGHT; //invert the direction for the other
                end
                else if (btnR_D) begin
                    TX <= LEFT;
                end
                else begin
                    TX <= 0;
                end
        end
        else begin
            TX <= 0;
        end
    end

    //control block for player selection
    always @(posedge clk) begin
        if (stage == START) begin
            player1 <= 0;
            player2 <= 0;
        end
        else if (stage == SELECT) begin
            if (btnC_D) begin
                player1 <= place;
                player1_select <= 1;
            end
        end
    end
    
    get_coord coord (pixel_index, x, y);

    wire [7:0] JC_INT; //jc for initialization

    always @ (posedge clk) begin
        if (stage <= SELECT) begin
            JC <= JC_INT;
        end
        else begin
            JC <= JC_GAME;
        end
    end

    Oled_Display unit_oled(
       .clk(clk_6p25m),
       .reset(0),
       .frame_begin(frame_begin),
       .sending_pixels(sending_pixels),
       .sample_pixel(sample_pixel),
       .pixel_index(pixel_index),
       .pixel_data(oled_data),
       .cs(JC_INT[0]),
       .sdin(JC_INT[1]),
       .sclk(JC_INT[3]),
       .d_cn(JC_INT[4]),
       .resn(JC_INT[5]),
       .vccen(JC_INT[6]),
       .pmoden(JC_INT[7]));
    
    reg [31:0] count = 0;

    reg [3:0] goal = 0;

    always @ (posedge clk) begin
        if (stage >= BACKGROUND) begin
            an <= 4'b0000;
            if (goal == 0) begin
                seg <= 7'b1000000;
            end
            else if (goal == 4'b0001) begin
                seg <= 7'b1111001;
            end
            else if (goal == 4'b0010) begin
                seg <= 7'b0100100;
            end
            else if (goal == 4'b0011) begin
                seg <= 7'b0110000;
            end
            else if (goal == 4'b0100) begin
                seg <= 7'b0011001;
            end
            else if (goal == 4'b0101) begin
                seg <= 7'b0010010;
            end
            else if (goal == 4'b0110) begin
                seg <= 7'b0000010;
            end
            else if (goal == 4'b0111) begin
                seg <= 7'b1111000;
            end
            else if (goal == 4'b1000) begin
                seg <= 7'b0000000;
            end
            else if (goal == 4'b1001) begin
                seg <= 7'b0011000;
            end
            else begin
                seg <= 7'b1000000;
            end
        end
    end


                
    always @ (posedge clk_25m) begin
        if (stage == 0) begin
            oled_data = start_page_mem[pixel_index];
        end
        
        
        if (stage >= 3) begin
            count = count + 1;
        end
        
        
        if ((((x >= 88 && x <= 90 ) && (y >= 16 && y <= 39))
            || ((x >= 74 && x <= 90 ) && (y >= 16 && y <= 18))
            || ((x >= 74 && x <= 90 ) && (y >= 37 && y <= 39))
            || ((x >= 74 && x <= 76 ) && (y >= 16 && y <= 39)))
            && (place == 3) && (stage == 1))
        begin
            oled_data <= 16'b0000011111100000;
        end
        else if ((((x >= 64 && x <= 66 ) && (y >= 16 && y <= 39))
            || ((x >= 51 && x <= 66 ) && (y >= 16 && y <= 18))
            || ((x >= 51 && x <= 66 ) && (y >= 37 && y <= 39))
            || ((x >= 51 && x <= 53 ) && (y >= 16 && y <= 39)))
            && (place == 2) && (stage == 1))
        begin
            oled_data <= 16'b0000011111100000;
        end
        else if ((((x >= 41 && x <= 43 ) && (y >= 16 && y <= 39))
            || ((x >= 28 && x <= 43 ) && (y >= 16 && y <= 18))
            || ((x >= 28 && x <= 43 ) && (y >= 37 && y <= 39))
            || ((x >= 28 && x <= 30 ) && (y >= 16 && y <= 39)))
            && (place == 1) && (stage == 1))
       begin
            oled_data <= 16'b0000011111100000;
       end
       else if ((((x >= 18 && x <= 20 ) && (y >= 16 && y <= 39))
            || ((x >= 5 && x <= 20 ) && (y >= 16 && y <= 18))
            || ((x >= 5 && x <= 20 ) && (y >= 37 && y <= 39))
            || ((x >= 5 && x <= 7 ) && (y >= 16 && y <= 39)))
            && (place == 0) && (stage == 1))
       begin
            oled_data <= 16'b0000011111100000;
       end 
       else if (stage == 1) begin
            oled_data <= test_mem[pixel_index];
       end
       else begin
            oled_data <= oled_data;
       end
       
       if (stage == 2) begin
            oled_data <= background[pixel_index];
       end
       
       if (stage == 3) begin
           if (count <= 4000000) begin
                oled_data <= ani0_mem[pixel_index];
           end
           else if ((count > 4000000) && (count <= 8000000)) begin
                oled_data <= ani1_mem[pixel_index];
           end 
           else if ((count > 8000000) && (count <= 12000000)) begin
                oled_data <= ani2_mem[pixel_index];
           end
           else if ((count > 12000000) && (count <= 16000000)) begin
                oled_data <= ani3_mem[pixel_index];
           end
           else if ((count > 16000000) && (count <= 20000000)) begin
                oled_data <= ani4_mem[pixel_index];
           end
           else begin
                oled_data <= ani5_mem[pixel_index];
           end
       end
       
    end  
    
endmodule
