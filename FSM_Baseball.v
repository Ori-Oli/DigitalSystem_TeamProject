`timescale 1ns/1ns

module FSM_Baseball(pitch, rstn, clk, result);
    input [1:0] pitch;     // 00: none, 01: strike, 10: ball
    input rstn, clk;
    output [1:0] result;   // 00: none, 01: strike_out, 10: four_ball

    wire [1:0] pitch;
    wire rstn, clk;
    reg [1:0] result;
    reg [2:0] s_state;
    reg [2:0] b_state;

    // [Before]
    // reg [4:0] s_state;
    // reg [4:0] s_next_state;
    // reg [4:0] b_state;
    // reg [4:0] b_next_state;
    //
    // 기존 코드는 현재 상태와 다음 상태를 모두 reg로 저장했다.
    // 그러나 아래처럼 같은 always 블록 안에서 non-blocking assignment(<=)로
    // next_state와 state를 동시에 갱신하면 state가 새 next_state가 아니라
    // 이전 next_state 값을 받게 되어 출력이 한 클록 늦어진다.
    //
    // 예:
    // s_next_state <= s1;
    // s_state <= s_next_state;  // 여기서 s_state는 새 s1이 아니라 이전 값을 받음

    localparam [2:0] s0 = 3'b000, s1 = 3'b001, s2 = 3'b010,
                     b0 = 3'b011, b1 = 3'b100, b2 = 3'b101, b3 = 3'b110;

    // [Before]
    // localparam [2:0] s0 = 3'b000, s1 = 3'b001, s2 = 3'b010,
    //                  b0 = 3'b011, b1 = 3'b100, b2 = 3'b101, b3 = 3'b110,
    //                  out = 3'b111;
    //
    // 기존에는 strike out과 four ball을 모두 out 상태 하나로 표현했다.
    // 하지만 strike 쪽 out인지 ball 쪽 out인지에 따라 result가 달라야 하므로
    // 하나의 out 상태를 두 상태 레지스터가 따로 사용하면 출력이 헷갈릴 수 있다.
    // 수정 후에는 s2에서 strike가 들어오면 즉시 result=01,
    // b3에서 ball이 들어오면 즉시 result=10을 출력하도록 했다.

    // [Before]
    // always@(posedge clk or rstn) begin
    //
    // rstn은 active-low reset이므로 negedge rstn으로 감지하는 것이 맞다.
    // 기존처럼 "or rstn"으로 쓰면 rstn의 모든 변화에 반응하므로 reset 의도가
    // 명확하지 않다.
    always @(posedge clk or negedge rstn) begin
        if (rstn == 1'b0) begin
            s_state <= s0;
            b_state <= b0;
            result <= 2'b00;
        end else begin
            result <= 2'b00;

            if (pitch == 2'b01) begin
                // [Before]
                // case (s_next_state)
                //     s0: begin
                //         s_next_state <= s1;
                //         s_state <= s_next_state;
                //     end
                //     s1: begin
                //         s_next_state <= s2;
                //         s_state <= s_next_state;
                //     end
                //     s2: begin
                //         s_next_state <= out;
                //         s_state <= s_next_state;
                //     end
                // endcase
                //
                // 위 방식은 s_state가 s_next_state를 한 클록 늦게 따라간다.
                // 따라서 3번째 strike에서 바로 out이 나오지 않고 다음 클록으로 밀린다.
                // 수정 후에는 현재 s_state를 기준으로 바로 다음 상태와 출력을 정한다.
                case (s_state)
                    s0: s_state <= s1;
                    s1: s_state <= s2;
                    s2: begin
                        s_state <= s0;
                        b_state <= b0;
                        result <= 2'b01;
                    end
                    default: begin
                        s_state <= s0;
                        b_state <= b0;
                    end
                endcase
            end else if (pitch == 2'b10) begin
                // [Before]
                // case (b_next_state)
                //     b0: begin
                //         b_next_state <= b1;
                //         b_state <= b_next_state;
                //     end
                //     b1: begin
                //         b_next_state <= b2;
                //         b_state <= b_next_state;
                //     end
                //     b2: begin
                //         b_next_state <= b3;
                //         b_state <= b_next_state;
                //     end
                //     b3: begin
                //         b_next_state <= out;
                //         b_state <= b_next_state;
                //     end
                // endcase
                //
                // strike와 같은 이유로 b_state도 한 클록 늦게 갱신된다.
                // 따라서 4번째 ball에서 바로 four_ball이 나오지 않고 다음 클록으로 밀린다.
                case (b_state)
                    b0: b_state <= b1;
                    b1: b_state <= b2;
                    b2: b_state <= b3;
                    b3: begin
                        s_state <= s0;
                        b_state <= b0;
                        result <= 2'b10;
                    end
                    default: begin
                        s_state <= s0;
                        b_state <= b0;
                    end
                endcase
            end else if (pitch == 2'b00) begin
                result <= 2'b00;
            end
        end
    end

    // [Before]
    // always @(s_state) begin
    //     case (s_state)
    //         s0: result <= 2'b00;
    //         s1: result <= 2'b00;
    //         s2: result <= 2'b00;
    //         out: result <= 2'b01;
    //     endcase
    // end
    //
    // always @(b_state) begin
    //     case (b_state)
    //         b0: result <= 2'b00;
    //         b1: result <= 2'b00;
    //         b2: result <= 2'b00;
    //         b3: result <= 2'b00;
    //         out: result <= 2'b10;
    //     endcase
    // end
    //
    // 기존에는 result를 두 always 블록에서 동시에 제어했다.
    // 하나의 reg를 여러 always 블록에서 바꾸면 어떤 값이 마지막에 들어갈지
    // 애매해질 수 있으므로 안정적이지 않다.
    // 수정 후에는 위의 clock always 블록 하나에서만 result를 제어한다.
endmodule
