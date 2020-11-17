`timescale 1ns / 1ps

module DFF(D, Q, clk, rst_n);
    parameter bitwidth = 1;
    input clk, rst_n;
    input [bitwidth-1:0] D;
    output logic [bitwidth-1:0] Q;
    
    always_ff @(posedge clk, negedge rst_n) begin
        if(~rst_n) Q <= 0;
        else if(clk) Q <= D;
        else Q <= Q;
    end
    
endmodule
