`timescale 1ns/1ps

module uart_tb();

    parameter TIMER = 10;  

   
    reg clk, reset_n;
    reg wr_en;
    wire tick;
    reg [7:0] tx_data_in;
    wire tx, tx_done_tick;
    wire tx_full, tx_empty;
    wire [7:0] fifo_to_tx;
    wire tx_start = ~tx_empty; 
    reg rx;
    wire [7:0] rx_data_out;
    wire rx_done_tick;
    reg rd_uart=1;
    wire [7:0]r_data;
    wire rx_full,rx_empty;
    wire connect =tx;
    
    
    FIFO fifotx(
        .data_in(tx_data_in),
        .wr_en(wr_en),
        .rd_en(~tx_done_tick), 
        .clk(clk),
        .rst_n(reset_n),
        .full(tx_full),
        .empty(tx_empty),
        .data_out(fifo_to_tx)
    );
    baud_rate brg(
        .clk(clk),
        .reset_n(reset_n),
        .tick(tick),
        .Final_Value(1)
    );
    FIFO fiforx(
            .data_in(rx_data_out),
            .wr_en(rx_done_tick),
            .rd_en(rd_uart),
            .clk(clk),
            .rst_n(reset_n),
            .full(rx_full),
            .empty(rx_empty),
            .data_out(r_data)
);
uart_rx u_rx (
        .tick(tick),
        .clk(clk),
        .reset_n(reset_n),
        .rx(connect),
        .rx_data_out(rx_data_out),
        .rx_done_tick(rx_done_tick)
    );
    uart_tx utx(
        .tick(tick),
        .clk(clk),
        .reset_n(reset_n),
        .tx_start(tx_start),
        .tx_data_in(fifo_to_tx),
        .tx(tx),
        .tx_done_tick(tx_done_tick)
    );

    
    always begin
        clk = 0;
        #(TIMER/2);
        clk = 1;
        #(TIMER/2);
    end

    
    initial begin
        reset_n = 0;
        wr_en = 0;
       tx_data_in = 8'h00;
        #100;
        reset_n = 1;
        #100;

       
        @(negedge clk);
        wr_en = 1;
        tx_data_in = 8'b01001100;
        @(negedge clk);
        wr_en = 0;

        
       #100
       

        #5000;
        $finish;
    end



endmodule