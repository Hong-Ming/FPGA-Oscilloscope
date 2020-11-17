`timescale 1ns / 1ps

module Clk_div_4(
    input clk_in,
    input rst_n,
    output logic clk_out
    );
    
    logic c;
    
    clk_div_2 clk_div_2_1(.clk_in(clk_in), .clk_out(c), .rst_n(rst_n));
    clk_div_2 clk_div_2_2(.clk_in(c), .clk_out(clk_out), .rst_n(rst_n));
        
endmodule
