// ============================================================
// Paso 1 del video: latch AND-OR (set / reset).
// Q = SET OR (Q AND NOT RESET)
//  - set = 1   -> Q pasa a 1 y se queda en 1 aunque set vuelva a 0
//  - reset = 1 -> la compuerta AND bloquea el lazo y Q pasa a 0
// La salida se conecta de vuelta a la entrada (lazo de realimentacion):
// eso es lo que "recuerda" el bit.
// Con set = reset = 1 no tiene sentido (en este modelo gana set).
// ============================================================
module sr_latch_andor (
    input  wire set,
    input  wire reset,
    output wire q
);
    assign q = set | (q & ~reset);
endmodule
