`timescale 1ns / 1ps

module Scale_tag(
    input [3:0] scale_in,
    output logic [31:0] code_out
    );

    always_comb begin
        case(scale_in)
            0:  code_out = 1000;
            1:  code_out = 2000;
            2:  code_out = 5000;
            3:  code_out = 10000;
            4:  code_out = 20000;
            5:  code_out = 50000;
            6:  code_out = 100000;
            7:  code_out = 200000;
            8:  code_out = 500000;
            9:  code_out = 1000000;
            10:  code_out = 2000000;
            11:  code_out = 5000000;
            12:  code_out = 10000000;
            default:  code_out = 1000000;
        endcase
    end

endmodule
