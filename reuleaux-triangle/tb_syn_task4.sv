// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.

`timescale 1ps / 1ps

module tb_syn_task4();

    reg CLOCK_50, VGA_HS, VGA_CLOCK_50, VGA_PLOT;
    reg [3:0] KEY;
    reg [9:0] SW;
    reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, VGA_Y;
    reg [7:0] VGA_R, VGA_B, VGA_G, VGA_X;
    reg [2:0] VGA_COLOUR;

    reg[7:0] centre_x, diameter;
    reg[6:0] centre_y;
    reg[7:0] c_x1, c_x2, c_x3;
    reg[6:0] c_y1, c_y2, c_y3;
    reg signed [9:0] crit;
    reg [7:0] offset_x;
    reg [6:0] offset_y;

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

    assign c_x1 = centre_x + (diameter >> 1);
    assign c_y1 = centre_y + (((diameter * 19'b0000000_010010011111) + (1 << 11)) >> 12);
    assign c_x2 = centre_x - (diameter >> 1);
    assign c_y2 = centre_y + (((diameter * 19'b0000000_010010011111) + (1 << 11)) >> 12);
    assign c_x3 = centre_x; 
    assign c_y3 = centre_y - (((diameter * 19'b0000000_100100111110) + (1 << 11)) >> 12);

    // This task checks the outputs of the fillscreen against expected values, vga_x, vga_y, colour, vga_plot
    task check_screen;

        input [7:0] expected_x;
        input [6:0] expected_y;
        input [2:0] expected_colour;
        input expected_plot; 

        err = 1'b0;

        if(tb_syn_task4.DUT.VGA_X != expected_x) begin
            $display("Error, vga_x is %d, expected %d", tb_syn_task4.DUT.VGA_X, expected_x);
            err = 1'b1; 
        end

        if(tb_syn_task4.DUT.VGA_Y != expected_y) begin
            $display("Error, vga_y is %d, expected %d", tb_syn_task4.DUT.VGA_Y, expected_y);
            err = 1'b1; 
        end

        if(tb_syn_task4.DUT.VGA_COLOUR != expected_colour) begin
            $display("error, colour is: %b, expect: %b", tb_syn_task4.DUT.VGA_COLOUR, expected_colour);
                err = 1'b1;
        end

        if(tb_syn_task4.DUT.VGA_PLOT != expected_plot) begin
            $display("Error, plot is %b, expected %b", tb_syn_task4.DUT.VGA_PLOT, expected_plot);
            err = 1'b1; 
        end

    endtask 

    // This task checks the outputs of the reuleaux against expected values, vga_x, vga_y, vga_colour, vga_plot
    task task_4_checker;

        input [7:0] expected_x;
        input [6:0] expected_y;
        input [2:0] expected_colour;
        input expected_plot;

        err = 1'b0;
        
        if(tb_syn_task4.DUT.VGA_X != expected_x) begin
            $display("Error: vga_x is: %d, expected is: %d", tb_syn_task4.DUT.VGA_X, expected_x);
            err = 1'b1;
        end
            
        if(tb_syn_task4.DUT.VGA_Y != expected_y) begin
            $display("Error: vga_y is: %d, expected is: %d", tb_syn_task4.DUT.VGA_Y, expected_y);
            err = 1'b1;
        end

        if(tb_syn_task4.DUT.VGA_COLOUR != expected_colour) begin
            $display("Error: vga_colour is: %b, expected is: %b", tb_syn_task4.DUT.VGA_COLOUR, expected_colour);
            err = 1'b1;
        end
        
        if(tb_syn_task4.DUT.VGA_PLOT != expected_plot) begin
            $display("Error: vga_plot is: %b, expected is: %b", tb_syn_task4.DUT.VGA_PLOT, expected_plot);
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

        // Initialize inputs
        diameter = 8'd80;
        centre_x = 8'd80;
        centre_y = 7'd60;

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

        offset_x <= diameter;
        offset_y <= 7'b0;
        crit <= 8'sd1 - $signed(diameter);
        
        // Order: 
        // Octant 2/3 (circle 3 - top circle)
        // Octant 5/6 (circle 1 - right circle)
        // Octant 7/8 (circle 2 - left circle)

        #30;

        // In each, we check and update the new values for each x and y    
        while(offset_y <= offset_x) begin

            // Octant 2
            @(negedge CLOCK_50);
            task_4_checker(c_x3 + offset_y, c_y3 + offset_x, 3'b001, ((c_x3 + offset_y) <= c_x1) ? 1'b1 : 1'b0); // octant 2
            
            // Octant 3
            @(negedge CLOCK_50);
            task_4_checker(c_x3 - offset_y, c_y3 + offset_x, 3'b001, ((c_x3 - offset_y) >= c_x2) ? 1'b1 : 1'b0); // octant 3

            // Octant 5
            @(negedge CLOCK_50);
            task_4_checker(c_x1 - offset_x, c_y1 - offset_y, 3'b001, 1'b1); // octant 5

            // Octant 6
            @(negedge CLOCK_50);
            task_4_checker(c_x1 - offset_y, c_y1 - offset_x, 3'b001, ((c_x1 - offset_y) <= c_x3) ? 1'b1 : 1'b0); // octant 6

            // Octant 8
            @(negedge CLOCK_50);
            task_4_checker(c_x2 + offset_x, c_y2 - offset_y, 3'b001, 1'b1); // octant 8

            // Octant 7
            @(negedge CLOCK_50);
            task_4_checker(c_x2 + offset_y, c_y2 - offset_x, 3'b001, ((c_x2 + offset_y) >= c_x3) ? 1'b1 : 1'b0); // octant 7

            offset_y++;
            if(crit <= 10'sd0) 
                crit = crit + (10'sd2 * offset_y) + 10'sd1; 
            else begin
                offset_x--;
                crit = crit + (10'sd2 * (offset_y - offset_x)) + 10'sd1;
            end
        end

        #100;

        task_4_checker(8'd0, 7'b0, 3'b001, 1'b0);
        
        $stop; // End simulation  

    end

endmodule: tb_syn_task4
