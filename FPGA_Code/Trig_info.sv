`timescale 1ns / 1ps

module Trig_info(
    input [3:0] scale_in,
    input [9:0] trig,
    input [9:0] offset_in,
    output logic [4:0] trig_sign,
    output logic [31:0] trig_scale
    );
    
    logic [31:0] trig_abs;
    
    assign trig_abs = (trig >= offset_in)? (trig - offset_in) : (offset_in - trig);
    assign trig_sign = (trig >= offset_in)? 5'd16 : 5'd17;
    
    always_comb begin
        case(scale_in)
            0:  trig_scale = trig_abs*20;
            1:  trig_scale = trig_abs*40;
            2:  trig_scale = trig_abs*100;
            3:  trig_scale = trig_abs*200;
            4:  trig_scale = trig_abs*400;
            5:  trig_scale = trig_abs*1000;
            6:  trig_scale = trig_abs*2000;
            7:  trig_scale = trig_abs*4000;
            8:  trig_scale = trig_abs*10000;
            9:  trig_scale = trig_abs*20000;
            10:  trig_scale = trig_abs*40000;
            11:  trig_scale = trig_abs*100000;
            12:  trig_scale = trig_abs*200000;
            default:  trig_scale = trig_abs*20000;
        endcase
    end
        
endmodule
