`timescale 1ns / 1ps

module Oscilloscope(
    input rst_n,
    input CLK100MHz,
    input vauxp2,
    input vauxn2,
    input vauxp3,
    input vauxn3,
    
    input trig_up,
    input trig_down,
    input trig_reset,
    
    input trig_off,
    
    input time_scale_in,
    input time_scale_out,
    input time_left,
    input time_right,
    input time_reset,
    
    input ch1_en,
    input ch1_scale_in,
    input ch1_scale_out,
    input ch1_up,
    input ch1_down,
    input ch1_reset,
    input ch1_couple_sw,
    output logic ch1_couple,
     
    input ch2_en,
    input ch2_scale_in,
    input ch2_scale_out,
    input ch2_up,
    input ch2_down,
    input ch2_reset,
    input ch2_couple_sw,
    output logic ch2_couple,
    
    output logic [3:0] vga_r,
    output logic [3:0] vga_g,
    output logic [3:0] vga_b,
    output logic vga_hs,
    output logic vga_vs,
    
        output logic clk_sampling

    );
    
    parameter reg_size = 600;
    logic en, ready, sw;
    
    logic [9:0] data_out_1 [reg_size - 1:0];
    logic [9:0] data_out_2 [reg_size - 1:0];
    logic [3:0] ch1_scale, ch2_scale;
    logic [4:0] time_scale;
    logic [9:0] ch1_offset, ch2_offset, trig, time_offset;
    logic [17:0] clk_count;
    
    assign ready = clk_count >= 200000;
    assign sw = clk_count >= 100000;
    
    /*always @(posedge CLK100MHz, negedge rst_n) begin
        if(~rst_n) begin
            clk_count <= 0;
        end else begin
            if(~en | clk_count > 0) clk_count <= clk_count + 1;
            else if(en) clk_count <= 0;
        end
    end
    
    always_ff @(posedge sw, negedge rst_n) begin
       if(~rst_n) ch1_couple <= 0;
       else if(sw) ch1_couple <= ~ch1_couple;
    end*/
       
    /*always_ff @(posedge ch1_couple_sw, posedge ready, negedge rst_n) begin
        if(~rst_n) en <= 1;
            else if(ch1_couple_sw & ~ready) en <= 0;
        else if(ready) en <= 1;
    end*/
    assign ch1_couple = ch1_couple_sw;
    assign ch2_couple = ch2_couple_sw;
    assign en = 1;
          
    Control #(200, 0, 400) trig_control (.en, .rst_n, .clk(CLK100MHz), .rst(trig_reset), .up(trig_up), .down(trig_down), .data_ctrl(trig));
    Control #(300, 0, 600) time_control (.en, .rst_n, .clk(CLK100MHz), .rst(time_reset), .up(time_left), .down(time_right), .data_ctrl(time_offset));
    Control #(9, 3, 11) ch1_scale_control (.en, .rst_n, .clk(CLK100MHz), .rst(1'b1), .up(ch1_scale_in), .down(ch1_scale_out), .data_ctrl(ch1_scale));
    Control #(200, 0, 400) ch1_position_control (.en, .rst_n, .clk(CLK100MHz), .rst(ch1_reset), .up(ch1_up), .down(ch1_down), .data_ctrl(ch1_offset));
    Control #(9, 3, 11) ch2_scale_control (.en, .rst_n, .clk(CLK100MHz), .rst(1'b1), .up(ch2_scale_in), .down(ch2_scale_out), .data_ctrl(ch2_scale));
    Control #(200, 0, 400) ch2_position_control (.en, .rst_n, .clk(CLK100MHz), .rst(ch2_reset), .up(ch2_up), .down(ch2_down), .data_ctrl(ch2_offset));
    Control #(14, 1, 16) time_scale_control (.en, .rst_n, .clk(CLK100MHz), .rst(1'b1), .up(time_scale_in), .down(time_scale_out), .data_ctrl(time_scale));

    Sampling #(reg_size) sampling(.*);
    VGA #(reg_size) vga(.*);
    

endmodule
