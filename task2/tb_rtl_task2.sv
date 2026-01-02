// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.

`timescale 1 ps/ 1 ps

module tb_rtl_task2();

    reg CLOCK_50;
    reg [3:0] KEY;
    reg [9:0] SW;
    reg [9:0] LEDR;
    reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    reg [7:0] VGA_R, VGA_G, VGA_B;
    reg VGA_HS, VGA_VS, VGA_CLK;
    reg [7:0] VGA_X;
    reg [6:0] VGA_Y;
    reg [2:0] VGA_COLOUR;
    reg VGA_PLOT;  

    reg err;
    
    task2 DUT(
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .SW(SW),
        .LEDR(LEDR),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_CLK(VGA_CLK),
        .VGA_X(VGA_X),
        .VGA_Y(VGA_Y),
        .VGA_COLOUR(VGA_COLOUR),
        .VGA_PLOT(VGA_PLOT)
    );
 
    // This task checks the outputs of task2 to the expected values: vga_colour, vga_x, vga_y, and vga_plot
    task task2_checker;
    
        input [2:0] expected_vga_colour;
        input [7:0] expected_vga_x;
        input [6:0] expected_vga_y;   
        input expected_vga_plot;

        if(tb_rtl_task2.DUT.VGA_COLOUR != expected_vga_colour) begin
            $display("error: vga_colour is: %b, expected: %b", tb_rtl_task2.DUT.VGA_COLOUR, expected_vga_colour);
            err = 1'b1;
        end
        else
            err = 1'b0;

        if(tb_rtl_task2.DUT.VGA_X != expected_vga_x) begin
            $display("error: vga_x is %b, expected: %b", tb_rtl_task2.DUT.VGA_X, expected_vga_x);
            err = 1'b1;
        end
        else
            err = 1'b0;

        if(tb_rtl_task2.DUT.VGA_Y != expected_vga_y) begin
            $display("error: vga_y is %b, expected: %b", tb_rtl_task2.DUT.VGA_Y, expected_vga_y);
            err = 1'b1;
        end
        else
            err = 1'b0;

        if(tb_rtl_task2.DUT.VGA_PLOT != expected_vga_plot) begin
            $display("error: vga_plot is %b, expected: %b", tb_rtl_task2.DUT.VGA_PLOT, expected_vga_plot);
            err = 1'b1;
        end
        else
            err = 1'b0;
        
    endtask

    initial begin

        // Reset asserted, clock simulated manually 
        CLOCK_50 = 1'b0;
        KEY[3] = 1'b0;
        #5;
        CLOCK_50 = 1'b1;
        #5; 
        CLOCK_50 = 1'b0;
        KEY[3] = 1'b1; 
        #5; 

        // For each pixel on the screen, check the ouputs
        for(logic [7:0] i = 8'b0; i <= 8'd159; i = i + 1'b1) begin
    
            for(logic [6:0] j = 7'b0; j <= 7'd119; j = j + 1'b1) begin
                    task2_checker(i % 8, i, j, 1'b1);
                    CLOCK_50 = ~CLOCK_50; // Rising edge
                    #5; 
                    CLOCK_50 = ~CLOCK_50; // Falling edge
                    #5; 

                end  
        end

    // End simulation
	$stop;
    
    end

endmodule: tb_rtl_task2
