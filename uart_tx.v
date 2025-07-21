`timescale 1ns / 1ps
    module uart_tx
    #(parameter DATA_BITS=8,SB_TICKS =16)
    (
    input clk,reset_n,
    input tx_start,
    input tick,
    input [DATA_BITS-1:0] tx_data_in,
    output reg tx,
    output reg tx_done_tick
);
    

localparam idle=0,start=1,data=2,stop=3;
     reg [1:0] state;
     reg [3:0] s;
     reg [$clog2(DATA_BITS) :0] n;
     
   
always @(posedge clk or negedge reset_n) begin

        if (~reset_n) 
        begin
            state <= idle;
            s <= 0;
            n <= 0;
            tx_done_tick <= 0;
            tx<= 1;
            end 
            else
             begin
            
            tx_done_tick <= 0; 
            if (tick)
             begin 
             case(state)
                    idle: begin
                        if (!tx_start) 
                        begin 
                            state <=start;
                            s<= 0;
                            n<= 0;
                        end
                    end
                    
                    start:
                     begin
                     if (s ==7)
                      begin 
                         if (!tx_start)
                             begin
                                state<= data;
                                s<= 0;
                                tx<= 0;
                             end 
                          else
                          begin 
                          state<= idle;
                            end
                       end
                       else 
                       begin
                            s<= s + 1;
                        end
                    end

                    data:
                     begin
                        if (s == 15) begin 
                            tx <= tx_data_in[n]; 
                            s<= 0;
                                if (n== 8)
                                 begin
                                    state<= stop;
                                    tx<=1;
                                    s<= 0;
                                end
                         else
                         begin
                           n<= n + 1;
                            end
                        end else begin
                            s<= s + 1;
                        end
                    end

                    stop:
                     begin
                     if (state == 15)
                          begin 
                                state <= idle;
                                tx_done_tick <= 1; 
                          end 
                      else
                            begin
                              s<= s + 1;
                            end
                    end
                endcase
        end 
   end
   end
endmodule