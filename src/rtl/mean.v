`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        Privat
// Engineer:       Abdenassir El Amin
// 
// Create Date:    25.05.2025
// Design Name:    Mittelwertberechnung
// Module Name:    mean
// Project Name:   MeanFilter
// Target Devices: All
// Tool Versions:  Vivado 2022.2
// Description: 
//   Dieses Modul berechnet den arithmetischen Mittelwert von 2048 Eingangswerten
//   im Q1.15 Fixed-Point Format (signed). Die Ausgabe erfolgt ebenfalls im 
//   Q1.15-Format. Das Ergebnis wird nach jeder vollständigen Akkumulation 
//   (2048 Werte) einmalig ausgegeben.
//
// Dependencies:   Keine
//
// Revision:
// Revision 0.01 - Initial
//
//////////////////////////////////////////////////////////////////////////////////

module mean (
    input  wire        clk,         // Takt-Eingang
    input  wire        rst,         // Asynchrones Reset (aktiv-low)
    input  wire        s_axis_data_tvalid,    // Eingangsdaten gültig
    output reg        s_axis_data_tready,
    input  wire [15:0] data_in,     // Eingangsdaten im Q1.15-Format (Zweierkomplement)
    output reg m_axis_data_tvalid,
    input wire m_axis_data_tready,
    output reg [15:0]  sum_out      // Mittelwert-Ausgabe (Q1.15), Zweierkomplement
);

    localparam N = 2048;                    // Anzahl der Daten für Mittelwertbildung
    parameter ACC_WIDTH = 28;               // Breite des Akkumulators

    reg [14:0] count;                        // Zähler: bis zu 2048 → 15 Bit
    reg [ACC_WIDTH-1:0] accumulator;        // Akkumulator zur Summierung
    reg [ACC_WIDTH-1:0] extended_in;        // Sign-erweiterte Eingabe

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            count       <= 0;
            accumulator <= 0;
            sum_out     <= 0;
            s_axis_data_tready <= 0;
            m_axis_data_tvalid <= 0;
        end else begin
            
            s_axis_data_tready <= 1;
            if (s_axis_data_tvalid) begin
                // Manuelle Sign-Erweiterung von 16 Bit auf 28 Bit
                if (data_in[15]) begin
                    extended_in = {12'b111111111111, data_in}; // negativ: obere Bits mit 1
                end else begin
                    extended_in = {12'b000000000000, data_in}; // positiv: obere Bits mit 0
                end

                if (count == N) begin
                    if(m_axis_data_tready) begin
                    accumulator <= 0;
                    count <= 0;
                    m_axis_data_tvalid <= 0;
                    s_axis_data_tready <= 1;
                    end
                    else begin
                    sum_out     <= accumulator[27:11]; // Mittelwert = Summe / 2048
                    m_axis_data_tvalid  <= 1;
                    s_axis_data_tready  <= 0;
                    end
                end else begin
                    accumulator <= accumulator + extended_in;
                    count       <= count + 1;
                end
            end
        end
    end

endmodule
