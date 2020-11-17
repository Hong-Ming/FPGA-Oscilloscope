`timescale 1ns / 1ps

module clk_div_256(
    input clk_in,
    input rst_n,
    output logic clk_out
    );
    
    logic c;
    
    clk_div_16 clk_div_16_1(.clk_in(clk_in), .clk_out(c), .rst_n(rst_n));
    clk_div_16 clk_div_16_2(.clk_in(c), .clk_out(clk_out), .rst_n(rst_n));

endmodule
