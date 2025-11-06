`timescale 1ns / 1ps

module tb_top_controller;

    reg clk_100Mhz;
    reg reset;
    reg rx_in;
    wire tx_out;

    top_controller uut (
        .clk_100Mhz(clk_100Mhz),
        .reset(reset),
        .rx_in(rx_in),
        .tx_out(tx_out)
    );

    always begin
        #5 clk_100Mhz = ~clk_100Mhz;  // 100 MHz clock (10ns period)
    end

    initial begin
        clk_100Mhz = 0;
        reset = 0;
        rx_in = 0;

        reset = 1;
        #20;  
        reset = 0;

        rx_in = 1'b1;  // Start bit
        #8686;
        rx_in = 1'b0;  // Data bit 1 (0xAA pattern)
        #8686;
        rx_in = 1'b1;  // Data bit 2
        #8686;
        rx_in = 1'b0;  // Data bit 3
        #8686;
        rx_in = 1'b1;  // Data bit 4
        #8686;
        rx_in = 1'b0;  // Data bit 5
        #8686;
        rx_in = 1'b1;  // Data bit 6
        #8686;
        rx_in = 1'b0;  // Data bit 7
        #8686;
        rx_in = 1'b1;  // Stop bit
        #8686;

        // UART data processing
        #10000;

        $display("tx_out: %b", tx_out);

        #20000;
        $finish;
    end

    initial begin
        $monitor("At time %t, reset = %b, rx_in = %b, tx_out = %b", $time, reset, rx_in, tx_out);
    end

endmodule
