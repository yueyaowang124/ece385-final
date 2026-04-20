//=============================================================================
// audio_pdm_tb.sv  -  Testbench for audio_pdm (PDM modulator)
//
// What we verify:
//   1. Reset brings accumulator/output to known state
//   2. audio_in = 16'h0000 (signed 0)     -> pdm_out has ~50% duty cycle (silence)
//   3. audio_in = 16'h7FFF (signed +max)  -> pdm_out is mostly 1
//   4. audio_in = 16'h8000 (signed -max)  -> pdm_out is mostly 0
//   5. A sine-approximated input produces a smoothly-varying duty cycle
//
// Duty cycle is measured by counting 1s over a window of N clock cycles.
//=============================================================================
`timescale 1ns/1ps

module audio_pdm_tb;

    logic        clk;
    logic        reset_n;
    logic [15:0] audio_in;
    logic        pdm_out;

    // DUT
    audio_pdm dut (
        .clk     (clk),
        .reset_n (reset_n),
        .audio_in(audio_in),
        .pdm_out (pdm_out)
    );

    // 100 MHz clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Duty-cycle measurement task
    task measure_duty(input [15:0] sample, input int N);
        int ones;
        begin
            audio_in = sample;
            // settle a bit
            repeat (100) @(posedge clk);
            ones = 0;
            repeat (N) begin
                @(posedge clk);
                if (pdm_out) ones = ones + 1;
            end
            $display("  audio_in=0x%h -> %0d/%0d ones = %0d%% duty",
                     sample, ones, N, (ones*100)/N);
        end
    endtask

    initial begin
        $display("=== PDM Testbench Start ===");

        // ---------- Reset ----------
        reset_n  = 0;
        audio_in = 16'h0000;
        #100;
        reset_n = 1;
        #20;

        // ---------- Test 1: silence (signed 0) -> ~50% duty ----------
        $display("--- Test 1: signed 0 (silence) ---");
        measure_duty(16'h0000, 10000);

        // ---------- Test 2: +max -> near 100% duty ----------
        $display("--- Test 2: +max (0x7FFF) ---");
        measure_duty(16'h7FFF, 10000);

        // ---------- Test 3: -max -> near 0% duty ----------
        $display("--- Test 3: -max (0x8000) ---");
        measure_duty(16'h8000, 10000);

        // ---------- Test 4: +1/2 scale -> ~75% duty ----------
        $display("--- Test 4: +half (0x4000) ---");
        measure_duty(16'h4000, 10000);

        // ---------- Test 5: -1/2 scale -> ~25% duty ----------
        $display("--- Test 5: -half (0xC000) ---");
        measure_duty(16'hC000, 10000);

        // ---------- Test 6: ramp to visualize noise-shaping ----------
        $display("--- Test 6: sweeping ramp (watch waveform) ---");
        for (int i = 0; i < 16; i++) begin
            logic signed [15:0] v;
            v = (i - 8) * 16'sh1000;  // -32768 ... +28672
            measure_duty(v, 2000);
        end

        $display("=== PDM Testbench Done ===");
        $finish;
    end

endmodule
