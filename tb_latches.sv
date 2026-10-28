// ============================================================
// Pruebas de los bloques pequenos del video, paso a paso:
//   1. latch AND-OR (set / reset)
//   2. latch con WR enable (gated latch)
//   3. registro de 8 bits
// Imprime: Errores: N
// ============================================================
`timescale 1ns/1ps

module tb_latches;
    int errores = 0;

    task automatic chk(input string que, input logic got, input logic exp);
        if (got !== exp) begin
            errores++;
            $display("ERROR %s: leido=%b esperado=%b", que, got, exp);
        end
    endtask

    // ---- 1. latch AND-OR ----
    reg  set = 0, rst = 0;
    wire q1;
    sr_latch_andor u1 (.set(set), .reset(rst), .q(q1));

    // ---- 2. gated latch ----
    reg  d = 0, we = 0;
    wire q2;
    gated_latch u2 (.d(d), .we(we), .q(q2));

    // ---- 3. registro de 8 bits ----
    reg  [7:0] dr = 0;
    reg        wer = 0;
    wire [7:0] qr;
    register_n #(.W(8)) u3 (.d(dr), .we(wer), .q(qr));

    initial begin
        // 1. AND-OR: reset inicial, set, mantener, reset, mantener
        rst = 1; #1; chk("sr: reset inicial", q1, 0);
        rst = 0; #1; chk("sr: se mantiene en 0", q1, 0);
        set = 1; #1; chk("sr: set -> 1", q1, 1);
        set = 0; #1; chk("sr: recuerda el 1", q1, 1);
        rst = 1; #1; chk("sr: reset -> 0", q1, 0);
        rst = 0; #1; chk("sr: recuerda el 0", q1, 0);

        // 2. gated latch: con we=0 ignora d; con we=1 guarda d
        we = 1; d = 1; #1; chk("gl: escribe 1", q2, 1);
        we = 0; #1;       chk("gl: we=0 mantiene 1", q2, 1);
        d = 0; #1;        chk("gl: d cambia y we=0, sigue 1", q2, 1);
        we = 1; #1;       chk("gl: sobrescribe con 0", q2, 0);
        we = 0; d = 1; #1; chk("gl: we=0 mantiene 0", q2, 0);

        // 3. registro de 8 bits
        dr = 8'hA5; wer = 1; #1; wer = 0; #1;
        if (qr !== 8'hA5) begin errores++; $display("ERROR reg: %h", qr); end
        dr = 8'h3C; #1;
        if (qr !== 8'hA5) begin errores++; $display("ERROR reg mantiene: %h", qr); end
        wer = 1; #1; wer = 0; #1;
        if (qr !== 8'h3C) begin errores++; $display("ERROR reg sobrescribe: %h", qr); end

        $display("Errores: %0d  (latch AND-OR, gated latch, registro de 8 bits)", errores);
        $finish;
    end
endmodule
