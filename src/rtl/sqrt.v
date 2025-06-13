`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        Privat
// Engineer:       Abdenassir El Amin
// 
// Create Date:    12.06.2025
// Design Name:    Quadratwurzel-Berechnung
// Module Name:    tb_sqrt_int
// Project Name:   SqrtInt
// Target Devices: All
// Tool Versions:  Vivado 2022.2
// Description: 
//   Testbench für das Modul "sqrt_int", das die ganzzahlige Quadratwurzel
//   eines gegebenen Radikanden berechnet. Der Radikand sowie die Ausgabe
//   sind im Q16.16 Fixed-Point Format.
//
// Dependencies:   Modul "sqrt_int" muss im gleichen Verzeichnis vorhanden sein.
//
// Revision:
// Revision 0.01 - Initial
//
//////////////////////////////////////////////////////////////////////////////////

module sqrt_int #(parameter WIDTH=31) (      // width of radicand
    input wire clk,
    input wire reset,
 	input wire [WIDTH:0] rad, // radicand// radicand
  	input wire s_axis_sqrt_tvalid,
  	output reg m_axis_sqrt_tlast,
    output reg m_axis_sqrt_tvalid,
    output reg m_axis_sqrt_tready,
    output reg [WIDTH:0] root,  // root
    output reg [WIDTH:0] rem    // remainder
    );

    reg [WIDTH:0] x;    // radicand copy
  	reg [WIDTH:0] q;       // intermediate root (quotient)
    reg [WIDTH+2:0] ac; // accumulator (2 bits wider)
    reg [WIDTH+2:0] test_res;  // sign test result (2 bits wider)
	
  	reg [WIDTH:0] old_rad;
    reg[4:0] i;
    reg[2:0] state;
    // State parameters
    localparam INITIAL = 3'b000;
    localparam SETUP = 3'b001;
    localparam SHIFT1 = 3'b100;
    localparam SHIFT2 = 3'b110;
    localparam SQRT = 3'b010;
    localparam ENDS = 3'b111;

    always @(posedge clk or negedge reset) begin
        if(!reset) begin
            state <= INITIAL2;
            m_axis_sqrt_tlast <= 0;
            root <= 0;
            rem <= 0;
            x <= 0;
            test_res <= 0;
            q <= 0;
            ac <= 0;
            i <= 0;
            old_rad <= 0;
            m_axis_sqrt_tvalid <= 0;
            m_axis_sqrt_tready <= 1;
        end

        else begin

        case (state)
            INITIAL: begin
                x <= rad;
                test_res <= 0;
                q <= 0;
                ac <= 0;
                i <= 0;
                state <= SHIFT1;
              	//root <= 0;
                //rem <= 0;
            end
            INITIAL2: begin
                if(s_axis_sqrt_tvalid) begin
                    state <= INITIAL;
                end
            end
            SHIFT1: begin
                // Final state - nothing to do here
              if (i <= 23) begin
                
                ac[1:0] <= x[WIDTH: WIDTH-1];  // Take two MSB bits of x
                    x <= x << 2;  // Shift radicand left by 2
                    state <= SETUP;
                end
                else begin
                  	old_rad <= rad;
                    state <= ENDS;
                    root <= q;
                    rem <= ac[WIDTH:2];  // Undo the final 2-bit shift for remainder
                end
            end

            SETUP: begin
                test_res <= ac - {q, 2'b01};  // Calculate test result
                q <= q << 1;  // Shift quotient
                state <= SQRT;
            end

            SQRT: begin
              if (test_res[WIDTH+2] == 0) begin  // If test_res >= 0
                    ac <= test_res;  // Update accumulator with test result
                    q[0] <= 1'b1;  // Set the least significant bit of q
                    state <= SHIFT2;
                end
                else begin
                    state <= SHIFT2;
                end
                i <= i + 1;
            end

            SHIFT2: begin
                ac <= ac << 2;  // Shift accumulator left by 2 for the next iteration
                state <= SHIFT1;
            //  $display("testost");
            end

            ENDS: begin
              x <= rad;
              test_res <= 0;
              q <= 0;
              ac <= 0;
              i <= 0;
              //$display("Root", root);

              if(s_axis_sqrt_tvalid) begin
                state <=SHIFT1;
                m_axis_sqrt_valid <= 0;
                m_axis_sqrt_tready <= 0;
              end
              else begin
                m_axis_sqrt_valid <= 1;
                m_axis_sqrt_tready <= 1;

            end
        endcase
        end
    end
endmodule

