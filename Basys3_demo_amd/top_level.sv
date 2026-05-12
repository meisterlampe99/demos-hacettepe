`default_nettype none

module top_level(
    input wire clk, rst_ext, 
    output logic [7:0] leds
    );

//internal variables
logic rst;
logic [1:0] rstreg;

//supply based reset synchronizer
always_ff @(posedge clk, posedge rst_ext)
begin
	//assert internal reset asynchronously
    if (rst_ext) rstreg <= 2'b11;
	//deassert internal reset synchronously
    else rstreg <= {rstreg[0], 1'b0};
end
//assign synchronized reset from rstreg
always_comb rst = rstreg[1];
    
//variable for storing count value
logic [23:0] cnt;

//counter itself
always_ff @(posedge clk)
begin
    if (rst)
        cnt <= 0;
    else
        cnt <= cnt + 1;
end

//contect the 8MSBs to the leds
always_comb leds = cnt[23:16];
    
endmodule

`default_nettype wire