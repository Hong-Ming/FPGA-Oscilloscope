`timescale 1ns / 1ps

module clk_div_2(
    input clk_in,
    input rst_n,
    output logic clk_out
    );
    
    DFF dff1(.D(~clk_out), .Q(clk_out), .clk(clk_in), .rst_n(rst_n));
    
endmodule
