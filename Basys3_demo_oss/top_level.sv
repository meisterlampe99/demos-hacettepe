`default_nettype none

module top_level(
    input wire clk, rst_ext, 
    output logic [7:0] leds
    );

// Internal variables
logic rst;
logic [1:0] rstreg;

// Asynchronous-assert, synchronous-deassert reset synchronizer
always_ff @(posedge clk, posedge rst_ext)
begin
    // Assert internal reset asynchronously
    if (rst_ext) rstreg <= 2'b11;
    // Deassert internal reset synchronously
    else rstreg <= {rstreg[0], 1'b0};
end
// Assign synchronized reset from rstreg
always_comb rst = rstreg[1];
    
// Counter register
logic [23:0] cnt;

// Free-running counter
always_ff @(posedge clk)
begin
    if (rst)
        cnt <= 0;
    else
        cnt <= cnt + 1;
end

// Connect the 8 MSBs to the LEDs
always_comb leds = cnt[23:16];
    
endmodule

`default_nettype wire