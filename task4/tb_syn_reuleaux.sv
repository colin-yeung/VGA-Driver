// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.

`timescale 1ps / 1ps

module tb_syn_reuleaux();

    reg[7:0] centre_x, vga_x, diameter;
    reg[6:0] centre_y, vga_y;
    reg[2:0] colour, vga_colour;
    reg clk, rst_n, start, done, vga_plot;  

    reg[7:0] sync_x;
    reg[6:0] sync_y;
    reg[7:0] c_x1, c_x2, c_x3;
    reg[6:0] c_y1, c_y2, c_y3;
    reg err;

    reuleaux DUT(.clk(clk), 
                 .rst_n(rst_n),
                 .colour(colour), 
                 .centre_x(centre_x), 
                 .centre_y(centre_y), 
                 .diameter(diameter), 
                 .start(start),
                 .done(done),
                 .vga_x(vga_x),
                 .vga_y(vga_y),
                 .vga_colour(vga_colour),
                 .vga_plot(vga_plot)
                );

    // The 19 bit number is √3/6 or √3/3, then the (1 << 11) handles the rounding. We shift back 12 bits to round to the nearest integer
    assign c_x1 = centre_x + (diameter >> 1);
    assign c_y1 = centre_y + (((diameter * 19'b0000000_010010011111) + (1 << 11)) >> 12);
    assign c_x2 = centre_x - (diameter >> 1);
    assign c_y2 = centre_y + (((diameter * 19'b0000000_010010011111) + (1 << 11)) >> 12);
    assign c_x3 = centre_x; 
    assign c_y3 = centre_y - (((diameter * 19'b0000000_100100111110) + (1 << 11)) >> 12);

    // This task checks the outputs of the DUT against expected values, done, vga_x, vga_y, vga_colour, vga_plots
    task reuleaux_check;
    
        input expected_done;
        input [7:0] expected_x;
        input [6:0] expected_y;
        input [2:0] expected_colour;
        input expected_plot;

        if(tb_syn_reuleaux.DUT.done != expected_done) begin
            $display("Error: done is: %b, expected is: %b", tb_syn_reuleaux.DUT.done, expected_done);
            err = 1'b1;
        end
        else if(tb_syn_reuleaux.DUT.vga_x != expected_x) begin
            $display("Error: vgax is: %d, expected is: %d", tb_syn_reuleaux.DUT.vga_x, expected_x);
            err = 1'b1;
        end
        else if(tb_syn_reuleaux.DUT.vga_y != expected_y) begin
            $display("Error: vgay is: %d, expected is: %d", tb_syn_reuleaux.DUT.vga_y, expected_y);
            err = 1'b1;
        end
        else if(tb_syn_reuleaux.DUT.colour != expected_colour) begin
            $display("Error: colour is: %b, expected is: %b", tb_syn_reuleaux.DUT.colour, expected_colour);
            err = 1'b1;
        end

        else if(tb_syn_reuleaux.DUT.vga_plot != expected_plot) begin
            $display("Error: vga_plot is: %b, expected is: %b", tb_syn_reuleaux.DUT.vga_plot, expected_plot);
            err = 1'b1;
        end
        else
            err = 1'b0;

    endtask

    // Simulate clock
    initial begin
        clk = 1'b0;
        forever begin
            #5;
            clk = ~clk;
        end
    end


    initial begin

        // Initialiize inputs
        diameter = 8'd80;
        colour = 3'b001;
        centre_x = 8'd80;
        centre_y = 7'd60;

        rst_n = 1'b0;
        #10;
        rst_n = 1'b1;

        reuleaux_check(1'b0, 8'd0, 7'b0, colour, 1'b0);

        start = 1'b1;

        #15; 

        // Since the values of vga_x and vga_y are dependent on the rising edge of clk, these will need to be computed before the posedge to then be checked after
        sync_x = (tb_syn_reuleaux.DUT.x_total <= c_x1) ? c_x3 + tb_syn_reuleaux.DUT.offset_y : 8'd0;
        sync_y = (tb_syn_reuleaux.DUT.x_total <= c_x1) ? c_y3 + tb_syn_reuleaux.DUT.offset_x : 7'd0;

        // Order: 
        // Octant 2/3 (circle 3 - top circle)
        // Octant 5/6 (circle 1 - right circle)
        // Octant 7/8 (circle 2 - left circle)
            
        // In each, we check and update the new values for each x and y    
        while(tb_syn_reuleaux.DUT.offset_y <= tb_syn_reuleaux.DUT.offset_x) begin

            // Octant 2
            @(negedge clk);
            reuleaux_check(1'd0, sync_x, sync_y, 3'b001, (tb_syn_reuleaux.DUT.x_total <= c_x1) ? 1'b1 : 1'b0); // octant 2
            sync_x = (tb_syn_reuleaux.DUT.x_total >= c_x2) ? c_x3 - tb_syn_reuleaux.DUT.offset_y : 8'd0;
            sync_y = (tb_syn_reuleaux.DUT.x_total >= c_x2) ? c_y3 + tb_syn_reuleaux.DUT.offset_x : 7'd0;
            
            // Octant 3
            @(negedge clk);
            reuleaux_check(1'd0, sync_x , sync_y, 3'b001, (tb_syn_reuleaux.DUT.x_total >= c_x2) ? 1'b1 : 1'b0); // octant 3
            sync_x = c_x1 - tb_syn_reuleaux.DUT.offset_x;
            sync_y = c_y1 - tb_syn_reuleaux.DUT.offset_y;

            // Octant 5
            @(negedge clk);
            reuleaux_check(1'd0, sync_x, sync_y, 3'b001, 1'b1); // octant 5
            sync_x = (tb_syn_reuleaux.DUT.x_total <= c_x3) ? c_x1 - tb_syn_reuleaux.DUT.offset_y : 8'd0;
            sync_y = (tb_syn_reuleaux.DUT.x_total <= c_x3) ? c_y1 - tb_syn_reuleaux.DUT.offset_x : 7'd0;
            
            // Octant 6
            @(negedge clk);
            reuleaux_check(1'd0, sync_x, sync_y, 3'b001, (tb_syn_reuleaux.DUT.x_total <= c_x3) ? 1'b1 : 1'b0); // octant 6
            sync_x = c_x2 + tb_syn_reuleaux.DUT.offset_x;;
            sync_y = c_y2 - tb_syn_reuleaux.DUT.offset_y;

            // Octant 8
            @(negedge clk);
            reuleaux_check(1'd0, sync_x, sync_y, 3'b001, 1'b1); // octant 8
            sync_x = (tb_syn_reuleaux.DUT.x_total >= c_x3) ? c_x2 + tb_syn_reuleaux.DUT.offset_y : 8'd0;
            sync_y = (tb_syn_reuleaux.DUT.x_total >= c_x3) ? c_y2 - tb_syn_reuleaux.DUT.offset_x : 7'd0;

            // Octant 7
            @(negedge clk);
            reuleaux_check(1'd0, sync_x, sync_y, 3'b001, (tb_syn_reuleaux.DUT.x_total >= c_x3) ? 1'b1 : 1'b0); // octant 7
            sync_x = (tb_syn_reuleaux.DUT.x_total <= c_x1) ? c_x3 + tb_syn_reuleaux.DUT.offset_y : 8'd0;
            sync_y = (tb_syn_reuleaux.DUT.x_total <= c_x1) ? c_y3 + tb_syn_reuleaux.DUT.offset_x : 7'd0;
        
        end

        #100;

        reuleaux_check(1'b1, 8'd0, 7'b0, colour, 1'b0);

        $stop; // End simulation

    end

endmodule: tb_syn_reuleaux