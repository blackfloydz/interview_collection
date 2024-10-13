//题目要求：sync clka时钟域存在一个单周期pulse sync，sync拉高的时候将clkb中的output信号拉高。output信号拉高之后如果收到T1信号会拉低，如果没有收到sync信号，在T1时间端之后也会拉低。clka的频率大于clkb
//要点：ouput信号有一个上升的条件，两个下降的条件
//方案：快时钟域脉冲展宽+目标时钟域边沿检测
//test
module CDC_HD #(
    parameter T1=4
)
(
    input           clka,
    input           clkb,
    input           rst_n,
    input           sync,
    output reg      op    
);

    reg             sync_expanded;
    reg             sync_ff1,sync_ff2,sync_ff3;
    wire            edge_detected;
    reg     [2:0]   T1_cnt;

//pulse expansion
always @(posedge clka or negedge rst_n) begin
    if(rst_n==1'b0) begin
        sync_expanded<=1'b0;
    end
    else begin
        sync_expanded<=sync^sync_expanded;
    end
end

//CDC
always @(posedge clkb or negedge rst_n) begin
    if(rst_n==1'b0) begin
        sync_ff1<=1'b0;
        sync_ff2<=1'b0;
    end
    else begin
        sync_ff1<=sync_expanded;
        sync_ff2<=sync_ff1;
    end
end

//edge detect

always @(posedge clkb or negedge rst_n) begin
    if(rst_n==1'b0) begin
        sync_ff3<=1'b0;
    end
    else begin
        sync_ff3<=sync_ff3;
    end
end

assign edge_detected=sync_ff2^sync_ff3;

//T1 counter

always @(posedge clkb or negedge rst_n) begin
    if(rst_n==1'b0) begin
        T1_cnt<=3'd0;
    end
    else if(sync_ff2==1'b1)begin
        T1_cnt<=T1_cnt+1'b1;
    end
    else begin
        T1_cnt<=3'd0;
    end
end

always @(posedge clkb or negedge rst_n) begin
    if(rst_n==1'b0) begin
        op<=1'b0;
    end
    else if(T1_cnt==T1) begin
        op<=1'b0;
    end
    else if(edge_detected) begin
        op<=~op;
    end
end
    
endmodule