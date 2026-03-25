module triangle_wave (
    input  logic        CLOCK_50,
    input  logic [8:0]  step,
    output logic [23:0] triangle_wave
);

    logic        rise;
    logic [8:0]  counter;

    always_ff @(posedge CLOCK_50) begin
        if (counter == step) begin
            counter <= 0;

            if (triangle_wave == 0)
                rise <= 1;
            if (triangle_wave == 24'h3FFFFF)
                rise <= 0;

            if (rise)
                triangle_wave <= triangle_wave + 1;
            else
                triangle_wave <= triangle_wave - 1;
        end else begin
            counter <= counter + 1;
        end
    end

endmodule
