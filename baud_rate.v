`timescale 1ns/1ps
module baud_rate(
    input clk,
    input reset_n,
    input [15:0] Final_Value,
    output reg tick
);

reg [15:0] s;
always @(posedge clk or negedge reset_n ) begin

    if(~reset_n)
     begin
        s <= 0;
        tick <= 0;
    end
    else begin
        if(s == Final_Value) begin
            s <= 0;
            tick <= ~tick;
        end
        else begin
            s <= s + 1;
        end
    end
end
endmodule