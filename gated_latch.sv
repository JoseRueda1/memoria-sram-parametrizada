// ============================================================
// Paso 2 del video: latch con entrada de escritura (WR enable).
// Un solo dato (d) y una senal we:
//   we = 0 -> se ignora d, el bit guardado no cambia
//   we = 1 -> el latch guarda el valor de d
// Se construye con dos compuertas AND delante del latch AND-OR:
//   set   = we AND d
//   reset = we AND (NOT d)
// Asi set y reset nunca estan activos al mismo tiempo.
// ============================================================
module gated_latch (
    input  wire d,
    input  wire we,
    output wire q
);
    wire s = we &  d;
    wire r = we & ~d;
    sr_latch_andor u_sr (.set(s), .reset(r), .q(q));
endmodule
