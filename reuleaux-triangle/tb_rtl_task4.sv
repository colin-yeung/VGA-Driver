// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.

`timescale 1ps / 1ps

module tb_rtl_task4();

    reg CLOCK_50, VGA_HS, VGA_CLK, VGA_PLOT;
    reg [3:0] KEY;
    reg [9:0] SW;
    reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, VGA_Y;
    reg [7:0] VGA_R, VGA_B, VGA_G, VGA_X;
    reg [2:0] VGA_COLOUR;

    reg[7:0] sync_x, diameter;
    reg[6:0] sync_y;

    reg err;

    task4 DUT(.CLOCK_50(CLOCK_50),
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

    // This task checks the outputs of the fillscreen against expected values, vga_x, vga_y, colour, vga_plot
    task check_screen;

        input [7:0] expected_x;
        input [6:0] expected_y;
        input [2:0] expected_colour;
        input expected_plot; 

        err = 1'b0;

        if(tb_rtl_task4.DUT.fs.vga_x != expected_x) begin
            $display("Error, vga_x is %d, expected %d", tb_rtl_task4.DUT.fs.vga_x, expected_x);
            err = 1'b1; 
        end

        if(tb_rtl_task4.DUT.fs.vga_y != expected_y) begin
            $display("Error, vga_y is %d, expected %d", tb_rtl_task4.DUT.fs.vga_y, expected_y);
            err = 1'b1; 
        end

        if(tb_rtl_task4.DUT.fs.colour != expected_colour) begin
            $display("error, colour is: %b, expect: %b", tb_rtl_task4.DUT.fs.colour, expected_colour);
                err = 1'b1;
        end

        if(tb_rtl_task4.DUT.fs.vga_plot != expected_plot) begin
            $display("Error, plot is %b, expected %b", tb_rtl_task4.DUT.fs.vga_plot, expected_plot);
            err = 1'b1; 
        end

    endtask 

    // This task checks the outputs of the reuleaux triangle against expected values, vga_x, vga_y, colour, vga_plot
    task task_4_checker;

        input [7:0] expected_x;
        input [6:0] expected_y;
        input [2:0] expected_colour;
        input expected_plot;

        err = 1'b0;
        
        if(tb_rtl_task4.DUT.chubby_triangle.vga_x != expected_x) begin
            $display("Error: vga_x is: %d, expected is: %d", tb_rtl_task4.DUT.chubby_triangle.vga_x, expected_x);
            err = 1'b1;
        end
            
        if(tb_rtl_task4.DUT.chubby_triangle.vga_y != expected_y) begin
            $display("Error: vga_y is: %d, expected is: %d", tb_rtl_task4.DUT.chubby_triangle.vga_y, expected_y);
            err = 1'b1;
        end

        if(tb_rtl_task4.DUT.chubby_triangle.colour != expected_colour) begin
            $display("Error: vga_colour is: %b, expected is: %b", tb_rtl_task4.DUT.chubby_triangle.colour, expected_colour);
            err = 1'b1;
        end
        
        if(tb_rtl_task4.DUT.chubby_triangle.vga_plot != expected_plot) begin
            $display("Error: vga_plot is: %b, expected is: %b", tb_rtl_task4.DUT.chubby_triangle.vga_plot, expected_plot);
            err = 1'b1;
        end

    endtask

    // Simulate clock
    initial begin
        CLOCK_50 = 1'b0; 
        forever begin
            #5; CLOCK_50 = ~CLOCK_50; 
        end
    end

    initial begin

        // Reset
        KEY[3] = 1'b0;
        #10;
        KEY[3] = 1'b1;

        // Checks that the entire screen is initialized to black 
        for(logic [7:0] i = 8'b0; i <= 8'd159; i = i + 1'b1) begin
    
            for(logic [6:0] j = 7'b0; j <= 7'd119; j = j + 1'b1) begin
                if(i == 8'b0 && j == 7'b0)begin
                    @(posedge CLOCK_50);
                    check_screen(0, 0, 3'b000, 1'b0);
                end
                else begin
                    @(posedge CLOCK_50);
                    check_screen(i, j, 3'b000, 1'b1);
                end
                    
            end  
        end

        // CHECK REULEAUX TRIANGLE
    
        // Since the values of vga_x and vga_y are dependent on the rising edge of clk, these will need to be computed before the posedge to then be checked after
        sync_x = (tb_rtl_task4.DUT.chubby_triangle.x_total <= tb_rtl_task4.DUT.chubby_triangle.c_x1) ? tb_rtl_task4.DUT.chubby_triangle.c_x3 + tb_rtl_task4.DUT.chubby_triangle.offset_y : 8'd0;
        sync_y = (tb_rtl_task4.DUT.chubby_triangle.x_total <= tb_rtl_task4.DUT.chubby_triangle.c_x1) ? tb_rtl_task4.DUT.chubby_triangle.c_y3 + tb_rtl_task4.DUT.chubby_triangle.offset_x : 7'd0;

        #30;

        // Order: 
        // Octant 2/3 (circle 3 - top circle)
        // Octant 5/6 (circle 1 - right circle)
        // Octant 7/8 (circle 2 - left circle)

        // In each, we check and update the new values for each x and y    
        while(tb_rtl_task4.DUT.chubby_triangle.offset_y <= tb_rtl_task4.DUT.chubby_triangle.offset_x) begin

            // Octant 2
            @(negedge CLOCK_50);
            task_4_checker(sync_x, sync_y, 3'b001, (tb_rtl_task4.DUT.chubby_triangle.x_total <= tb_rtl_task4.DUT.chubby_triangle.c_x1) ? 1'b1 : 1'b0); // octant 2
            sync_x = (tb_rtl_task4.DUT.chubby_triangle.x_total >= tb_rtl_task4.DUT.chubby_triangle.c_x2) ? tb_rtl_task4.DUT.chubby_triangle.c_x3 - tb_rtl_task4.DUT.chubby_triangle.offset_y : 8'd0;
            sync_y = (tb_rtl_task4.DUT.chubby_triangle.x_total >= tb_rtl_task4.DUT.chubby_triangle.c_x2) ? tb_rtl_task4.DUT.chubby_triangle.c_y3 + tb_rtl_task4.DUT.chubby_triangle.offset_x : 7'd0;
            
            // Octant 3
            @(negedge CLOCK_50);
            task_4_checker(sync_x , sync_y, 3'b001, (tb_rtl_task4.DUT.chubby_triangle.x_total >= tb_rtl_task4.DUT.chubby_triangle.c_x2) ? 1'b1 : 1'b0); // octant 3
            sync_x = tb_rtl_task4.DUT.chubby_triangle.c_x1 - tb_rtl_task4.DUT.chubby_triangle.offset_x;
            sync_y = tb_rtl_task4.DUT.chubby_triangle.c_y1 - tb_rtl_task4.DUT.chubby_triangle.offset_y;

            // Octant 5
            @(negedge CLOCK_50);
            task_4_checker(sync_x, sync_y, 3'b001, 1'b1); // octant 5
            sync_x = (tb_rtl_task4.DUT.chubby_triangle.x_total <= tb_rtl_task4.DUT.chubby_triangle.c_x3) ? tb_rtl_task4.DUT.chubby_triangle.c_x1 - tb_rtl_task4.DUT.chubby_triangle.offset_y : 8'd0;
            sync_y = (tb_rtl_task4.DUT.chubby_triangle.x_total <= tb_rtl_task4.DUT.chubby_triangle.c_x3) ? tb_rtl_task4.DUT.chubby_triangle.c_y1 - tb_rtl_task4.DUT.chubby_triangle.offset_x : 7'd0;
            
            // Octant 6
            @(negedge CLOCK_50);
            task_4_checker(sync_x, sync_y, 3'b001, (tb_rtl_task4.DUT.chubby_triangle.x_total <= tb_rtl_task4.DUT.chubby_triangle.c_x3) ? 1'b1 : 1'b0); // octant 6
            sync_x = tb_rtl_task4.DUT.chubby_triangle.c_x2 + tb_rtl_task4.DUT.chubby_triangle.offset_x;;
            sync_y = tb_rtl_task4.DUT.chubby_triangle.c_y2 - tb_rtl_task4.DUT.chubby_triangle.offset_y;

            // Octant 8
            @(negedge CLOCK_50);
            task_4_checker(sync_x, sync_y, 3'b001, 1'b1); // octant 8
            sync_x = (tb_rtl_task4.DUT.chubby_triangle.x_total >= tb_rtl_task4.DUT.chubby_triangle.c_x3) ? tb_rtl_task4.DUT.chubby_triangle.c_x2 + tb_rtl_task4.DUT.chubby_triangle.offset_y : 8'd0;
            sync_y = (tb_rtl_task4.DUT.chubby_triangle.x_total >= tb_rtl_task4.DUT.chubby_triangle.c_x3) ? tb_rtl_task4.DUT.chubby_triangle.c_y2 - tb_rtl_task4.DUT.chubby_triangle.offset_x : 7'd0;

            // Octant 7
            @(negedge CLOCK_50);
            task_4_checker(sync_x, sync_y, 3'b001, (tb_rtl_task4.DUT.chubby_triangle.x_total >= tb_rtl_task4.DUT.chubby_triangle.c_x3) ? 1'b1 : 1'b0); // octant 7
            sync_x = (tb_rtl_task4.DUT.chubby_triangle.x_total <= tb_rtl_task4.DUT.chubby_triangle.c_x1) ? tb_rtl_task4.DUT.chubby_triangle.c_x3 + tb_rtl_task4.DUT.chubby_triangle.offset_y : 8'd0;
            sync_y = (tb_rtl_task4.DUT.chubby_triangle.x_total <= tb_rtl_task4.DUT.chubby_triangle.c_x1) ? tb_rtl_task4.DUT.chubby_triangle.c_y3 + tb_rtl_task4.DUT.chubby_triangle.offset_x : 7'd0;
        
        end

        #100;

        task_4_checker(8'd0, 7'b0, 3'b001, 1'b0);
        
        $stop; // End simulation

    end

endmodule: tb_rtl_task4