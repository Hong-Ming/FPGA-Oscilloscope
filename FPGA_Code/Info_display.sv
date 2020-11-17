`timescale 1ns / 1ps

module Info_display #(parameter offset_x = 0, parameter offset_y = 0, parameter mode = 0)(
    input [9:0] x_in,
    input [9:0] y_in,
    input [31:0] number_in,
    output logic display
    );
    
    logic [4:0] eng, unit;
    logic [7:0] dis;
    logic [31:0] number_out, number_hundred, number_ten, number_one, number_one_ten, number_one_hundred;
    
    assign unit = (mode == 0)? 5'd13 : 5'd21;
    
    assign display = (dis == 0)? 0 : 1;
    assign number_hundred = ((number_out/10000) == 0)? 32'd16 : (number_out/10000);
    assign number_ten = ((number_out/10000) == 0 & (number_out/1000 %10) == 0)? 32'd16 : (number_out/1000 %10);
    assign number_one = (number_out/100%10);
    assign number_one_ten = (number_out/10%10);
    assign number_one_hundred = (number_out%10);
    
    always_comb begin
        if(number_in < 1000) begin
            eng = 5'd12;
            number_out = number_in * 100;
        end else if(number_in >= 1000 & number_in < 1000000) begin
            eng = 5'd11;
            number_out = number_in / 10;
        end else begin
            eng = 5'd16;
            number_out = number_in / 10000;
        end
    end
    
    Word #(offset_x      , offset_y) hundred_tag        (.*, .number(number_hundred     ), .display(dis[7]));
    Word #(offset_x +   7, offset_y) ten_tag            (.*, .number(number_ten         ), .display(dis[6]));
    Word #(offset_x +  14, offset_y) one_tag            (.*, .number(number_one         ), .display(dis[5]));
    Word #(offset_x +  21, offset_y) dp_tag             (.*, .number(5'd10              ), .display(dis[4]));
    Word #(offset_x +  28, offset_y) one_ten_tag        (.*, .number(number_one_ten     ), .display(dis[3]));
    Word #(offset_x +  35, offset_y) one_hundred_tag    (.*, .number(number_one_hundred ), .display(dis[2]));
    Word #(offset_x +  42, offset_y) eng_tag            (.*, .number(eng                ), .display(dis[1]));
    Word #(offset_x +  49, offset_y) unit_tag           (.*, .number(unit               ), .display(dis[0]));
       
endmodule
