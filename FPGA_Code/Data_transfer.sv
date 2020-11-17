`timescale 1ns / 1ps

module Data_transfer(
    input couple_in,
    input [3:0] scale_in,
    input [9:0] offset_in,
    input [15:0] data_in,
    output logic [31:0] data_out
    );
    
    logic [31:0] data_reg;
    
    assign data_reg = (couple_in)? data_in[15:4] : data_in[15:4];
    
    always_comb begin
        //if(couple_in) begin
            case(scale_in)
              /*  0:  data_out <= data_reg*125 - offset_in - 1013;
                1:  data_out <= data_reg*125/2 - offset_in - 286;
                2:  data_out <= data_reg*25 - offset_in - 465;*/
                3:  data_out <= data_reg*25/2 - offset_in - 26025;
                4:  data_out <= data_reg*25/4 - offset_in - 12792;
                5:  data_out <= data_reg*5/2 - offset_in - 5262;
                6:  data_out <= data_reg*5/4 - offset_in - 2412;//standard
                7:  data_out <= data_reg*5/8 - offset_in - 986;
                8:  data_out <= data_reg/4 - offset_in - 130;
                9:  data_out <= data_reg/8 - offset_in + 155;
                10:  data_out <= data_reg/16 - offset_in + 298;
                11:  data_out <= data_reg/40 - offset_in + 383;
                default:  data_out <= data_reg/8 - offset_in - 56;
            endcase
       /* end else begin
            case(scale_in)
                0:  data_out <= data_reg*125 - offset_in - 1013;
                1:  data_out <= data_reg*125/2 - offset_in - 286;
                2:  data_out <= data_reg*25 - offset_in - 465;
                3:  data_out <= data_reg*25/2 - offset_in + 500;
                4:  data_out <= data_reg*25/4 - offset_in + 470;
                5:  data_out <= data_reg*5/2 - offset_in + 862;
                6:  data_out <= data_reg*5/4 - offset_in + 651;//standard
                7:  data_out <= data_reg*5/8 - offset_in + 34;
                8:  data_out <= data_reg/4 - offset_in + 892;
                9:  data_out <= data_reg/8 - offset_in + 154;
                10:  data_out <= data_reg/16 - offset_in + 297;
                11:  data_out <= data_reg/40 - offset_in + 383;
                12:  data_out <= data_reg/80 - offset_in + 412;
                default:  data_out <= data_reg/8 - offset_in;
            endcase
        end*/
    end
        
endmodule
