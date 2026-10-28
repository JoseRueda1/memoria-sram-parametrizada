// ============================================================
// Testbench autoverificable de ram_top.
// Prueba 4 configuraciones de parametros (para demostrar que el top
// es parametrizable) y compara cada lectura contra un modelo de
// referencia (arreglo de SystemVerilog).
//
// Pruebas por configuracion:
//   1. Con we = re = 0 el bus data debe estar en alta impedancia (z).
//   2. Escribir TODAS las posiciones y leerlas todas.
//   3. Sobrescribir posiciones al azar; despues de cada escritura leer
//      la celda escrita y otra celda al azar (no debe cambiar).
//   4. Escribir todo ceros y todo unos en una posicion.
//   5. we = re = 1 a la vez: gana la escritura y la RAM no maneja data.
//   6. Lectura final de toda la memoria contra el modelo.
// Imprime: Errores: N
// ============================================================
`timescale 1ns/1ps

module ram_checker #(
    parameter int ADDR_W = 8,
    parameter int DATA_W = 8,
    parameter int N_RAND = 2000,
    parameter string NAME = "cfg"
) (
    output int errores,
    output bit done
);
    localparam int DEPTH = 1 << ADDR_W;

    reg  [ADDR_W-1:0] addr = '0;
    reg               we   = 0;
    reg               re   = 0;
    reg  [DATA_W-1:0] wdata = '0;
    wire [DATA_W-1:0] data;

    // El banco de pruebas maneja el bus solo al escribir
    assign data = we ? wdata : {DATA_W{1'bz}};

    ram_top #(.ADDR_W(ADDR_W), .DATA_W(DATA_W)) dut (
        .addr(addr), .we(we), .re(re), .data(data)
    );

    reg [DATA_W-1:0] ref_mem [0:DEPTH-1];
    reg              known   [0:DEPTH-1];

    int n_err = 0;
    assign errores = n_err;
    initial done = 0;

    task automatic escribir(input [ADDR_W-1:0] a, input [DATA_W-1:0] d);
        addr = a; wdata = d; #1;
        we = 1; #5;
        we = 0; #1;
        ref_mem[a] = d; known[a] = 1;
    endtask

    task automatic leer_y_comparar(input [ADDR_W-1:0] a, input string que);
        reg [DATA_W-1:0] got;
        addr = a; re = 1; #2;
        got = data;
        re = 0; #1;
        if (got !== ref_mem[a]) begin
            n_err++;
            if (n_err <= 10)
                $display("[%s] ERROR (%s) addr=%0h esperado=%0h leido=%0h",
                         NAME, que, a, ref_mem[a], got);
        end
    endtask

    initial begin
        for (int i = 0; i < DEPTH; i++) begin ref_mem[i] = '0; known[i] = 0; end
        #5;

        // 1. bus en alta impedancia cuando no se lee ni se escribe
        addr = '0; we = 0; re = 0; #2;
        if (data !== {DATA_W{1'bz}}) begin
            n_err++; $display("[%s] ERROR: data no esta en z en reposo (%b)", NAME, data);
        end

        // 2. escribir todo y leer todo
        for (int a = 0; a < DEPTH; a++)
            escribir(a[ADDR_W-1:0], DATA_W'((a * 37 + 11) ^ (a << 3)));
        for (int a = 0; a < DEPTH; a++)
            leer_y_comparar(a[ADDR_W-1:0], "lectura inicial");

        // 3. sobrescrituras al azar, comprobando que las demas celdas no cambian
        for (int k = 0; k < N_RAND; k++) begin
            reg [ADDR_W-1:0] a1, a2;
            a1 = $urandom_range(DEPTH-1, 0);
            a2 = $urandom_range(DEPTH-1, 0);
            escribir(a1, DATA_W'($urandom));
            leer_y_comparar(a1, "escritura al azar");
            leer_y_comparar(a2, "vecina sin cambio");
        end

        // 4. todo ceros y todo unos
        escribir('0, '0);                 leer_y_comparar('0, "todo ceros");
        escribir('1, {DATA_W{1'b1}});     leer_y_comparar('1, "todo unos");

        // 5. we y re a la vez: gana la escritura
        addr = DEPTH/2; wdata = DATA_W'(5); #1;
        we = 1; re = 1; #5;
        if (data !== wdata) begin
            n_err++; $display("[%s] ERROR: con we=re=1 la RAM manejo el bus", NAME);
        end
        we = 0; re = 0; #1;
        ref_mem[DEPTH/2] = DATA_W'(5); known[DEPTH/2] = 1;
        leer_y_comparar(DEPTH/2, "we y re juntos");

        // 6. lectura final de toda la memoria
        for (int a = 0; a < DEPTH; a++)
            leer_y_comparar(a[ADDR_W-1:0], "lectura final");

        $display("[%s] ADDR_W=%0d DATA_W=%0d (%0d posiciones): errores = %0d",
                 NAME, ADDR_W, DATA_W, DEPTH, n_err);
        done = 1;
    end
endmodule

module tb_ram_top;
    int e0, e1, e2, e3, total;
    bit d0, d1, d2, d3;

    // 4x4 del video: 16 posiciones de 8 bits (dos decodificadores de 4 salidas)
    ram_checker #(.ADDR_W(4), .DATA_W(8),  .N_RAND(500),  .NAME("4x8  (video 4x4)")) c0 (.errores(e0), .done(d0));
    // 256 posiciones de 8 bits: 256 bytes, dos decodificadores de 16 salidas
    ram_checker #(.ADDR_W(8), .DATA_W(8),  .N_RAND(2000), .NAME("256x8 (video)")) c1 (.errores(e1), .done(d1));
    // direccion de ancho impar y dato ancho (filas != columnas)
    ram_checker #(.ADDR_W(5), .DATA_W(16), .N_RAND(1000), .NAME("32x16")) c2 (.errores(e2), .done(d2));
    // dato de 1 bit, minimo
    ram_checker #(.ADDR_W(6), .DATA_W(1),  .N_RAND(1000), .NAME("64x1")) c3 (.errores(e3), .done(d3));

    initial begin
`ifdef FSDB
        $fsdbDumpfile("dump_mem.fsdb");
        $fsdbDumpvars(0, tb_ram_top.c0);
`elsif VCD
        $dumpfile("dump_mem.vcd");
        $dumpvars(0, tb_ram_top.c0);
`endif
        wait (d0 && d1 && d2 && d3);   // espera a que terminen las 4 configuraciones
        #10;
        total = e0 + e1 + e2 + e3;
        $display("Errores: %0d  (configuraciones: 4x8, 256x8, 32x16, 64x1)", total);
        $finish;
    end
endmodule
