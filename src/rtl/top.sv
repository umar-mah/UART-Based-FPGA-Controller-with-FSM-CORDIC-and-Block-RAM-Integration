`timescale 1ns / 1ps
module top_controller #(
    parameter CLK_DIV_PARAM = 868 // For 100MHz clock and 115200 baud
) (
    input logic clk_100Mhz,  
    input logic reset,       
    input logic rx_in,       
    output logic tx_out      
);


    // Internal Signals

    // FSM signals
    logic rx_empty_fsm;
    logic tx_empty_fsm;
    logic sqrt_done_fsm;
    logic load_AH_fsm;
    logic load_AL_fsm;
    logic load_DH_fsm;
    logic load_DL_fsm;
    logic uld_rx_data_fsm;
    logic read_RAM_fsm;
    logic write_RAM_fsm;
    logic start_sqrt_fsm;
    logic ld_tx_data_fsm;
    logic send_high_byte_en_fsm; 
    logic send_low_byte_en_fsm;  

    // UART signals
    logic [7:0] rx_data_uart;
    logic rx_enable_uart = 1'b1; // enabling receiver always
    logic tx_enable_uart = 1'b1; // enable transmitter always
    logic [7:0] tx_data_uart;
    logic rx_empty_uart;
    logic tx_empty_uart;

    logic [7:0] addr_high_byte;
    logic [7:0] addr_low_byte;
    logic [7:0] data_high_byte;
    logic [7:0] data_low_byte;
    
    // RAM
    logic [11:0] ram_address_internal; // RAM address is 12 bits
    logic ram_write_enable_internal; 
    logic [15:0] ram_data_in_internal; 
    logic [15:0] ram_data_out_internal;

    // CORDIC signals
    logic [15:0] cordic_input_internal;
    logic cordic_start_pulse_internal; 
    logic [15:0] cordic_output_internal;
    logic cordic_output_valid; 


    // FSM Instance
    controller_fsm fsm_inst (
        .clk(clk_100Mhz),
        .reset(reset),
        .rx_empty(rx_empty_uart), 
        .tx_empty(tx_empty_uart), 
        .sqrt_done(cordic_output_valid), 
        .load_AH(load_AH_fsm),
        .load_AL(load_AL_fsm),
        .load_DH(load_DH_fsm),
        .load_DL(load_DL_fsm),
        .uld_rx_data(uld_rx_data_fsm),
        .read_RAM(read_RAM_fsm),
        .write_RAM(write_RAM_fsm),
        .start_sqrt(start_sqrt_fsm),
        .ld_tx_data(ld_tx_data_fsm),
        .send_high_byte_en(send_high_byte_en_fsm), 
        .send_low_byte_en(send_low_byte_en_fsm)   
    );

    // UART Instance
    uart #(
        .CLK_DIVISION(CLK_DIV_PARAM) 
    ) uart_inst (
        .reset(reset),
        .ld_tx_data(ld_tx_data_fsm), 
        .tx_data(tx_data_uart),      
        .tx_enable(tx_enable_uart),  
        .tx_out(tx_out),             
        .tx_empty(tx_empty_uart),    
        .clk(clk_100Mhz),
        .uld_rx_data(uld_rx_data_fsm), 
        .rx_data(rx_data_uart),      
        .rx_enable(rx_enable_uart),  
        .rx_in(rx_in),               
        .rx_empty(rx_empty_uart)     
    );

    // CORDIC IP core Instance
    cordic_0 cordic_inst (
        .aclk(clk_100Mhz),
        .s_axis_cartesian_tvalid(cordic_start_pulse_internal), 
        .s_axis_cartesian_tdata(cordic_input_internal),       
        .m_axis_dout_tvalid(cordic_output_valid),    
        .m_axis_dout_tdata(cordic_output_internal)            
    );

    // Block Memory Generator (RAM) Instance
    blk_mem_gen_0 ram_inst (
        .clka(clk_100Mhz),
        .ena(1'b1),          
        .wea(ram_write_enable_internal),  
        .addra(ram_address_internal),     
        .dina(ram_data_in_internal),      
        .douta(ram_data_out_internal)     
    );


    always_ff @(posedge clk_100Mhz or posedge reset) begin
        if (reset) begin
            addr_high_byte <= 8'h00;
            addr_low_byte  <= 8'h00;
            data_high_byte <= 8'h00;
            data_low_byte  <= 8'h00;
        end else begin
           
            if (uld_rx_data_fsm) begin
                if (load_AH_fsm) addr_high_byte <= rx_data_uart;
                if (load_AL_fsm) addr_low_byte  <= rx_data_uart;
                if (load_DH_fsm) data_high_byte <= rx_data_uart;
                if (load_DL_fsm) data_low_byte  <= rx_data_uart;
            end
        end
    end
    
    // Need to verify this, whether the address pins are 16 bits or 12 bits
    assign ram_address_internal = {addr_high_byte[3:0], addr_low_byte[7:0]};
    
    logic [15:0] assembled_rx_data;
    assign assembled_rx_data = {data_high_byte, data_low_byte};


    // When the FSM is in the WRITE_RAM state, it writes the CORDIC result.
    // Otherwise, the RAM input is the data assembled from the UART bytes.
    assign ram_data_in_internal = write_RAM_fsm ? cordic_output_internal : assembled_rx_data;


    // The data read from RAM is the input to the CORDIC.
    assign cordic_input_internal = ram_data_out_internal;

    // Pulsing CORDIC start based on FSM signal
    logic start_sqrt_fsm_d;
    always_ff @(posedge clk_100Mhz or posedge reset) begin
        if (reset)
            start_sqrt_fsm_d <= 1'b0;
        else
            start_sqrt_fsm_d <= start_sqrt_fsm;
    end
    assign cordic_start_pulse_internal = start_sqrt_fsm && !start_sqrt_fsm_d; // Generates a pulse on the rising edge of start_sqrt_fsm

    // Provides data for UART transmission
    always_comb begin
        tx_data_uart = 8'h00; // Default
        if (ld_tx_data_fsm) begin // When FSM enables load TX data
            if (send_high_byte_en_fsm) begin
                tx_data_uart = ram_data_out_internal[15:8]; // Send the upper byte
            end else if (send_low_byte_en_fsm) begin
                tx_data_uart = ram_data_out_internal[7:0];  // Send the lower byte
            end
        end
    end

    assign ram_write_enable_internal = write_RAM_fsm;



endmodule
