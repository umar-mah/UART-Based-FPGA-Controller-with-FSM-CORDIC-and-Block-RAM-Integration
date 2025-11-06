module tb_controller_fsm;

    logic clk;
    logic reset;
    logic rx_empty;
    logic tx_empty;
    logic sqrt_done;
    logic load_AH;
    logic load_AL;
    logic load_DH;
    logic load_DL;
    logic uld_rx_data;
    logic read_RAM;
    logic write_RAM;
    logic start_sqrt;
    logic ld_tx_data;
    logic send_high_byte_en;
    logic send_low_byte_en;

    controller_fsm uut (
        .clk(clk),
        .reset(reset),
        .rx_empty(rx_empty),
        .tx_empty(tx_empty),
        .sqrt_done(sqrt_done),
        .load_AH(load_AH),
        .load_AL(load_AL),
        .load_DH(load_DH),
        .load_DL(load_DL),
        .uld_rx_data(uld_rx_data),
        .read_RAM(read_RAM),
        .write_RAM(write_RAM),
        .start_sqrt(start_sqrt),
        .ld_tx_data(ld_tx_data),
        .send_high_byte_en(send_high_byte_en), 
        .send_low_byte_en(send_low_byte_en)
    );

    always begin
        #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        clk = 0;
        reset = 0;
        rx_empty = 1;
        tx_empty = 1;
        sqrt_done = 0;

        reset = 1;
        #10 reset = 0;

        // Test Case 1: Transitions through the states when rx_empty is low
        rx_empty = 0;  // Simulates rx_empty as not empty
        #100;            

        // Test Case 2: Simulates tx_empty being low to progress to SEND_HIGH
        tx_empty = 0;
        #20;            

        // Test Case 3: Simulates sqrt_done to complete the sequence
        sqrt_done = 1;
        #20;            // Allows FSM to transition to WRITE_RAM

        // Test Case 4: Resets again and checks FSM behavior
        reset = 1;
        #10 reset = 0;
        #10; 

        $stop;
    end

    initial begin
        $monitor("Time: %0t | state: %b | load_AH: %b | load_AL: %b | load_DH: %b | load_DL: %b | uld_rx_data: %b | read_RAM: %b | write_RAM: %b | start_sqrt: %b | ld_tx_data: %b", 
                 $time, uut.state, load_AH, load_AL, load_DH, load_DL, uld_rx_data, read_RAM, write_RAM, start_sqrt, ld_tx_data);
    end

endmodule
