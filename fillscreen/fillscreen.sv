// The user of the fillscreen module will assert start and hold it high until your module asserts done. 
// Any time after done is received, the user may de-assert start. After start is deasserted, your module 
// should deassert done and must be prepared for the possibility that start may be immediately asserted again.

module fillscreen(input logic clk, input logic rst_n, input logic [2:0] colour,
                  input logic start, output logic done,
                  output logic [7:0] vga_x, output logic [6:0] vga_y,
                  output logic [2:0] vga_colour, output logic vga_plot);

     // Resolution: 160x120
     logic [7:0] x_pixel; // 8 bits for 160
     logic [6:0] y_pixel; // 7 bits for 120 

     assign vga_x = x_pixel; 
     assign vga_y = y_pixel;
     assign vga_colour = colour;

     // This always block is sequential, controlling the vga_x, vga_y, done, and vga_plot signals based on start
     always_ff @(posedge clk) begin

          // If start is asserted then vga_plot stays high, and the loop begins
          if(start) 
               begin

                    vga_plot <= 1'b1;

                    // If the end of the screen is reached that assert done
                    if(x_pixel == 8'd159 && y_pixel == 7'd119) begin
                         done <= 1'b1;
                         x_pixel <= 8'd0;
                         y_pixel <= 7'd0;
                         
                    // Else we keep plotting
                    end else begin
                         done <= 1'b0;
                         // We plot pixel by pixel, by doing all the vga_y for each given vga_x
                         if(y_pixel == 7'd119) begin
                                   y_pixel <= 7'd0;
                                   x_pixel <= x_pixel + 1;
                         end else begin
                                   y_pixel <= y_pixel + 1;
                         end
                    end

               end

          // Re-initialize outputs if start is not asserted after the screen is filled
          else 
               begin           
                    x_pixel <= 8'b0;
                    y_pixel <= 7'b0;
                    done <= 1'b0;
                    vga_plot <= 1'b0;

               end
     
     end

endmodule: fillscreen