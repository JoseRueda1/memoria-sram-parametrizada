// ============================================================
// TOP: memoria RAM estatica (SRAM) parametrizada, segun el video
// "How Transistors Remember Data" (Core Dumped).
//
//   ADDR_W : ancho del bus de direcciones  -> 2^ADDR_W posiciones
//   DATA_W : ancho de cada dato (8 = un byte, como en el video)
//
// Por cada bit del dato hay una matriz de latches; todas las matrices
// comparten la misma direccion, we y re. Se selecciona la misma celda
// en cada matriz y asi se lee o escribe la palabra completa.
// Con ADDR_W = 8 hay dos decodificadores de 16 salidas (256 posiciones),
// igual que el ejemplo del video.
//
// Es asincrona (sin reloj), como en el video. Para escribir: poner
// direccion y dato, y luego subir we. Para leer: poner direccion y
// subir re. we y re no deben estar activas a la vez; si lo estan, gana
// la escritura (re se ignora).
// data es un bus bidireccional: la RAM lo maneja solo al leer.
// ============================================================
module ram_top #(
    parameter int ADDR_W = 8,
    parameter int DATA_W = 8
) (
    input  wire [ADDR_W-1:0] addr,
    input  wire              we,
    input  wire              re,
    inout  wire [DATA_W-1:0] data
);
    localparam int ROW_BITS = ADDR_W / 2;
    localparam int COL_BITS = ADDR_W - ROW_BITS;

    initial begin
        if (ADDR_W < 2) $error("ram_top: ADDR_W debe ser >= 2");
        if (DATA_W < 1) $error("ram_top: DATA_W debe ser >= 1");
    end

    wire [ROW_BITS-1:0] row_addr = addr[ADDR_W-1:COL_BITS];
    wire [COL_BITS-1:0] col_addr = addr[COL_BITS-1:0];
    wire                re_int   = re & ~we;   // la escritura tiene prioridad

    for (genvar b = 0; b < DATA_W; b++) begin : g_bit
        latch_matrix #(.ROW_BITS(ROW_BITS), .COL_BITS(COL_BITS)) u_matrix (
            .row_addr(row_addr),
            .col_addr(col_addr),
            .we(we),
            .re(re_int),
            .data(data[b])
        );
    end
endmodule
