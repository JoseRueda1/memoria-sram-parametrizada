// ============================================================
// Paso 3 del video: registro de W bits.
// W latches con la entrada we unida: una sola senal escribe todos.
// Es el "registro" que se explica antes de pasar a la matriz.
// (La RAM de este repo usa la matriz de latches, no este registro.)
// ============================================================
module register_n #(
    parameter int W = 8
) (
    input  wire [W-1:0] d,
    input  wire         we,
    output wire [W-1:0] q
);
    for (genvar i = 0; i < W; i++) begin : g_bit
        gated_latch u_latch (.d(d[i]), .we(we), .q(q[i]));
    end
endmodule
