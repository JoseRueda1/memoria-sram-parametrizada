// ============================================================
// Decodificador: activa SOLO una de sus 2^N salidas.
// a = 0 -> y[0] = 1,  a = 1 -> y[1] = 1, y asi sucesivamente.
// Se usa uno para filas y otro para columnas.
// ============================================================
module decoder #(
    parameter int N = 4
) (
    input  wire [N-1:0]      a,
    output wire [(1<<N)-1:0] y
);
    for (genvar i = 0; i < (1 << N); i++) begin : g_out
        assign y[i] = (a == i);
    end
endmodule
