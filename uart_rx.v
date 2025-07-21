`timescale 1ns/1ps
module uart_rx
#(parameter DATA_BITS=8 , SB_TICKS=16)
(
    input clk,
    input reset_n,
    input tick,
    input rx,
    output reg [7:0] rx_data_out,
    output reg rx_done_tick
);

localparam idle=0,start=1,data=2,stop=3;

reg [1:0] state;
 reg [3:0] s;
 reg [$clog2(DATA_BITS) :0] n;
 reg [DATA_BITS -1:0] b;


always @(posedge clk or negedge reset_n) 
begin
    if (~reset_n) 
        begin
        state <= idle;
        s <= 0;
        n <= 0;
        b<=0;
        rx_done_tick <= 0;
        rx_data_out <= 8'b00000000;
        end 
    else 
        begin
      
        rx_done_tick <= 0; 
        
        if (tick) begin
            case(state)
                idle: begin
                    if (!rx) begin 
                        state<= start;
                        s<= 0;
                        n<= 0;
                    end
                end
                
                start:
                 begin
                        if (s == 7) begin 
                            if (!rx)
                             begin 
                            state <= data;
                            s <= 0;
                            end 
                        else
                        begin
                        state<= idle;
                        end
                        end
                         else
                          begin
                           s <= s + 1;
                           end
                end

                data: begin
                    if (s == 15)
                     begin 
                        b[n] <= rx; 
                        s <= 0;
                        if (n == 7)
                         begin
                            state <= stop;
                        end else begin
                            n <= n + 1;
                        end
                    end
                     else
                      begin
                        s <= s + 1;
                    end
                end

                stop: 
                begin
                    if (s == 15) begin 
                        state<= idle;
                        rx_data_out <= b;
                        rx_done_tick <= 1;
                    end 
                    else
                     begin
                        s <= s + 1;
                      end
               end
        endcase
    end
    end
    end

endmodule








