module slider_logic (
    input  logic clk,
    input  logic slider_in,
    output logic slider_out
);
//shift register for slider sync
	logic [1:0] slider_sreg;
    always_ff @(posedge clk) begin
        slider_sreg <= {slider_in, slider_sreg[1]};
    end
	//forward synchronized signal
	always_comb slider_out = slider_sreg[0];

endmodule
