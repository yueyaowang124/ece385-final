//=============================================================================
// piano_tiles_top.sv  —  钢琴块游戏顶层
//
// 连接：
//   piano_tiles_game  → 游戏逻辑
//   piano_tiles_display → VGA渲染
//   DDS IP 音效控制（通过外部AXI写，或直接连phase_inc）
//
// 外部接口（连接到 Block Design）：
//   clk, reset_n, vsync      来自VGA控制器
//   DrawX, DrawY             来自VGA扫描计数器
//   key_asdf[3:0]            来自AXI GPIO（按键状态）
//   game_start               来自AXI GPIO（按钮触发）
//   R, G, B                  输出到VGA
//   dds_phase_out[31:0]      输出到DDS IP phase_inc寄存器（经AXI写）
//   dds_enable_out           输出到DDS enable
//=============================================================================
module piano_tiles_top (
    input  logic        clk,
    input  logic        reset_n,
    input  logic        vsync,
    input  logic [9:0]  DrawX,
    input  logic [9:0]  DrawY,

    // 按键输入（来自AXI GPIO，bit0=A, bit1=S, bit2=D, bit3=F）
    input  logic [3:0]  key_asdf,
    input  logic        game_start,

    // VGA输出
    output logic [7:0]  R,
    output logic [7:0]  G,
    output logic [7:0]  B,

    // DDS音效控制（接到DDS IP）
    output logic [31:0] dds_phase_out,
    output logic        dds_enable_out,

    // 游戏状态输出（可选，用于调试或额外GPIO）
    output logic        game_over,
    output logic        game_win
);

    // 游戏逻辑输出
    logic [9:0]         tile_y_top [0:3];
    logic [9:0]         tile_y_bot [0:3];
    logic [1:0]         tile_state [0:3];
    logic               tile_valid [0:3];
    logic signed [3:0]  score;
    logic [31:0]        dds_ph0, dds_ph1;
    logic               dds_en;

    piano_tiles_game game_inst (
        .clk        (clk),
        .reset_n    (reset_n),
        .game_start (game_start),
        .vsync      (vsync),
        .key_a      (key_asdf[0]),
        .key_s      (key_asdf[1]),
        .key_d      (key_asdf[2]),
        .key_f      (key_asdf[3]),
        .tile_y_top (tile_y_top),
        .tile_y_bot (tile_y_bot),
        .tile_state (tile_state),
        .tile_valid (tile_valid),
        .score      (score),
        .game_over  (game_over),
        .game_win   (game_win),
        .dds_phase_0(dds_ph0),
        .dds_phase_1(dds_ph1),
        .dds_enable (dds_en)
    );

    piano_tiles_display disp_inst (
        .DrawX      (DrawX),
        .DrawY      (DrawY),
        .tile_y_top (tile_y_top),
        .tile_y_bot (tile_y_bot),
        .tile_state (tile_state),
        .tile_valid (tile_valid),
        .score      (score),
        .game_over  (game_over),
        .game_win   (game_win),
        .R          (R),
        .G          (G),
        .B          (B)
    );

    // DDS音效：只用ch0（正确音/蜂鸣），ch1备用
    assign dds_phase_out = dds_ph0;
    assign dds_enable_out = dds_en;

endmodule