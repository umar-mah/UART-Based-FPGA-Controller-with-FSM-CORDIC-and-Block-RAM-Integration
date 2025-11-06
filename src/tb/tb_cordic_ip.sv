module tb_cordic_ip;

    logic clk;
    logic cartesian_valid_pulse;
    logic [15:0] cartesian_data;
    logic cordic_result_valid_pulse;
    logic [15:0] cordic_result;

    cordic_0 uut (
        .aclk(clk),
        .s_axis_cartesian_tvalid(cartesian_valid_pulse),
        .s_axis_cartesian_tdata(cartesian_data),
        .m_axis_dout_tvalid(cordic_result_valid_pulse),
        .m_axis_dout_tdata(cordic_result)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        cartesian_valid_pulse = 0;
        cartesian_data = 16'd4; // Input value

        #20 cartesian_valid_pulse = 1;
        #10 cartesian_valid_pulse = 0; // 1-cycle pulse

        wait (cordic_result_valid_pulse);
        $display("CORDIC Result: %d", cordic_result);

        #100 $finish;
    end

endmodule
