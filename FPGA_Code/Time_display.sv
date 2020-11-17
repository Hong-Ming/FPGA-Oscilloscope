`timescale 1ns / 1ps

module Time_display #(parameter offset_x = 0, parameter offset_y = 0)(
    input [4:0] scale_in,
    input [9:0] x_in,
    input [9:0] y_in,
    output logic display
    );

    logic time_icon_dis_1, time_icon_dis_2, time_info_dis;
    logic [31:0] time_scale;
    
    assign display = time_icon_dis_1 | time_icon_dis_2 | time_info_dis;
    
    Time_info time_info(.*);
    Word #(offset_x, offset_y) time_tag_1(.*, .number(5'd19), .display(time_icon_dis_1));
    Word #(offset_x + 7, offset_y) time_tag_2(.*, .number(5'd20), .display(time_icon_dis_2));
    Info_display #(offset_x + 14, offset_y, 1) info_display(.*, .number_in(time_scale), .display(time_info_dis));

endmodule
