`timescale 1ns/1ns
`include "FSM_Baseball.v"

module FSM_Baseball_TEST;
    reg [1:0] pitch;
    reg rstn, clk;
    wire [1:0] result;

    FSM_Baseball u_FSM_Baseball(.pitch(pitch), .rstn(rstn), .clk(clk), .result(result));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("FSM_Baseball.vcd");
        $dumpvars(0, FSM_Baseball_TEST);
    end

    initial begin
        rstn = 1'b0; pitch = 2'b00; clk = 1'b0;
        #10 rstn = 1'b1;

        #10 pitch = 2'b01; // Scenario 1: strike
        #10 pitch = 2'b01; // strike
        #10 pitch = 2'b01; // strike -> out
        #10 pitch = 2'b00;
        #10 pitch = 2'b00;

        #10 pitch = 2'b10; // Scenario 2: ball
        #10 pitch = 2'b10; // ball
        #10 pitch = 2'b10; // ball
        #10 pitch = 2'b10; // ball -> four_ball
        #10 pitch = 2'b00;
        #10 pitch = 2'b00;

        #10 pitch = 2'b10; // Scenario 3: ball
        #10 pitch = 2'b10; // ball
        #10 pitch = 2'b01; // strike
        #10 pitch = 2'b10; // ball
        #10 pitch = 2'b01; // strike
        #10 pitch = 2'b10; // ball -> four_ball
        #10 pitch = 2'b00;
        #10 pitch = 2'b00;
        #10 $finish;
    end
endmodule
