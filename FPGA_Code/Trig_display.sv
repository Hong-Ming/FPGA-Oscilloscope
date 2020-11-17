`timescale 1ns / 1ps

module Trig_display #(parameter offset_x = 0, parameter offset_y = 0)(
    input [3:0] scale_in,
    input [9:0] offset_in,
    input [9:0] trig,
    input [9:0] x_in,
    input [9:0] y_in,
    output logic display
    );
    
    logic trig_icon_dis, trig_sign_dis, trig_info_dis;
    logic [4:0] trig_sign;
    logic [31:0] trig_scale;
    
    assign display = trig_icon_dis | trig_sign_dis | trig_info_dis;
    
    Trig_info trig_info(.*);
    Word #(offset_x, offset_y) trig_icon_tag(.*, .number(5'd18), .display(trig_icon_dis));
    Word #(offset_x + 7, offset_y) trig_sign_tag(.*, .number(trig_sign), .display(trig_sign_dis));
    Info_display #(offset_x + 14, offset_y) info_display(.*, .number_in(trig_scale), .display(trig_info_dis));
    
endmodule
