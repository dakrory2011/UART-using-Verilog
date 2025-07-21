`timescale 1ns/1ps
module uart(
    input clk, reset_n, rx, rd_uart, wr_uart,
    input [7:0] w_data,
    input [15:0] Final_Value,
    output tx, rx_empty, tx_full,
    output [7:0] r_data,
    output full,
    output wr_ack1, wr_ack2
   
);
    wire tick;
    baud_rate
        (
        .clk(clk),
        .reset_n(reset_n),
        .Final_Value(Final_Value),
        .tick(tick)
        );

  
    wire [7:0] rx_data_out;
    wire rx_done_tick;
    uart_rx receiver(
        .tick(tick),
        .clk(clk),
        .reset_n(reset_n),
        .rx(rx),
        .rx_data_out(rx_data_out),
        .rx_done_tick(rx_done_tick)
    );

    
    wire tx_empty;
    wire [7:0] tx_data_in;
    wire tx_done_tick, tx_start;
    assign tx_start = ~tx_empty; 
    
    uart_tx transmitter(
        .tick(tick),
        .clk(clk),
        .reset_n(reset_n),
        .tx_start(tx_start),
        .tx_data_in(tx_data_in),
        .tx(tx),
        .tx_done_tick(tx_done_tick)
    );
    FIFO rx_fifo(
        .data_in(rx_data_out),
        .wr_en(rx_done_tick),
        .rd_en(rd_uart),
        .clk(clk),
        .rst_n(reset_n),
        .data_out(r_data),
        .full(full),
        .empty(rx_empty),
        .wr_ack(wr_ack1)
    );
    FIFO tx_fifo(
        .data_in(w_data),
        .wr_en(wr_uart),
        .rd_en(~tx_start),
        .clk(clk),
        .rst_n(reset_n),
        .data_out(tx_data_in),
        .full(tx_full),
        .empty(tx_empty),
        .wr_ack(wr_ack2)
        
    );

endmodule