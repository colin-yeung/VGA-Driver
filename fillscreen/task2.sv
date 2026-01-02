// instantiate and connect the VGA adapter and your module

module task2(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);

    logic VGA_BLANK, VGA_SYNC;
    logic start, done, rst_n; 
    wire [2:0] assign_colour;
    

    // Assign a colour based on the x coordinate. We use a modulo 8 operation tto
    assign assign_colour = VGA_X % 8;

    assign rst_n = KEY[3]; 

    // Instantiate the fillscreen module
    fillscreen fs(
        .clk(CLOCK_50),
        .rst_n(KEY[3]),
        .colour(assign_colour),
        .start(start),
        .done(done),
        .vga_x(VGA_X),
        .vga_y(VGA_Y),
        .vga_colour(VGA_COLOUR),
        .vga_plot(VGA_PLOT)
    );

    // Instantiate the VGA adapter
    vga_adapter#(.RESOLUTION("160x120")) VGA_adapter(.resetn(KEY[3]), 
                                                     .clock(CLOCK_50), 
                                                     .colour(VGA_COLOUR),
                                                     .x(VGA_X), 
                                                     .y(VGA_Y), 
                                                     .plot(VGA_PLOT),
                                                     .VGA_R(VGA_R), 
                                                     .VGA_G(VGA_G), 
                                                     .VGA_B(VGA_B),
                                                     .*
                                                     );


    // Logic for asserting start and keeping it high until fillscreen asserts done
     always @(posedge CLOCK_50) begin
        if(~rst_n)
            start <= 1'b1; 
        else begin
            if(done)
                start <= 1'b0; 
            else
                start <= start;
        end

    end
    
endmodule: task2
