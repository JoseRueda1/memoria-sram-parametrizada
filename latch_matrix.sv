// ============================================================
// Matriz de latches de 1 bit (en el video: 4 x 4 = 16 latches).
// Hay 2^ROW_BITS filas y 2^COL_BITS columnas. Cada latch tiene una
// direccion unica: {fila, columna}. Un decodificador activa una fila y
// otro una columna; solo la celda donde se cruzan responde.
// Todas las celdas comparten la misma linea data, we y re.
// ============================================================
module latch_matrix #(
    parameter int ROW_BITS = 2,
    parameter int COL_BITS = 2
) (
    input  wire [ROW_BITS-1:0] row_addr,
    input  wire [COL_BITS-1:0] col_addr,
    input  wire                we,
    input  wire                re,
    inout  wire                data
);
    localparam int ROWS = 1 << ROW_BITS;
    localparam int COLS = 1 << COL_BITS;

    wire [ROWS-1:0] row_sel;
    wire [COLS-1:0] col_sel;

    decoder #(.N(ROW_BITS)) u_row_dec (.a(row_addr), .y(row_sel));
    decoder #(.N(COL_BITS)) u_col_dec (.a(col_addr), .y(col_sel));

    for (genvar r = 0; r < ROWS; r++) begin : g_row
        for (genvar c = 0; c < COLS; c++) begin : g_col
            mem_cell u_cell (
                .row_sel(row_sel[r]),
                .col_sel(col_sel[c]),
                .we(we),
                .re(re),
                .data(data)
            );
        end
    end
endmodule
