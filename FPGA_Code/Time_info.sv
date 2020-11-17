`timescale 1ns / 1ps

module Time_info(
    input [4:0] scale_in,
    output logic [31:0] time_scale
    );
    
    always_comb begin
        case(scale_in)
            0:  time_scale = 20;
            1:  time_scale = 50;
            2:  time_scale = 100;
            3:  time_scale = 200;
            4:  time_scale = 500;
            5:  time_scale = 1000;
            6:  time_scale = 2000;
            7:  time_scale = 5000;
            8:  time_scale = 10000;
            9:  time_scale = 20000;
            10:  time_scale = 50000;
            11:  time_scale = 100000;
            12:  time_scale = 200000;
            13:  time_scale = 500000;
            14:  time_scale = 1000000;
            15:  time_scale = 2000000;
            16:  time_scale = 5000000;
            17:  time_scale = 10000000;
            18:  time_scale = 20000000;
            19:  time_scale = 50000000;
            default:  time_scale = 1000000;
        endcase
    end
        
endmodule
