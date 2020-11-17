`timescale 1ns / 1ps

module Channel_display #(parameter offset_x_tag = 0, parameter offset_x_info = 0, parameter offset_y_info = 0)(
    input [3:0] scale_in,
    input [4:0] mode,
    input [4:0] channel,
    input [9:0] x_in,
    input [9:0] y_in,
    input [9:0] offset_y_move,
    output logic display_light,
    output logic display_dark
    );
    
    logic move_tag, info_tag, info_dis, mode_tag;
    logic [31:0] info_out;
    
    assign display_light = info_dis | mode_tag;
    assign display_dark = move_tag | info_tag;
    
    Word_move channel_tag(.*, .offset_x(offset_x_tag), .offset_y(offset_y_move), .number(channel), .display(move_tag));
    Word #(offset_x_info, offset_y_info) channel_icon(.*, .number(channel), .display(info_tag));
    Scale_tag channel_scale_tag(.scale_in, .code_out(info_out));
    Info_display #(offset_x_info + 12, offset_y_info) channel_info_display(.*, .number_in(info_out), .display(info_dis));
    Word #(offset_x_info + 68, offset_y_info) channel_mode_tag(.*, .number(mode), .display(mode_tag));
    
endmodule
