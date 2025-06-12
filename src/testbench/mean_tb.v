`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        Privat
// Engineer:       Abdenassir El Amin
// 
// Create Date:    25.05.2025
// Design Name:    Mittelwertberechnung
// Module Name:    mean_tb
// Project Name:   MeanFilter
// Target Devices: All
// Tool Versions:  Vivado 2022.2
// Description: 
//   Testbench für das Modul "mean", das den arithmetischen Mittelwert von 
//   2048 Eingangswerten im Q1.15 Fixed-Point Format berechnet. Die Testbench
//   prüft verschiedene Eingangswerte und vergleicht die Ausgabe mit der Referenz.
//
// Dependencies:   Modul "mean" muss im gleichen Verzeichnis vorhanden sein.
//
// Revision:
// Revision 0.01 - Initial
//
//////////////////////////////////////////////////////////////////////////////////

module mean_tb;

    // Signale für den DUT (Device Under Test)
    reg clk = 0;                // Taktsignal (100 MHz)
    reg rst;                    // Reset (aktiv-high)
    reg valid_in;               // Signal: Eingangsdaten gültig
    reg [15:0] data_in;        // Eingangsdaten (Q1.15)
    wire valid_out;            // Ausgangs-Flag: Ergebnis gültig
    wire [15:0] sum_out;       // Ergebnis (Q1.15)

    // Instanziierung des zu testenden Moduls (DUT)
    mean dut (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .data_in(data_in),
        .valid_out(valid_out),
        .sum_out(sum_out)
    );

    // Taktgenerierung: Umschalten alle 5 ns ⇒ 100 MHz
    always #5 clk = ~clk;

    integer i;
    reg signed [31:0] ref_sum;     // Referenz-Akkumulator für Vergleich

    // Testprozedur für einen Q1.15-Testwert
    task run_test;
        input [15:0] value;        // Q1.15-Wert in hex
        input real float_val;      // Lesbarer Fließkomma-Wert
        begin
            // Initialisieren
            rst = 0;
            $display("--------------------------------------------------");
            $display("? Test with Q1.15 = 0x%04h (%f)", value, float_val);
            
            // Reset-Sequenz
            rst = 1;
            rst = 0;
            valid_in = 0;
            data_in = 0;
            ref_sum = 0;
            #10;
            rst = 1;
            #10;

            // 2048 mal denselben Wert einspeisen
            for (i = 0; i < 2048; i = i + 1) begin
                valid_in = 1;
                data_in = value;
                ref_sum = ref_sum + $signed(value);  // Referenzwert mitführen
                #10;
            end
            #10;
            valid_in = 0;

            // Warten auf gültige Ausgabe vom DUT
            wait (valid_out);

            // Vergleich & Ausgabe
            $display("Expected sum     : %f", $signed(ref_sum[27:11])/ 32768.0);
            $display("DUT sum_out      : 0x%04h", sum_out);
            $display("DUT sum (float)  : %f", $signed(sum_out)/ 32768.0);
            
            if ($signed(sum_out) === $signed(ref_sum[27:11]))
                $display(" Test PASSED.");
            else
                $display(" Test FAILED.");
                
            $display("--------------------------------------------------\n");
            #20;
        end
    endtask

    // Initialblock für vollständigen Testlauf
    initial begin
        // Verschiedene manuelle Testwerte (Q1.15-Format)
        run_test(16'h4000,  0.5);       #100;
        run_test(16'hC000, -0.5);       #100;
        run_test(16'h2000,  0.25);      #100;
        run_test(16'hE000, -0.25);      #100;
        run_test(16'h1000,  0.125);     #100;
        run_test(16'hF000, -0.125);     #100;
        run_test(16'h0000,  0.0);       #100;
        run_test(16'h0666,  0.1);       #100;
        run_test(16'hF99A, -0.1);       #100;
        run_test(16'h3333,  0.4);       #100;
        run_test(16'hCCCC, -0.4);       #100;
        run_test(16'h199A,  0.2);       #100;
        run_test(16'hE666, -0.2);       #100;
        run_test(16'h0CCC,  0.05);      #100;
        run_test(16'hF334, -0.05);      #100;
        run_test(16'h7FFF,  0.99997);   #100;
        run_test(16'h8000, -1.0);       #100;
        run_test(16'h7333,  0.9);       #100;
        run_test(16'h8CCD, -0.9);       #100;
        run_test(16'h6666,  0.8);       #100;
        run_test(16'h999A, -0.8);       #100;
        run_test(16'h59A0,  0.7);       #100;
        run_test(16'hA660, -0.7);       #100;
        run_test(16'h4CCD,  0.6);       #100;
        run_test(16'hB333, -0.6);       #100;
        run_test(16'h3CCD,  0.45);      #100;
        run_test(16'hC334, -0.45);      #100;
        run_test(16'h0A3D,  0.04);      #100;
        run_test(16'hF5C3, -0.04);      #100;

        $display("? All Q1.15 tests completed.");
        $finish;
    end

endmodule
