`timescale 1ns/1ns

module FSM_Baseball(pitch, rstn, clk, result);
    input [1:0] pitch;// 00: none, 01: strike, 10: ball
    input rstn, clk;
    output [1:0] result;// 00: none, 01: strike_out, 10: four_ball

    wire [1:0] pitch;
    wire rstn, clk;
    reg [1:0] result;
    reg [4:0] s_state;
    reg [4:0] s_next_state;
    reg [4:0] b_state;
    reg [4:0] b_next_state;

    localparam [2:0] s0 = 3'b000, s1 = 3'b001, s2 = 3'b010,
                     b0 = 3'b011, b1 = 3'b100, b2 = 3'b101, b3 = 3'b110,
                     out = 3'b111;


    always@(posedge clk or rstn) begin
        if (rstn == 1'b0) begin
            s_state = s0;
            b_state = b0;
            s_next_state = s0;
            b_next_state = b0;
            result = 2'b00;
        end else begin
            if (pitch == 2'b01) begin
                case(s_next_state)
                    s0: begin
                        s_next_state <= s1;
                        s_state <= s_next_state;
                    end
                    s1: begin
                        s_next_state <= s2;
                        s_state <= s_next_state;
                    end
                    s2: begin
                        s_next_state <= out;
                        s_state <= s_next_state;
                    end
                    out : begin
                        s_next_state <= s0;
                        s_state <= s_next_state;
                        b_next_state <= b0;
                        b_state <= b_next_state;
                    end
                endcase
            end else if (pitch == 2'b10) begin
                case(b_next_state)
                    b0: begin
                        b_next_state <= b1;
                        b_state <= b_next_state;
                    end
                    b1: begin
                        b_next_state <= b2;
                        b_state <= b_next_state;
                    end
                    b2: begin
                        b_next_state <= b3;
                        b_state <= b_next_state;
                    end
                    b3: begin
                        b_next_state <= out;
                        b_state <= b_next_state;
                    end
                    out : begin
                        s_next_state <= s0;
                        s_state <= s_next_state;
                        b_next_state <= b0;
                        b_state <= b_next_state;
                    end
                endcase
            end 
            else if (pitch == 2'b00) begin
                s_next_state <= s0;
                s_state <= s_next_state;
                b_next_state <= b0;
                b_state <= b_next_state;
            end
        end
    end

    always @(s_state) begin
        case (s_state)
            s0: result <= 2'b00;
            s1: result <= 2'b00;
            s2: result <= 2'b00;
            out: result <= 2'b01;
        endcase
    end

    always @(b_state) begin
        case (b_state)
            b0: result <= 2'b00;
            b1: result <= 2'b00;
            b2: result <= 2'b00;
            b3: result <= 2'b00;
            out: result <= 2'b10;
        endcase
    end

endmodule