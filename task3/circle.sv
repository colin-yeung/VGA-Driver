// Defines for each octant of the circle
`define commence  4'b0000
`define octant_1  4'b0001
`define octant_2  4'b0010
`define octant_4  4'b0011
`define octant_3  4'b0100
`define octant_5  4'b0101
`define octant_6  4'b0110
`define octant_8  4'b0111
`define octant_7  4'b1000
`define done      4'b1001

module circle(input logic clk, input logic rst_n, input logic [2:0] colour,
            input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] radius,
            input logic start, output logic done,
            output logic [7:0] vga_x, output logic [6:0] vga_y,
            output logic [2:0] vga_colour, output logic vga_plot);

    reg signed [9:0] crit;
    reg [7:0] offset_x;
    reg [6:0] offset_y;
    reg [3:0] present_state, next_state;
    reg signed [9:0] x_total;  // must have range from -255 to 510
    reg signed [8:0] y_total; // must have range from -127 to 254

    // Assign vga_x and vga_y to either the x_total and y_total based on the vga_plot signal
    assign vga_colour = colour;
    assign vga_x = vga_plot ? $unsigned(x_total[7:0]) : 8'd0;
    assign vga_y = vga_plot ? $unsigned(y_total[6:0]) : 7'd0;

    // Sequential always block to initialize present_state upon reset, otherwise update to next_state
    always @(posedge clk) begin
            if(~rst_n)
               present_state <= `commence;
            else if(start)
               present_state <= next_state;
    end

    // Combinational always block for state transitions
    always_comb begin

        case(present_state)
            `commence: next_state = `octant_1; 
            `octant_1: next_state = `octant_2;
            `octant_2: next_state = `octant_4; 
            `octant_4: next_state = `octant_3; 
            `octant_3: next_state = `octant_5;
            `octant_5: next_state = `octant_6;
            `octant_6: next_state = `octant_8;
            `octant_8: next_state = `octant_7;
            `octant_7: 
                begin
                    if(offset_y <= offset_x) begin
                        next_state = `octant_1;
                    end
                    else
                        next_state = `done;
                end
            `done:    next_state = `done;
            default:  next_state = 4'bxxxx; 
        endcase

    end

    // Combinational always block for output logic
    always @(posedge clk) begin

        // Upon reset, offset_x, offset_y, and crit are initialized
        if(~rst_n) begin
            offset_x <= radius;
            offset_y <= 7'b0;
            crit <= 8'sd1 - $signed(radius);
        end else begin

            // In each octant, we compute the x and y coordinate based on Bresenham's circle algorithm
            // We also determine if vga_plot is set to high based on if the point is within the VGA bounds (160x120)
            // After going through 8 octants, use crit from Bresenham's circle algorithm to determine if offset_x or offset_y should change
            case(present_state)
                `commence:
                    begin
                        done = 1'b0;
                        vga_plot = 1'b0;
                    end
                `octant_1:
                    begin
                        x_total = centre_x + offset_x; 
                        y_total = centre_y + offset_y;   
                        done = 1'b0; 
                        if((x_total >= 10'sd0) && (x_total <= 10'sd160) && (y_total >= 9'sd0) && (y_total <= 9'sd120))
                            vga_plot = 1'b1;  
                        else 
                            vga_plot = 1'b0; 				  
                    end
                `octant_2:
                    begin
                        x_total = centre_x + offset_y;
                        y_total = centre_y + offset_x;
                        done = 1'b0; 
                        if((x_total >= 10'sd0) && (x_total <= 10'sd160) && (y_total >= 9'sd0) && (y_total <= 9'sd120))
                            vga_plot = 1'b1;  
                        else 
                            vga_plot = 1'b0; 	  
                    end
                `octant_4:
                    begin
                        x_total = centre_x - offset_x;
                        y_total = centre_y + offset_y; 
                        done = 1'b0; 
                        if((x_total >= 10'sd0) && (x_total <= 10'sd160) && (y_total >= 9'sd0) && (y_total <= 9'sd120))
                            vga_plot = 1'b1;  
                        else 
                            vga_plot = 1'b0;     
                    end
                `octant_3:
                    begin
                        x_total = centre_x - offset_y;
                        y_total = centre_y + offset_x;
                        done = 1'b0; 
                        if((x_total >= 10'sd0) && (x_total <= 10'sd160) && (y_total >= 9'sd0) && (y_total <= 9'sd120))
                            vga_plot = 1'b1;  
                        else 
                            vga_plot = 1'b0;   	  
                    end
                `octant_5:
                    begin
                        x_total = centre_x - offset_x; 
                        y_total = centre_y - offset_y; 
                        done = 1'b0; 
                        if((x_total >= 10'sd0) && (x_total <= 10'sd160) && (y_total >= 9'sd0) && (y_total <= 9'sd120))
                            vga_plot = 1'b1;  
                        else 
                            vga_plot = 1'b0;   
                    end
                `octant_6:
                    begin
                        x_total = centre_x - offset_y;
                        y_total = centre_y - offset_x;
                        done = 1'b0; 
                        if((x_total >= 10'sd0) && (x_total <= 10'sd160) && (y_total >= 9'sd0) && (y_total <= 9'sd120))
                            vga_plot = 1'b1;  
                        else 
                            vga_plot = 1'b0;
                    end  
                `octant_8:
                    begin
                        x_total = centre_x + offset_x;
                        y_total = centre_y - offset_y;
                        done = 1'b0; 
                        if((x_total >= 10'sd0) && (x_total <= 10'sd160) && (y_total >= 9'sd0) && (y_total <= 9'sd120))
                            vga_plot = 1'b1;  
                        else 
                            vga_plot = 1'b0;
                    end
                `octant_7:
                    begin
                        x_total = centre_x + offset_y;
                        y_total = centre_y - offset_x;
                        done = 1'b0; 
                        if((x_total >= 10'sd0) && (x_total <= 10'sd160) && (y_total >= 9'sd0) && (y_total <= 9'sd120))
                            vga_plot = 1'b1;  
                        else 
                            vga_plot = 1'b0;

                        // In the last octant, we also update offset_x, offset_y, and crit based on Bresenham's circle algorithm
                        offset_y = offset_y + 7'b1;

                        if(crit <= 10'sd0) 
                            crit = crit + (10'd2 * offset_y) + 10'd1; 
                        else begin
                            offset_x = offset_x - 8'd1; 
                            crit = crit + (10'd2 * (offset_y - offset_x)) + 10'd1;
                        end
                    end
                `done:
                    begin
                        done = 1'b1; 
                        vga_plot = 1'b0;
                    end
                default: 
                    begin
                        done = 1'bx; 
                        vga_plot = 1'bx;
                    end
            endcase 
            
        end
 
    end

endmodule

