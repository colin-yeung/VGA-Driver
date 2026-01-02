// Instantiate and connect the VGA adapter and your module

module task4(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);

    logic VGA_BLANK, VGA_SYNC, fs_start, fs_done, rst_n, chubby_triangle_start, chubby_triangle_done, fs_plot, chubby_triangle_plot;
    logic [7:0] fs_x, chubby_triangle_x;
    logic [6:0] fs_y, chubby_triangle_y;
	logic [3:0] fs_colour, chubby_triangle_colour;

    assign rst_n = KEY[3]; 

    // instantiate and connect the VGA adapter and your module
    assign VGA_X = (fs_start) ? fs_x : chubby_triangle_x; 
    assign VGA_Y = (fs_start) ? fs_y : chubby_triangle_y;
	assign VGA_COLOUR = (fs_start) ? fs_colour : chubby_triangle_colour; 
    assign VGA_PLOT = (fs_start) ? fs_plot : chubby_triangle_plot;  

    // Instantiate VGA adapter
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
            
    // Instantiate fillscreen module
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

    // Instantiate reuleaux.sv
    reuleaux chubby_triangle(.clk(CLOCK_50), 
             .rst_n(rst_n), 
             .colour(3'b010),
             .centre_x(8'd80), 
             .centre_y(7'd60), 
             .diameter(8'd80),
             .start(chubby_triangle_start), 
             .done(chubby_triangle_done),
             .vga_x(chubby_triangle_x), 
             .vga_y(chubby_triangle_y),
             .vga_colour(chubby_triangle_colour), 
             .vga_plot(chubby_triangle_plot)
             );

    // Sequential logic to control the assertion of start signals by linking the done signal of the fillscreen module to the start signal of the reuleaux module
    always @(posedge CLOCK_50) begin

        if (~rst_n) begin
            fs_start <= 1'b1;
            chubby_triangle_start  <= 1'b0;
        end else begin
            if (fs_done) begin
                fs_start <= 1'b0;
                chubby_triangle_start <= 1'b1;
            end else if (chubby_triangle_done)
                chubby_triangle_start <= 1'b0;
        end

    end

endmodule: task4
