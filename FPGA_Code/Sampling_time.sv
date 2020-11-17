`timescale 1ns / 1ps

module Sampling_time(
    input [4:0] scale_in,
    output logic [31:0] time_sampling
    );
    
    logic [31:0] time_out;
    
    assign time_sampling = time_out;
    
    always_comb begin
        case(scale_in)
            1:  time_out =        100;//50u
            2:  time_out =        200;//100u
            3:  time_out =        400;//200u
            4:  time_out =       1000;//500u
            5:  time_out =       2000;//1m
            6:  time_out =       4000;//2m
            7:  time_out =      10000;//5m
            8:  time_out =      20000;//10m
            9:  time_out =      40000;//20m
            10:  time_out =    100000;//50m
            11:  time_out =    200000;//100m
            12:  time_out =    400000;//200m
            13:  time_out =   1000000;//500m
            14:  time_out =   2000000;//1
            15:  time_out =   4000000;//2
            16:  time_out =  10000000;//5
            default:  time_out =  10000000;//1
        endcase
    end
    
endmodule
