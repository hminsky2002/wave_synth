module wave_synth (
    // Clock
    input  logic        CLOCK_50,
    
    input  logic [3:0]  KEY,
    input  logic [9:0]  SW,
    
    output logic        FPGA_I2C_SCLK,
    inout               FPGA_I2C_SDAT,
    output logic        AUD_XCK,
    input  logic        AUD_DACLRCK,
    input  logic        AUD_ADCLRCK,
    input  logic        AUD_BCLK,
    input  logic        AUD_ADCDAT,
    output logic        AUD_DACDAT
);

    logic reset;
    assign reset = ~KEY[0];  // KEY is active-low on DE1-SoC

    // Audio signals between driver and your DSP logic
    logic [23:0] dac_left, dac_right;
    logic [23:0] adc_left, adc_right;
    logic        advance;

    audio_driver audio (
        .CLOCK_50      (CLOCK_50),
        .reset         (reset),
        .dac_left      (dac_left),
        .dac_right     (dac_right),
        .adc_left      (adc_left),
        .adc_right     (adc_right),
        .advance       (advance),
        .FPGA_I2C_SCLK (FPGA_I2C_SCLK),
        .FPGA_I2C_SDAT (FPGA_I2C_SDAT),
        .AUD_XCK       (AUD_XCK),
        .AUD_DACLRCK   (AUD_DACLRCK),
        .AUD_ADCLRCK   (AUD_ADCLRCK),
        .AUD_BCLK      (AUD_BCLK),
        .AUD_ADCDAT    (AUD_ADCDAT),
        .AUD_DACDAT    (AUD_DACDAT)
    );

	
    logic [10:0] e_counter;
	logic [10:0] g_counter;
    logic [10:0] c_counter;

	logic [23:0] square_out;

    logic [23:0] triangle_wave;
    logic [23:0] triangle_out;
    logic [8:0]  tstep;

    triangle_wave twave (
        .CLOCK_50     (CLOCK_50),
        .step         (tstep),
        .triangle_wave(triangle_out)
    );

	always_ff @(posedge CLOCK_50) begin
		 if (reset) begin
			  e_counter <= 0;
			  g_counter <= 0;
			  c_counter <= 0;
		 end else if (advance) begin
			  if (e_counter >= 10'd292)
					e_counter <= 0;
			  else
					e_counter <= e_counter + 1;
			  if (g_counter >= 10'd244)
					g_counter <= 0;
			  else
					g_counter <= g_counter + 1;
			  if (c_counter >= 10'd368)
					c_counter <= 0;
			  else
					c_counter <= c_counter + 1;
		 end
	end

	logic [23:0] e_wave, g_wave, c_wave;
	assign e_wave = (e_counter < 11'd144)  ? 24'h3FFFFF : 24'hC00000;
	assign g_wave = (g_counter < 11'd122)  ? 24'h3FFFFF : 24'hC00000;
	assign c_wave = (c_counter < 11'd184)  ? 24'h3FFFFF : 24'hC00000;

	always_ff @(posedge CLOCK_50) begin
		if (reset)
			tstep <= 9'd292;
		else begin
			if (!KEY[2]) tstep <= tstep - 1;
			if (!KEY[3]) tstep <= tstep + 1;
		end
	end

	logic [23:0] mixed;
	always_comb begin
		 mixed = 24'd0;
		 if (!KEY[1]) mixed = mixed + triangle_wave;
	end

	assign dac_left  = mixed;
	assign dac_right = mixed;
	
endmodule