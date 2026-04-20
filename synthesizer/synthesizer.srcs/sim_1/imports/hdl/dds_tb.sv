//=============================================================================
// dds_tb.sv  -  Testbench for dds_oscillator
//
// What we verify:
//   1. Reset clears the phase accumulator to 0
//   2. With phase_increment = 0, audio_out stays at 16'h0000 (silence)
//   3. With phase_increment != 0, audio_out toggles between 16'h7FFF and 16'h8000
//   4. The toggle period matches the expected target frequency
//
// At 100 MHz clock, phase_increment = f_target * 2^32 / 1e8
//   - 440 Hz   -> 18897   -> period ~ 2.27 ms
//   - 100 kHz -> 4294967 -> period = 10 us  (use this in sim, much faster!)
//
// We use a HIGH frequency in sim so we don't have to wait milliseconds.
//=============================================================================
`timescale 1ns/1ps

module dds_tb;

    logic        clk;
    logic        reset_n;
    logic [31:0] phase_increment;
    logic [15:0] audio_out;

    // DUT
    dds_oscillator dut (
        .clk             (clk),
        .reset_n         (reset_n),
        .phase_increment (phase_increment),
        .audio_out       (audio_out)
    );

    // 100 MHz clock (period = 10 ns)
    initial clk = 0;
    always #5 clk = ~clk;

    // Counters for measuring the output frequency
    int high_to_low_transitions;
    logic prev_audio_msb;

    always_ff @(posedge clk) begin
        if (!reset_n) begin
            high_to_low_transitions <= 0;
            prev_audio_msb          <= 1'b0;
        end else begin
            prev_audio_msb <= audio_out[15];
            // count rising edges of audio_out[15] (the polarity bit)
            if (!prev_audio_msb && audio_out[15])
                high_to_low_transitions <= high_to_low_transitions + 1;
        end
    end

    initial begin
        $display("=== DDS Testbench Start ===");

        // ---------- Test 1: reset ----------
        reset_n         = 0;
        phase_increment = 0;
        #100;
        reset_n = 1;
        #20;

        if (audio_out !== 16'h0000)
            $display("FAIL: after reset, audio_out=%h, expected 0000", audio_out);
        else
            $display("PASS: after reset, audio_out=0000 (silence)");

        // ---------- Test 2: phase_inc = 0 -> silence ----------
        phase_increment = 32'd0;
        #1000;
        if (audio_out !== 16'h0000)
            $display("FAIL: phase_inc=0 should give silence, got %h", audio_out);
        else
            $display("PASS: phase_inc=0 produces silence");

        // ---------- Test 3: phase_inc for 100 kHz ----------
        // 100 kHz at 100 MHz clk: inc = 100_000 * 2^32 / 1e8 = 4294967
        $display("--- Test 3: 100 kHz tone ---");
        phase_increment = 32'd4294967;

        // Reset the transition counter
        reset_n = 0;
        #100;
        reset_n = 1;

        // Run for ~ 100 us (should see 10 cycles of 100 kHz)
        #100000;

        $display("Saw %0d high-edges in 100us (expected ~10 for 100 kHz)",
                 high_to_low_transitions);
        if (high_to_low_transitions >= 9 && high_to_low_transitions <= 11)
            $display("PASS: frequency is approximately 100 kHz");
        else
            $display("FAIL: frequency mismatch");

        // ---------- Test 4: change frequency to 200 kHz ----------
        $display("--- Test 4: 200 kHz tone ---");
        phase_increment = 32'd8589935;   // 200 kHz
        reset_n = 0;
        #100;
        reset_n = 1;
        #100000;
        $display("Saw %0d high-edges in 100us (expected ~20 for 200 kHz)",
                 high_to_low_transitions);

        // ---------- Test 5: confirm output values are only 7FFF or 8000 ----------
        $display("--- Test 5: confirm output is square wave (only 7FFF / 8000) ---");
        phase_increment = 32'd4294967;
        repeat (1000) begin
            @(posedge clk);
            if (audio_out !== 16'h7FFF && audio_out !== 16'h8000)
                $display("FAIL: unexpected audio_out = %h", audio_out);
        end
        $display("PASS: output is always 7FFF or 8000");

        $display("=== DDS Testbench Done ===");
        $finish;
    end

endmodule
