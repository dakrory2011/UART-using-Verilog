`timescale 1ns/1ps
module FIFO #(
    parameter FIFO_WIDTH = 8, FIFO_DEPTH = 1024)
    (
      input clk, rst_n,
       input wr_en, rd_en,
       input [FIFO_WIDTH-1:0] data_in,
       output reg [FIFO_WIDTH-1:0] data_out,
       output full, empty,
       output reg wr_ack
);

    localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);

    reg [FIFO_WIDTH-1:0] storage_array [FIFO_DEPTH-1:0];
    reg [ADDR_WIDTH-1:0] write_idx, read_idx;
    reg [ADDR_WIDTH:0] used_count;

    // Write logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_idx <= 0;
            wr_ack <= 0;
        end else begin
            if (wr_en && !full) begin
                storage_array[write_idx] <= data_in;
                write_idx <= write_idx + 1;
                wr_ack <= 1;
            end else begin
                wr_ack <= 0;
            end
        end
    end

    // Read logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_idx <= 0;
            data_out <= 0;
        end else if (rd_en && !empty) begin
            data_out <= storage_array[read_idx];
            read_idx <= read_idx + 1;
        end
    end

    // Counter logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            used_count <= 0;
        end else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10: used_count <= used_count + 1;
                2'b01: used_count <= used_count - 1;
                default: used_count <= used_count;
            endcase
        end
    end

    assign full = (used_count == FIFO_DEPTH);
    assign empty = (used_count == 0);

endmodule
