`timescale 1ns / 1ps

module controller_fsm (
    input logic clk,
    input logic reset,
    input logic rx_empty,
    input logic tx_empty,
    input logic sqrt_done,
    output logic load_AH,
    output logic load_AL,
    output logic load_DH,
    output logic load_DL,
    output logic uld_rx_data,
    output logic read_RAM,
    output logic write_RAM,
    output logic start_sqrt,
    output logic ld_tx_data,
    output logic send_high_byte_en,
    output logic send_low_byte_en
);

    typedef enum logic [3:0] {
        IDLE,
        LOAD_AH,
        LOAD_AL,
        LOAD_DH,
        LOAD_DL,
        READ_RAM,
        SEND_HIGH,
        SEND_LOW,
        START_SQRT,
        WAIT_SQRT,
        WRITE_RAM
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        load_AH = 0;
        load_AL = 0;
        load_DH = 0;
        load_DL = 0;
        uld_rx_data = 0;
        read_RAM = 0;
        write_RAM = 0;
        start_sqrt = 0;
        ld_tx_data = 0;
        send_high_byte_en = 0;
        send_low_byte_en = 0;

        next_state = state;

        case (state)
            IDLE: begin
                if (!rx_empty) begin
                    uld_rx_data = 1;
                    load_AH = 1;
                    next_state = LOAD_AL;
                end
            end

            LOAD_AH: begin
                if (!rx_empty) begin
                    uld_rx_data = 1;
                    load_AL = 1;
                    next_state = LOAD_DH;
                end
            end

            LOAD_AL: begin
                if (!rx_empty) begin
                    uld_rx_data = 1;
                    load_DH = 1;
                    next_state = LOAD_DL;
                end
            end

            LOAD_DH: begin
                if (!rx_empty) begin
                    uld_rx_data = 1;
                    load_DL = 1;
                    next_state = READ_RAM;
                end
            end

            LOAD_DL: begin
                next_state = READ_RAM;
            end

            READ_RAM: begin
                read_RAM = 1;
                next_state = SEND_HIGH;
            end

            SEND_HIGH: begin
                if (tx_empty) begin
                    ld_tx_data = 1;
                    send_high_byte_en = 1;
                    next_state = SEND_LOW;
                end
            end

            SEND_LOW: begin
                if (tx_empty) begin
                    ld_tx_data = 1;
                    send_low_byte_en = 1;
                    next_state = START_SQRT;
                end
            end

            START_SQRT: begin
                start_sqrt = 1;
                next_state = WAIT_SQRT;
            end

            WAIT_SQRT: begin
                if (sqrt_done) begin
                    next_state = WRITE_RAM;
                end
            end

            WRITE_RAM: begin
                write_RAM = 1;
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule
