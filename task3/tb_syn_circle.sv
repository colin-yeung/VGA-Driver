// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.

`timescale 1ps / 1ps

module tb_syn_circle();

    reg clk, rst_n, start, done, vga_plot, err;
    reg [2:0] colour;
    reg [7:0] centre_x, offset; 
    reg [6:0] centre_y;
    reg [7:0] radius;
    reg [7:0] vga_x; 
    reg [6:0] vga_y; 
    reg [3:0] vga_colour; 

    circle DUT(.clk(clk),
               .rst_n(rst_n),
               .colour(colour),
               .centre_x(centre_x),
               .centre_y(centre_y),
               .radius(radius),
               .start(start),
               .done(done),
               .vga_x(vga_x),
               .vga_y(vga_y),
               .vga_colour(vga_colour),
               .vga_plot(vga_plot)
               );

    // This task checks the outputs of the circle module against expected values, vga_x, vga_y, vga_colour, and vga_plot
    task o_checker;

        input [7:0] expected_vga_x;
        input [6:0] expected_vga_y;
        input [2:0] expected_vga_colour;
        input expected_vga_plot;

        err = 1'b0; 

        if(tb_syn_circle.DUT.vga_x != expected_vga_x) begin
            $display("Error: vga_x is: %d, expected: %d", tb_syn_circle.DUT.vga_x, expected_vga_x);
            err = 1'b1;
        end
        if(tb_syn_circle.DUT.vga_y != expected_vga_y) begin
            $display("Error: vga_y is: %d, expected: %d", tb_syn_circle.DUT.vga_y, expected_vga_y);
            err = 1'b1;
        end
        if(tb_syn_circle.DUT.vga_colour != expected_vga_colour) begin
            $display("Error: vga_colour is: %d, expected: %d", tb_syn_circle.DUT.vga_colour, expected_vga_colour);
            err = 1'b1;
        end
        if(tb_syn_circle.DUT.vga_plot != expected_vga_plot) begin
            $display("Error: vga_plot is: %d, expected: %d", tb_syn_circle.DUT.vga_plot, expected_vga_plot);
            err = 1'b1;
        end

    endtask

    // Simulate clock
    initial begin
        clk = 1'b0; 
        forever begin
            #5; clk = ~clk; 
        end
    end
    
    initial begin

        // Initialize inputs
        radius = 8'd40; 
        centre_x = 8'd80;
        centre_y = 7'd60; 
        rst_n = 1'b0;
        #10;
        rst_n = 1'b1; 

        start = 1'b1;

        #15; 

        // While offset_y is less than offset_x, check if the pixels on the octants are plotted, based on Bresenham's circle drawing algorithm
        while(tb_syn_circle.DUT.offset_y <= tb_syn_circle.DUT.offset_x) begin

            @(negedge clk);
            o_checker(tb_syn_circle.DUT.centre_x + tb_syn_circle.DUT.offset_x, tb_syn_circle.DUT.centre_y + tb_syn_circle.DUT.offset_y, 3'b010, 1'b1); 
            @(negedge clk); 
            o_checker(tb_syn_circle.DUT.centre_x + tb_syn_circle.DUT.offset_y, tb_syn_circle.DUT.centre_y + tb_syn_circle.DUT.offset_x, 3'b010, 1'b1); 
            @(negedge clk);
            o_checker(tb_syn_circle.DUT.centre_x - tb_syn_circle.DUT.offset_x, tb_syn_circle.DUT.centre_y + tb_syn_circle.DUT.offset_y, 3'b010, 1'b1); 
            @(negedge clk);
            o_checker(tb_syn_circle.DUT.centre_x - tb_syn_circle.DUT.offset_y, tb_syn_circle.DUT.centre_y + tb_syn_circle.DUT.offset_x, 3'b010, 1'b1); 
            @(negedge clk);
            o_checker(tb_syn_circle.DUT.centre_x - tb_syn_circle.DUT.offset_x, tb_syn_circle.DUT.centre_y - tb_syn_circle.DUT.offset_y, 3'b010, 1'b1); 
            @(negedge clk);
            o_checker(tb_syn_circle.DUT.centre_x - tb_syn_circle.DUT.offset_y, tb_syn_circle.DUT.centre_y - tb_syn_circle.DUT.offset_x, 3'b010, 1'b1); 
            @(negedge clk);
            o_checker(tb_syn_circle.DUT.centre_x + tb_syn_circle.DUT.offset_x, tb_syn_circle.DUT.centre_y - tb_syn_circle.DUT.offset_y, 3'b010, 1'b1);
            if(tb_syn_circle.DUT.crit[9] == 1'b1)
                offset = 8'd0;
            else 
                offset = -8'd1;
            @(negedge clk); 
            o_checker(tb_syn_circle.DUT.centre_x + tb_syn_circle.DUT.offset_y - 8'd1, tb_syn_circle.DUT.centre_y - tb_syn_circle.DUT.offset_x + offset, 3'b010, 1'b1); 

        end

        $stop; // End simulation

    end

endmodule: tb_syn_circle
