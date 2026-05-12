// ============================================================
// Testbench für top_level.sv
// Simulation mit Icarus Verilog
// VCD Output für Surfer / GTKWave
// ============================================================
`timescale 1ns/1ps
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
    
    // Warte bis LEDs sich ändern (Bit 16 = 655µs)
    #10ms;  // 10ms simulieren
    
    // Reset nochmal testen
    rst_ext = 1;
    #200ns;
    rst_ext = 0;
    #10ms;  // 10ms
    
    $finish;
end

endmodule

`default_nettype wire
