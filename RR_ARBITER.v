module RR_ARBITER#(
    parameter PORTNUM=16
)(
    input               clk         ,
    input               rst_n       ,
    input [PORTNUM-1:0] req         ,
    input               schedule_en ,
    output[PORTNUM-1:0] gnt         
);


reg [PORTNUM-1:0] ptr_ff;

wire [PORTNUM-1:0] mask_req;
wire [PORTNUM-1:0] mask_pre_req;
wire [PORTNUM-1:0] mask_gnt;


wire [PORTNUM-1:0] unmask_pre_req;
wire [PORTNUM-1:0] unmask_gnt;

assign mask_req=req&ptr_ff;
assign mask_pre_req[PORTNUM-1:1]=mask_pre_req[PORTNUM-2:0]|mask_req[PORTNUM-2:0];
assign mask_gnt=mask_req&(~mask_pre_req);
assign mask_pre_req[0]=1'b0;

assign unmask_pre_req[PORTNUM-1:1]=unmask_pre_req[PORTNUM-2:0]|req[PORTNUM-2:0];
assign unmask_gnt=req&~unmask_pre_req;
assign unmask_pre_req[0]=1'b0;

assign gnt=(|mask_gnt)?mask_gnt:unmask_gnt;

always @(posedge clk or negedge rst_n) begin
    if(rst_n==1'b0) begin
        ptr_ff<='d0;
    end
    else if(|mask_gnt) begin
        ptr_ff<=mask_pre_req;
    end
    else begin
        ptr_ff<=unmask_pre_req;
    end
end
endmodule

module onehot_to_bin#(
    parameter ONEHOT_WIDTH=16,
    parameter BIN_WIDTH=4
)(
    input [ONEHOT_WIDTH-1:0] onehot,
    output[BIN_WIDTH-1:0] bin
);
    genvar i,j;
    wire [ONEHOT_WIDTH-1:0] temp_mask;
    generate
        for(i=0;i<BIN_WIDTH;i=i+1) begin:il
            for(j=0;j<ONEHOT_WIDTH;j=j+1) begin:jl
                assign temp_mask[j]=j[i];
            end
            assign bin[i]=|(temp_mask&onehot);
        end
    endgenerate
endmodule


module bin_to_onehot#(
    parameter BIN_WIDTH=4,
    parameter ONEHOT_WIDTH=16
)(
    input [BIN_WIDTH-1:0] bin,
    output [ONEHOT_WIDTH-1:0] onehot
);
assign onehot={{(ONEHOT_WIDTH-1){1'b0}},1'b1}<<bin;

endmodule
