`timescale 1ns / 1ps

module Control  #(parameter offset = 0, parameter down_limit = 0, parameter up_limit = 500) (
    input rst_n,
    input clk,
    input en,
    input rst,
    input up,
    input down,
    output logic [9:0] data_ctrl
    );
    
    logic ctrl, clk_time;
    logic [9:0] next;
    logic [19:0] time_count;
    
    always_ff @(posedge up, negedge rst, negedge rst_n) begin
        if(~rst_n) next <= offset;
        else if(~rst) next <= offset;
        else if(up & ~down) begin
            if(data_ctrl >= up_limit) next <= up_limit;
            else next <= data_ctrl + 1;
        end else if(up & down) begin
            if(data_ctrl<= down_limit) next <= down_limit;
            else next <= data_ctrl - 1;
        end else next <= data_ctrl;
    end
    
    always_ff @(posedge clk_time, negedge rst, negedge rst_n) begin
        if(~rst_n) data_ctrl <= offset;
        else if(~rst & en) data_ctrl <= offset;
        else if(up & down & en) data_ctrl <= next;
    end
    
    always_ff @(posedge clk, negedge rst_n) begin
        if(~rst_n) time_count <= 0;
        else time_count <= time_count + 1;
    end
    
    assign clk_time = (time_count < 500000);
        
endmodule
