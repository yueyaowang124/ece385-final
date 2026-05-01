//=============================================================================
// dds_oscillator_v2.sv  -  Multi-waveform DDS (Square/Triangle/Saw/Sine/Organ/Vibrato)
//
// wave_sel (3 bits):
//   0 = Square      (original behavior)
//   1 = Triangle
//   2 = Sawtooth
//   3 = Sine        (256-entry ROM)
//   4 = Organ       (sine + half-amplitude 2nd harmonic)
//   5 = Vibrato     (sine with ~5 Hz tremolo AM)
//   6,7 = reserved (output silence)
//
// Replaces the old dds.sv / dds_oscillator from Week 1.
// Key difference from original:
//   - new input:  wave_sel[2:0]
//   - audio_out is signed 16-bit, centered at 0 (unchanged)
//   - when phase_increment == 0, audio_out = 0 (silence, unchanged)
//=============================================================================
module dds_oscillator (
    input  logic        clk,
    input  logic        reset_n,          // synchronous, active-low
    input  logic [31:0] phase_increment,
    input  logic [2:0]  wave_sel,
    output logic [15:0] audio_out         // signed 16-bit (interpreted as signed)
);
    logic [31:0] phase;
    always_ff @(posedge clk) begin
        if (!reset_n) phase <= 32'd0;
        else          phase <= phase + phase_increment;
    end

    logic signed [15:0] sine_rom [0:255];
    initial begin
      sine_rom[0] = 0;        sine_rom[1] = 804;      sine_rom[2] = 1608;     sine_rom[3] = 2410;
      sine_rom[4] = 3212;     sine_rom[5] = 4011;     sine_rom[6] = 4808;     sine_rom[7] = 5602;
      sine_rom[8] = 6393;     sine_rom[9] = 7179;     sine_rom[10] = 7962;    sine_rom[11] = 8739;
      sine_rom[12] = 9512;    sine_rom[13] = 10278;   sine_rom[14] = 11039;   sine_rom[15] = 11793;
      sine_rom[16] = 12539;   sine_rom[17] = 13279;   sine_rom[18] = 14010;   sine_rom[19] = 14732;
      sine_rom[20] = 15446;   sine_rom[21] = 16151;   sine_rom[22] = 16846;   sine_rom[23] = 17530;
      sine_rom[24] = 18204;   sine_rom[25] = 18868;   sine_rom[26] = 19519;   sine_rom[27] = 20159;
      sine_rom[28] = 20787;   sine_rom[29] = 21403;   sine_rom[30] = 22005;   sine_rom[31] = 22594;
      sine_rom[32] = 23170;   sine_rom[33] = 23731;   sine_rom[34] = 24279;   sine_rom[35] = 24811;
      sine_rom[36] = 25329;   sine_rom[37] = 25832;   sine_rom[38] = 26319;   sine_rom[39] = 26790;
      sine_rom[40] = 27245;   sine_rom[41] = 27683;   sine_rom[42] = 28105;   sine_rom[43] = 28510;
      sine_rom[44] = 28898;   sine_rom[45] = 29268;   sine_rom[46] = 29621;   sine_rom[47] = 29956;
      sine_rom[48] = 30273;   sine_rom[49] = 30571;   sine_rom[50] = 30852;   sine_rom[51] = 31113;
      sine_rom[52] = 31356;   sine_rom[53] = 31580;   sine_rom[54] = 31785;   sine_rom[55] = 31971;
      sine_rom[56] = 32137;   sine_rom[57] = 32285;   sine_rom[58] = 32412;   sine_rom[59] = 32521;
      sine_rom[60] = 32609;   sine_rom[61] = 32678;   sine_rom[62] = 32728;   sine_rom[63] = 32757;
      sine_rom[64] = 32767;   sine_rom[65] = 32757;   sine_rom[66] = 32728;   sine_rom[67] = 32678;
      sine_rom[68] = 32609;   sine_rom[69] = 32521;   sine_rom[70] = 32412;   sine_rom[71] = 32285;
      sine_rom[72] = 32137;   sine_rom[73] = 31971;   sine_rom[74] = 31785;   sine_rom[75] = 31580;
      sine_rom[76] = 31356;   sine_rom[77] = 31113;   sine_rom[78] = 30852;   sine_rom[79] = 30571;
      sine_rom[80] = 30273;   sine_rom[81] = 29956;   sine_rom[82] = 29621;   sine_rom[83] = 29268;
      sine_rom[84] = 28898;   sine_rom[85] = 28510;   sine_rom[86] = 28105;   sine_rom[87] = 27683;
      sine_rom[88] = 27245;   sine_rom[89] = 26790;   sine_rom[90] = 26319;   sine_rom[91] = 25832;
      sine_rom[92] = 25329;   sine_rom[93] = 24811;   sine_rom[94] = 24279;   sine_rom[95] = 23731;
      sine_rom[96] = 23170;   sine_rom[97] = 22594;   sine_rom[98] = 22005;   sine_rom[99] = 21403;
      sine_rom[100] = 20787;  sine_rom[101] = 20159;  sine_rom[102] = 19519;  sine_rom[103] = 18868;
      sine_rom[104] = 18204;  sine_rom[105] = 17530;  sine_rom[106] = 16846;  sine_rom[107] = 16151;
      sine_rom[108] = 15446;  sine_rom[109] = 14732;  sine_rom[110] = 14010;  sine_rom[111] = 13279;
      sine_rom[112] = 12539;  sine_rom[113] = 11793;  sine_rom[114] = 11039;  sine_rom[115] = 10278;
      sine_rom[116] = 9512;   sine_rom[117] = 8739;   sine_rom[118] = 7962;   sine_rom[119] = 7179;
      sine_rom[120] = 6393;   sine_rom[121] = 5602;   sine_rom[122] = 4808;   sine_rom[123] = 4011;
      sine_rom[124] = 3212;   sine_rom[125] = 2410;   sine_rom[126] = 1608;   sine_rom[127] = 804;
      sine_rom[128] = 0;      sine_rom[129] = -804;   sine_rom[130] = -1608;  sine_rom[131] = -2410;
      sine_rom[132] = -3212;  sine_rom[133] = -4011;  sine_rom[134] = -4808;  sine_rom[135] = -5602;
      sine_rom[136] = -6393;  sine_rom[137] = -7179;  sine_rom[138] = -7962;  sine_rom[139] = -8739;
      sine_rom[140] = -9512;  sine_rom[141] = -10278; sine_rom[142] = -11039; sine_rom[143] = -11793;
      sine_rom[144] = -12539; sine_rom[145] = -13279; sine_rom[146] = -14010; sine_rom[147] = -14732;
      sine_rom[148] = -15446; sine_rom[149] = -16151; sine_rom[150] = -16846; sine_rom[151] = -17530;
      sine_rom[152] = -18204; sine_rom[153] = -18868; sine_rom[154] = -19519; sine_rom[155] = -20159;
      sine_rom[156] = -20787; sine_rom[157] = -21403; sine_rom[158] = -22005; sine_rom[159] = -22594;
      sine_rom[160] = -23170; sine_rom[161] = -23731; sine_rom[162] = -24279; sine_rom[163] = -24811;
      sine_rom[164] = -25329; sine_rom[165] = -25832; sine_rom[166] = -26319; sine_rom[167] = -26790;
      sine_rom[168] = -27245; sine_rom[169] = -27683; sine_rom[170] = -28105; sine_rom[171] = -28510;
      sine_rom[172] = -28898; sine_rom[173] = -29268; sine_rom[174] = -29621; sine_rom[175] = -29956;
      sine_rom[176] = -30273; sine_rom[177] = -30571; sine_rom[178] = -30852; sine_rom[179] = -31113;
      sine_rom[180] = -31356; sine_rom[181] = -31580; sine_rom[182] = -31785; sine_rom[183] = -31971;
      sine_rom[184] = -32137; sine_rom[185] = -32285; sine_rom[186] = -32412; sine_rom[187] = -32521;
      sine_rom[188] = -32609; sine_rom[189] = -32678; sine_rom[190] = -32728; sine_rom[191] = -32757;
      sine_rom[192] = -32767; sine_rom[193] = -32757; sine_rom[194] = -32728; sine_rom[195] = -32678;
      sine_rom[196] = -32609; sine_rom[197] = -32521; sine_rom[198] = -32412; sine_rom[199] = -32285;
      sine_rom[200] = -32137; sine_rom[201] = -31971; sine_rom[202] = -31785; sine_rom[203] = -31580;
      sine_rom[204] = -31356; sine_rom[205] = -31113; sine_rom[206] = -30852; sine_rom[207] = -30571;
      sine_rom[208] = -30273; sine_rom[209] = -29956; sine_rom[210] = -29621; sine_rom[211] = -29268;
      sine_rom[212] = -28898; sine_rom[213] = -28510; sine_rom[214] = -28105; sine_rom[215] = -27683;
      sine_rom[216] = -27245; sine_rom[217] = -26790; sine_rom[218] = -26319; sine_rom[219] = -25832;
      sine_rom[220] = -25329; sine_rom[221] = -24811; sine_rom[222] = -24279; sine_rom[223] = -23731;
      sine_rom[224] = -23170; sine_rom[225] = -22594; sine_rom[226] = -22005; sine_rom[227] = -21403;
      sine_rom[228] = -20787; sine_rom[229] = -20159; sine_rom[230] = -19519; sine_rom[231] = -18868;
      sine_rom[232] = -18204; sine_rom[233] = -17530; sine_rom[234] = -16846; sine_rom[235] = -16151;
      sine_rom[236] = -15446; sine_rom[237] = -14732; sine_rom[238] = -14010; sine_rom[239] = -13279;
      sine_rom[240] = -12539; sine_rom[241] = -11793; sine_rom[242] = -11039; sine_rom[243] = -10278;
      sine_rom[244] = -9512;  sine_rom[245] = -8739;  sine_rom[246] = -7962;  sine_rom[247] = -7179;
      sine_rom[248] = -6393;  sine_rom[249] = -5602;  sine_rom[250] = -4808;  sine_rom[251] = -4011;
      sine_rom[252] = -3212;  sine_rom[253] = -2410;  sine_rom[254] = -1608;  sine_rom[255] = -804;
    end

    logic [31:0] lfo_phase;
    always_ff @(posedge clk) begin
        if (!reset_n) lfo_phase <= 32'd0;
        else          lfo_phase <= lfo_phase + 32'd215;
    end
    logic signed [15:0] lfo_sine;
    assign lfo_sine = sine_rom[lfo_phase[31:24]];

    logic signed [15:0] sq_val, tri_val, saw_val, sine_val, organ_val, vib_val;

    // Square: top bit of phase -> ¡Àmax
    assign sq_val = phase[31] ? 16'sh7FFF : 16'sh8000;

    // Triangle: linearly ramp up, then ramp down
    //   phase[31]=0: out = {1'b0, phase[30:15]} - 32768   (ramps -32768 ¡ú -1)
    //   phase[31]=1: out = 32767 - {1'b0, phase[30:15]}   (ramps 32767 ¡ú 0)
    // Actually want full ¡À32767 amplitude: use 16-bit top and double it
    always_comb begin
        logic signed [16:0] t;
        if (phase[31] == 1'b0) begin
            // up-slope: phase[30:15] goes 0..65535, want -32768..+32767
            t = $signed({1'b0, phase[30:15]}) - 17'sd32768;
        end else begin
            // down-slope: phase[30:15] goes 0..65535, want +32767..-32768
            t = 17'sd32767 - $signed({1'b0, phase[30:15]});
        end
        // saturate (no-op really, t fits in 16 bits)
        tri_val = t[15:0];
    end

    // Sawtooth: phase[31:16] as unsigned -> flip MSB -> signed
    assign saw_val = {~phase[31], phase[30:16]};

    // Sine: look up ROM by top 8 bits of phase
    assign sine_val = sine_rom[phase[31:24]];

    // Organ = sine + (sine at 2x freq) / 2
    //   2x freq = shift phase left by 1 -> use phase[30:23]
    logic signed [15:0] sine2_val;
    assign sine2_val = sine_rom[{phase[30:24], 1'b0}];
    // clip-safe: /2 + /2 guarantees no overflow
    assign organ_val = (sine_val >>> 1) + (sine2_val >>> 2);

    // Vibrato (implemented as Tremolo/AM):
    //   scale sine_val by (3/4 + lfo_sine/4)  ¡ú amplitude 0.5..1.0
    // cheap approximation:  sine * 3/4  +  sine * lfo / 32768 / 4
    logic signed [31:0] vib_prod;
    assign vib_prod = sine_val * lfo_sine;   // 32-bit signed
    assign vib_val  = (sine_val >>> 1) + (sine_val >>> 2) + vib_prod[30:17];
    //    ¡Ö 0.75*sine + sine*lfo/(32768*4)  -> gentle AM
    logic signed [15:0] wave_out;
    always_comb begin
        unique case (wave_sel)
            3'd0:    wave_out = sq_val;
            3'd1:    wave_out = tri_val;
            3'd2:    wave_out = saw_val;
            3'd3:    wave_out = sine_val;
            3'd4:    wave_out = organ_val;
            3'd5:    wave_out = vib_val;
            default: wave_out = 16'sd0;
        endcase
    end

    always_comb begin
        if (phase_increment == 32'd0)
            audio_out = 16'h0000;
        else
            audio_out = wave_out;
    end

endmodule
