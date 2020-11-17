`timescale 1ns / 1ps

module VGA #(   parameter reg_size = 600,
                parameter h_pulse   = 96,    //H-SYNC pulse width 96 * 40 ns (25 Mhz) = 3.84 uS
                parameter h_bp      = 48,    //H-BP back porch pulse width
                parameter h_pixels  = 640,    //H-PIX Number of pixels horisontally
                parameter h_fp      = 16,    //H-FP front porch pulse width
                parameter h_pol     = 1'b0,    //H-SYNC polarity
                parameter h_frame   = 800,    //800 = 96 (H-SYNC) + 48 (H-BP) + 640 (H-PIX) + 16 (H-FP)
                parameter v_pulse   = 2,    //V-SYNC pulse width
                parameter v_bp      = 33,    //V-BP back porch pulse width
                parameter v_pixels  = 480,    //V-PIX Number of pixels vertically
                parameter v_fp      = 10,    //V-FP front porch pulse width
                parameter v_pol     = 1'b1,    //V-SYNC polarity
                parameter v_frame   = 525    // 525 = 2 (V-SYNC) + 33 (V-BP) + 480 (V-PIX) + 10 (V-FP)
                                            ) 
    (
        input CLK100MHz,
        input rst_n,
        input ch1_en,
        input ch2_en,
        input ch1_couple,
        input ch2_couple,
        input [9:0] ch1_offset,
        input [9:0] ch2_offset,
        input [9:0] trig,
        input [9:0] time_offset,
        input [3:0] ch1_scale,
        input [3:0] ch2_scale,
        input [4:0] time_scale,
        input [9:0] data_out_1 [reg_size - 1:0],
        input [9:0] data_out_2 [reg_size - 1:0],
        output logic [3:0] vga_r,
        output logic [3:0] vga_g,
        output logic [3:0] vga_b,
        output logic vga_hs,
        output logic vga_vs
        );
    
    logic       vga_clk, vga_hs_r, vga_vs_r, disp_en, reset = 1;    //H-SYNC register, V-SYNC register, display enable flag
    logic [1:0] clk_div;    // 2 bit counter
    logic [3:0] vga_r_r, vga_g_r, vga_b_r;    //VGA color registers R,G,B x 3 bit
    logic [7:0] timer_t = 0;    // 8 bit timer with 0 initialization
    logic [8:0] ch1, ch2, trigger, time_zero;
    logic [9:0] c_row, c_col, c_hor, c_ver;        //complete frame register row, complete frame register colum, visible frame register horisontally, visible  frame register vertically
        
    logic [4:0] ch1_mode, ch2_mode;
    assign ch1_mode = (ch1_couple)? 5'd15 : 5'd14;
    assign ch2_mode = (ch2_couple)? 5'd15 : 5'd14;
        
    logic trig_info_dis, time_info_dis, ch1_info_light, ch1_info_dark, ch2_info_light, ch2_info_dark;
    logic [11:0] color, ch1_color, ch2_color, trig_color, white, gray, black;
    
    assign {vga_r_r, vga_g_r, vga_b_r} = color;
    assign ch1_color = {4'd15, 4'd15, 4'd0};
    assign ch2_color = {4'd3, 4'd11, 4'd15};
    assign trig_color = {4'd15, 4'd11, 4'd0};
    assign white = {4'd15, 4'd15, 4'd15};
    assign gray = {4'd7, 4'd7, 4'd7};
    assign black = {4'd0, 4'd0, 4'd0};
    
    assign     vga_r         = vga_r_r;        //assign the output signals for VGA to the VGA registers
    assign     vga_g         = vga_g_r;
    assign     vga_b         = vga_b_r;
    assign     vga_hs         = vga_hs_r;
    assign     vga_vs         = vga_vs_r;

    Clk_div_4 clk_div_4(.clk_in(CLK100MHz), .clk_out(vga_clk), .rst_n(rst_n));
    
    always_comb begin
        ch1         = 440 - ch1_offset;
        ch2         = 440 - ch2_offset;
        trigger     = 440 - trig;
        time_zero   = 20 + time_offset;
    end
    
    always @ (posedge vga_clk) begin                //25Mhz clock
    
        if(timer_t > 250) reset <= 0;                // generate 10 uS RESET signal 
        else begin
            reset <= 1;                    //while in reset display is disabled, suare is set to initial position
            timer_t <= timer_t + 1;
            disp_en <= 0;            
        end
        
        if(reset == 1) begin                    //while RESET is high init counters
            c_hor <= 0;
            c_ver <= 0;
            vga_hs_r <= 1;
            vga_vs_r <= 0;
            c_row <= 0;
            c_col <= 0;
        end else begin                        // update current beam position
            if(c_hor < h_frame - 1) c_hor <= c_hor + 1;
            else begin
                c_hor <= 0;
                if(c_ver < v_frame - 1) c_ver <= c_ver + 1;
                else c_ver <= 0;
            end
        end
        if((c_hor < (h_pixels + h_fp + 1)) | (c_hor > (h_pixels + h_fp + h_pulse))) vga_hs_r <= ~h_pol;    // H-SYNC generator
        else vga_hs_r <= h_pol;
        if((c_ver < (v_pixels + v_fp)) | (c_ver > (v_pixels + v_fp + v_pulse))) vga_vs_r <= ~v_pol;        //V-SYNC generator
        else vga_vs_r <= v_pol;
        if(c_hor < h_pixels) c_col <= c_hor;        //c_col and c_row counters are updated only in the visible time-frame
        if(c_ver < v_pixels) c_row <= c_ver;
        if(c_hor < h_pixels && c_ver < v_pixels) disp_en <= 1;        //VGA color signals are enabled only in the visible time frame
        else disp_en <= 0;
        
        if(disp_en == 1 & reset == 0) begin
            color <= black;
            if(c_row >= 40 & c_col >= 20 & c_row <= 440 & c_col <= 620) begin
                if(c_row == 40 | c_col == 20 | c_row == 440 | c_col == 620) begin    //�~��
                    color <= white;
                end else begin
                    if(((c_row == 240) & ((c_col-20)%10 == 0)) | ((c_col == 320) & ((c_row-40)%10 == 0)));  //����I
                    else if(((c_row-40)%50==0 & c_col%5 == 0) | ((c_col-20)%50==0 & c_row%5 == 0)) color <= gray;
                    
                    if(((c_row == 41 | c_row == 42 | c_row == 239 | c_row == 240 | c_row == 241 | c_row == 438 | c_row == 439) & (c_col-20)%10 == 0) |          //���
                       ((c_col == 21 | c_col == 22 | c_col == 319 | c_col == 320 | c_col == 321 | c_col == 618 | c_col == 619) & (c_row-40)%10 == 0) ) color <= white;
                    
                    if(c_row == trigger & c_col%3 == 0) color <= trig_color;    //trigger level
                    
                    if( ch2_en & ((c_row >= data_out_2[c_col-21] & c_row <= data_out_2[c_col-20]) | (c_row <= data_out_2[c_col-21] & c_row >= data_out_2[c_col-20])) ) color <= ch2_color;
                    
                    if( ch1_en & ((c_row >= data_out_1[c_col-21] & c_row <= data_out_1[c_col-20]) | (c_row <= data_out_1[c_col-21] & c_row >= data_out_1[c_col-20])) ) color <= ch1_color;
                    
                end
                
               /*********************************************************time_tag*********************************************************/
                if((c_row > 40) & (c_col <= time_zero + 3) & (c_col >= time_zero - 3) &
                   ( ((time_zero < c_col) & (c_row < 50 - c_col + time_zero)) |
                     ((time_zero > c_col) & (c_row < 50 + c_col - time_zero)) |
                     ((c_col == time_zero) & (c_row == 41 | ((c_row > 46) & (c_row < 50)))) ) ) color <= trig_color;
                if( ((c_row == 42) & (c_col > time_zero - 2) & (c_col < time_zero + 2)) |
                    ((c_col == time_zero) & (c_row < 46) & (c_row > 42)) ) color <= black;
               /*************************************************************************************************************************/
               
               
            end else begin
                           
            
                /*********************************************************Channel_tag*********************************************************/
                 if(ch2_en) begin
                     if((c_col >= 7) & (c_col < 20) & (c_row <= ch2 + 4) & (c_row >= ch2 - 4)) color <= ch2_color;
                     if(c_row >= 461 & c_col >= 20 & c_row <= 473 & c_col <= 32) color <= ch2_color;
                 end
                 
                 if(ch2_en & ((((c_col >= 20 - c_row + ch2) | (c_col >= 20 + c_row - ch2)) &
                                 c_col >= 16 & c_col < 20 & (c_row <= ch2 + 4) & (c_row >= ch2 - 4)) | ch2_info_dark)) color <= black;
                /*************************************************************************************************************************/


               /*********************************************************Ch1_tag*********************************************************/
                if(ch1_en) begin
                    if((c_col >= 7) & (c_col < 20) & (c_row <= ch1 + 4) & (c_row >= ch1 - 4)) color <= ch1_color;
                    if(c_row >= 445 & c_col >= 20 & c_row <= 457 & c_col <= 32) color <= ch1_color;
                end
                
                if(ch1_en & ((((c_col >= 20 - c_row + ch1) | (c_col >= 20 + c_row - ch1)) &
                                c_col >= 16 & c_col < 20 & (c_row <= ch1 + 4) & (c_row >= ch1 - 4)) | ch1_info_dark)) color <= black;
               /*************************************************************************************************************************/


               /*********************************************************trig_tag*********************************************************/
                if((c_col > 620) & (c_col <= 630) & (c_row <= trigger + 3) & (c_row >= trigger - 3)) color <= trig_color;
                if( (((c_col <= 620 + c_row - trigger) | (c_col <= 620 - c_row + trigger)) & c_col <= 624 & c_col > 620) |
                    ((c_row == trigger - 2) & c_col > 625 & c_col < 629) |
                    ((c_col == 627) & (c_row < trigger + 3) & (c_row > trigger - 3)) ) color <= black;
               /*************************************************************************************************************************/
               
               if(ch1_en & ch1_info_light) color <= ch1_color;
               
               if(ch2_en & ch2_info_light) color <= ch2_color;

               if(trig_info_dis) color <= trig_color;
               
               if(time_info_dis) color <= white;               
               
            end
            
        end else color <= black; //when display is not enabled everything is black
        
    end
    
    Trig_display #(550, 30) trig_display(.scale_in(ch1_scale), .offset_in(ch1_offset), .trig, .x_in(c_col), .y_in(c_row), .display(trig_info_dis));
    
    Time_display #(450, 30) time_display(.scale_in(time_scale), .x_in(c_col), .y_in(c_row), .display(time_info_dis));
    
    Channel_display #(8, 23, 447) ch1_display(.scale_in(ch1_scale), .mode(ch1_mode), .channel(5'd1), .x_in(c_col), .y_in(c_row),
                                              .offset_y_move(ch1 - 4), .display_light(ch1_info_light), .display_dark(ch1_info_dark));
                                              
    Channel_display #(8, 23, 463) ch2_display(.scale_in(ch2_scale), .mode(ch2_mode), .channel(5'd2), .x_in(c_col), .y_in(c_row),
                                              .offset_y_move(ch2 - 4), .display_light(ch2_info_light), .display_dark(ch2_info_dark));

endmodule
