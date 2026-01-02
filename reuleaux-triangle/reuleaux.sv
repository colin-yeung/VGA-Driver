// Draw the Reuleaux triangle

`define commence  3'b000
`define octant_2  3'b001
`define octant_3  3'b010
`define octant_5  3'b011
`define octant_6  3'b100
`define octant_8  3'b101
`define octant_7  3'b110
`define done      3'b111

module reuleaux(input logic clk, input logic rst_n, input logic [2:0] colour,
                input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] diameter,
                input logic start, output logic done,
                output logic [7:0] vga_x, output logic [6:0] vga_y,
                output logic [2:0] vga_colour, output logic vga_plot);

    reg signed [9:0] crit;
    reg [7:0] offset_x;
    reg [6:0] offset_y;
    reg [2:0] present_state, next_state;
    reg signed [9:0] x_total;  // must have range from -255 to 510, range based on minumim and maximum value of centre + radius
    reg signed [8:0] y_total; // must have range from -127 to 254

    reg [7:0] c_x1, c_x2, c_x3; 
    reg [6:0] c_y1, c_y2, c_y3;

    assign vga_colour = colour;
    assign vga_x = $unsigned(x_total[7:0]);
    assign vga_y = $unsigned(y_total[6:0]);    

    // The 19 bit number is √3/6 or √3/3, then the (1 << 11) handles the rounding. We shift back 12 bits to round to the nearest integer
    assign c_x1 = centre_x + (diameter >> 1);
    assign c_y1 = centre_y + (((diameter * 19'b0000000_010010011111) + (1 << 11)) >> 12);
    assign c_x2 = centre_x - (diameter >> 1);
    assign c_y2 = centre_y + (((diameter * 19'b0000000_010010011111) + (1 << 11)) >> 12);
    assign c_x3 = centre_x; 
    assign c_y3 = centre_y - (((diameter * 19'b0000000_100100111110) + (1 << 11)) >> 12);

    // Sequential always block, that initializes the present state if reset is asserted, else updates the present state to the next state
    always @(posedge clk) begin
        if(~rst_n)
            present_state <= `commence;
        else if(start)
            present_state <= next_state;
    end

    // Combinational always block for state transitions
    always_comb begin

        case(present_state)
            `commence: next_state = `octant_2; 
            `octant_2: next_state = `octant_3;
            `octant_3: next_state = `octant_5; 
            `octant_5: next_state = `octant_6; 
            `octant_6: next_state = `octant_8;
            `octant_8: next_state = `octant_7;
            `octant_7: 
                begin
                    if(offset_y <= offset_x) begin
                        next_state = `octant_2;
                    end
                    else
                        next_state = `done;
                end
            `done:    next_state = `done;
            default:  next_state = 4'bxxxx; 
        endcase

    end

    // State machine for outputs
    always @(posedge clk) begin

        // If reset is asserted the offsets and crit are initialized based on Bresenham's circle algorithm
        if(~rst_n) begin
            offset_x <= diameter;
            offset_y <= 7'b0;
            crit <= 8'sd1 - $signed(diameter);
        end
        else begin

            // In each octant, we compute the x and y coordinate based on Bresenham's circle algorithm
            // We also determine if vga_plot is set to high based on if the point is within the VGA bounds (160x120)
            // After going through 8 octants, use crit from Bresenham's circle algorithm to determine if offset_x or offset_y should change
            case(present_state)
                `commence:
                    begin
                        done = 1'b0;
                        vga_plot = 1'b0;
                    end
                `octant_2:
                    begin
                        x_total = c_x3 + offset_y;
                        y_total = c_y3 + offset_x;
                        done = 1'b0; 
                        if(((x_total >= 10'sd0) && (x_total <= 10'sd160) && (y_total >= 9'sd0) && (y_total <= 9'sd120)) && (x_total <= c_x1))
                            vga_plot = 1'b1;  
                        else 
                            vga_plot = 1'b0; 	  
                    end
                `octant_3:
                    begin
                        x_total = c_x3 - offset_y;
                        y_total = c_y3 + offset_x;
                        done = 1'b0; 
                        if(((x_total >= 10'sd0) && (x_total <= 10'sd160) && (y_total >= 9'sd0) && (y_total <= 9'sd120)) && (x_total >= c_x2))
                            vga_plot = 1'b1;  
                        else 
                            vga_plot = 1'b0;   	  
                    end
                `octant_5:
                    begin
                        x_total = c_x1 - offset_x; 
                        y_total = c_y1 - offset_y; 
                        done = 1'b0; 
                        if((x_total >= 10'sd0) && (x_total <= 10'sd160) && (y_total >= 9'sd0) && (y_total <= 9'sd120))
                            vga_plot = 1'b1;  
                        else 
                            vga_plot = 1'b0;   
                    end
                `octant_6:
                    begin
                        x_total = c_x1 - offset_y;
                        y_total = c_y1 - offset_x;
                        done = 1'b0; 
                        if(((x_total >= 10'sd0) && (x_total <= 10'sd160) && (y_total >= 9'sd0) && (y_total <= 9'sd120)) && (x_total <= c_x3))
                            vga_plot = 1'b1;  
                        else 
                            vga_plot = 1'b0;
                    end 
                `octant_8:
                    begin
                        x_total = c_x2 + offset_x;
                        y_total = c_y2 - offset_y;
                        done = 1'b0; 
                        if((x_total >= 10'sd0) && (x_total <= 10'sd160) && (y_total >= 9'sd0) && (y_total <= 9'sd120))
                            vga_plot = 1'b1;  
                        else 
                            vga_plot = 1'b0;
                    end
                `octant_7:
                    begin
                        x_total = c_x2 + offset_y;
                        y_total = c_y2 - offset_x;
                        done = 1'b0; 
                        if(((x_total >= 10'sd0) && (x_total <= 10'sd160) && (y_total >= 9'sd0) && (y_total <= 9'sd120)) && (x_total >= c_x3))
                            vga_plot = 1'b1;  
                        else 
                            vga_plot = 1'b0;

                        offset_y = offset_y + 7'b1;

                        if(crit <= 10'sd0) 
                            crit = crit + (10'd2 * offset_y) + 10'd1; 
                        else begin
                            offset_x = offset_x - 8'd1; 
                            crit = crit + (10'd2 * (offset_y - offset_x)) + 10'd1;
                        end
                    end
                `done:
                // Reset outputs after trangle has been drawn
                    begin
                        x_total = 8'd0;
                        y_total = 7'd0;
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

