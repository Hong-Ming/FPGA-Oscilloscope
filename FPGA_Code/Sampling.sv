`timescale 1ns / 1ps

module Sampling #(parameter reg_size = 600) (
    input rst_n,
    input CLK100MHz,
    input vauxp2,
    input vauxn2,
    input vauxp3,
    input vauxn3,
    input trig_off,
    input ch1_en,
    input ch2_en,
    input ch1_couple,
    input ch2_couple,
    input [3:0] ch1_scale,
    input [3:0] ch2_scale,
    input [4:0] time_scale,
    input [9:0] trig,
    input [9:0] ch1_offset,
    input [9:0] ch2_offset,
    output logic [9:0] data_out_1 [reg_size - 1:0],
    output logic [9:0] data_out_2 [reg_size - 1:0],
    output logic clk_sampling
    );
    
    logic enable1, enable2, out_clk,  GND, out_en, dis_en, ready1, ready2;//, clk_sampling;
    logic [1:0] reg_count;
    logic [7:0] Address_in_ch1, Address_in_ch2, clk_count, daddr_in;
    logic [9:0] trig_level;
    logic [9:0] data_reg [3:0];
    logic [15:0] data_count, do_out, data_ch1, data_ch2, out_count, sample_count;
    logic [31:0] data_cal_ch1, data_cal_ch2, data_tran, dis_count, time_sampling;
    
    assign trig_level = 440 - trig;
    assign Address_in_ch1 = 8'h12;
    assign Address_in_ch2 = 8'h13;
    
   //xadc instantiation connect the eoc_out .den_in to get continuous conversion
    xadcwiz  xadc_ch1 ( .daddr_in, //addresses can be found in the artix 7 XADC user guide DRP register space
                        .dclk_in(CLK100MHz), 
                        .den_in(enable1),                   
                        .vauxp2, .vauxn2, .vauxp3, .vauxn3,
                        .do_out, 
                        .di_in(16'd0), .dwe_in(1'b0), .vp_in(1'b0), .vn_in(1'b0), .reset_in(1'b0),
                        .eoc_out(enable1),
                        .drdy_out(ready1));

    always @(posedge CLK100MHz, negedge rst_n) begin
        if(~rst_n) dis_count <= 0;
        else begin
            dis_count <= dis_count + 1;
            if(dis_count >= time_sampling) dis_count <= 0;
        end
    end
    
    assign clk_sampling = (dis_count <= time_sampling/2);
    
    always @(posedge clk_sampling, negedge rst_n) begin
        if(~rst_n) daddr_in <= Address_in_ch1; 
        else begin
            if(daddr_in == Address_in_ch1) begin
                daddr_in <= Address_in_ch2;
                data_ch1 <= do_out;
            end else begin
                daddr_in <= Address_in_ch1;
                data_ch2 <= do_out;
            end
        end
    end

    always @(posedge CLK100MHz, negedge rst_n) begin
        if(~rst_n) begin
            reg_count <= 0;
        end else begin
            if(dis_count == 0) begin
                data_reg[reg_count] <= data_cal_ch1;
                reg_count <= reg_count - 1;
            end
        end
    end
    
    always @(posedge CLK100MHz, negedge rst_n) begin
        if(~rst_n) begin
            dis_en <= 0;
        end else begin
            if(data_reg[0] <= trig_level & data_reg[1] <= trig_level & data_reg[2] >= trig_level & data_reg[3] >= trig_level &
                data_reg[0] <= data_reg[1] & data_reg[1] <= data_reg[2] & data_reg[2] <= data_reg[3]) dis_en <= 1;
            else if(~rst_n | data_count >= reg_size - 1)  dis_en <= 0;
        end
    end
        
    always @(posedge clk_sampling, negedge rst_n) begin
        if(~rst_n) data_count <= 0;
        else if(dis_en | trig_off) begin
            data_out_1[data_count] <= data_cal_ch1;
            data_out_2[data_count] <= data_cal_ch2;
            if(data_count >= reg_size - 1) data_count <= 0;
            else data_count <= data_count + 1;
        end
    end
    
    Data_transfer ch1_data_transfer(.couple_in(ch1_couple), .offset_in(ch1_offset), .scale_in(ch1_scale), .data_in(data_ch1), .data_out(data_cal_ch1));
    Data_transfer ch2_data_transfer(.couple_in(ch2_couple), .offset_in(ch2_offset), .scale_in(ch2_scale), .data_in(data_ch2), .data_out(data_cal_ch2));
    Sampling_time sampling_time(.scale_in(time_scale), .time_sampling);
    
endmodule
