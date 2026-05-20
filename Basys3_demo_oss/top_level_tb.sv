// ============================================================
// Testbench for top_level.sv
// Simulation with Icarus Verilog
// VCD output for Surfer / GTKWave
// ============================================================
`default_nettype none

module top_level_tb();

logic clk;
logic rst_ext;
logic [7:0] leds;

top_level DUT (
    .clk(clk),
    .rst_ext(rst_ext),
    .leds(leds)
);

initial clk = 0;
always #5ns clk = ~clk;

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, top_level_tb);
end

initial begin
    rst_ext = 1;
    #200ns;
    rst_ext = 0;
    
    // Wait until LEDs visibly change (bit 16 toggles around 655 us)
    #10ms;  // simulate 10 ms
    
    // Test reset again
    rst_ext = 1;
    #200ns;
    rst_ext = 0;
    #10ms;  // 10ms
    
    $finish;
end

endmodule

`default_nettype wire
