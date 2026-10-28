// ============================================================
// Celda de la matriz: un latch + las compuertas AND que dejan pasar
// las senales de lectura y escritura SOLO si la celda esta
// seleccionada (fila y columna activas a la vez).
//
//   sel = row_sel AND col_sel
//   wr  = sel AND we        -> escribe lo que haya en la linea data
//   rd  = sel AND re        -> la celda maneja la linea data
//
// La linea data es un solo cable que sirve de entrada y de salida
// (bidireccional): al leer, un buffer de tres estados la conecta a la
// salida del latch; si no, queda en alta impedancia (z).
// ============================================================
module mem_cell (
    input  wire row_sel,
    input  wire col_sel,
    input  wire we,
    input  wire re,
    inout  wire data
);
    wire sel = row_sel & col_sel;
    wire wr  = sel & we;
    wire rd  = sel & re;
    wire q;

    gated_latch u_latch (.d(data), .we(wr), .q(q));
    assign data = rd ? q : 1'bz;
endmodule
