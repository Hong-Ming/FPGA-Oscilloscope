`timescale 1ns / 1ps

module clk_div_16(
    input clk_in,
    input rst_n,
    output logic clk_out
    );
    
    logic c;
    
    Clk_div_4 clk_div_4_1(.clk_in(clk_in), .clk_out(c), .rst_n(rst_n));
    Clk_div_4 clk_div_4_2(.clk_in(c), .clk_out(clk_out), .rst_n(rst_n));

endmodule
