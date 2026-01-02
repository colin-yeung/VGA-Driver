// instantiate and connect the VGA adapter and your module

module task3(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);

    logic VGA_BLANK, VGA_SYNC, fs_start, fs_done, rst_n, o_start, o_done, fs_plot, o_plot;
    logic [7:0] fs_x, o_x;
    logic [6:0] fs_y, o_y;
	logic [3:0] fs_colour, o_colour;

    assign rst_n = KEY[3]; 

    // Based on which module is active, the vga_x, vga_y, vga_colour, and vga_plot signals are selected to be outputted to the VGA adapter
    assign VGA_X = (fs_start) ? fs_x : o_x; 
    assign VGA_Y = (fs_start) ? fs_y : o_y;
	assign VGA_COLOUR = (fs_start) ? fs_colour : o_colour; 
    assign VGA_PLOT = (fs_start) ? fs_plot : o_plot;  

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
            
    // Instantiate the fillscreen module, with colour set to black (3'b000)
    fillscreen fs(.clk(CLOCK_50),
                  .rst_n(KEY[3]),
                  .colour(3'b000),
                  .start(fs_start),
                  .done(fs_done),
                  .vga_x(fs_x),
                  .vga_y(fs_y),
                  .vga_colour(fs_colour),
                  .vga_plot(fs_plot)
                  );
    
    // Instantiate the circle module, with centre at (80, 60) and radius 40, colour set to green (3'b010)
    circle o(.clk(CLOCK_50), 
             .rst_n(rst_n), 
             .colour(3'b010),
             .centre_x(8'd80), 
             .centre_y(7'd60), 
             .radius(8'd40),
             .start(o_start), 
             .done(o_done),
             .vga_x(o_x), 
             .vga_y(o_y),
             .vga_colour(o_colour), 
             .vga_plot(o_plot)
             );


    // Sequential logic to control the assertion of start signals by linking the done signal of the fillscreen module to the start signal of the circle module
    always @(posedge CLOCK_50) begin

        if (~rst_n) begin
            fs_start <= 1'b1;
            o_start  <= 1'b0;
        end else begin
            if (fs_done) begin
                fs_start <= 1'b0;
                o_start <= 1'b1;
            end else if (o_done)
                o_start <= 1'b0;
        end

    end

endmodule: task3 


