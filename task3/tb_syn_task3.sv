// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.

`timescale 1 ps/ 1 ps

module tb_syn_task3();

    reg [9:0] SW, LEDR; 
    reg [7:0] VGA_R, VGA_G, VGA_B, VGA_X, subtract;
    reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, VGA_Y;
    reg [3:0] KEY; 
    reg [2:0] VGA_COLOUR; 
    reg CLOCK_50, VGA_HS, VGA_VS, VGA_CLK, VGA_PLOT; 

    reg signed [9:0] crit;
    reg [7:0] offset_x, centre_x;
    reg [6:0] offset_y, centre_y;
    
    reg err; 

    task3 DUT(.CLOCK_50(CLOCK_50),
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

    // This task checks the outputs of the task3 module against expected values, VGA_COLOUR, VGA_X, VGA_Y, and VGA_PLOT
    task task3_checker;
    
        input [2:0] expected_vga_colour;
        input [7:0] expected_vga_x;
        input [6:0] expected_vga_y;   
        input expected_vga_plot;

        if(tb_syn_task3.DUT.VGA_COLOUR != expected_vga_colour) begin
            $display("error: vga_colour is: %b, expected: %b", tb_syn_task3.DUT.VGA_COLOUR, expected_vga_colour);
            err = 1'b1;
        end

        if(tb_syn_task3.DUT.VGA_X != expected_vga_x) begin
            $display("error: vga_x is %d, expected: %d", tb_syn_task3.DUT.VGA_X, expected_vga_x);
            err = 1'b1;
        end

        if(tb_syn_task3.DUT.VGA_Y != expected_vga_y) begin
            $display("error: vga_y is %d, expected: %d", tb_syn_task3.DUT.VGA_Y, expected_vga_y);
            err = 1'b1;
        end

        if(tb_syn_task3.DUT.VGA_PLOT != expected_vga_plot) begin
            $display("error: vga_plot is %b, expected: %b", tb_syn_task3.DUT.VGA_PLOT, expected_vga_plot);
            err = 1'b1;
        end

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

        task3_checker(3'b000, 8'd0, 7'd0, 1'b0);

        // Checks that the entire screen is initialized to black 
        for(logic [7:0] i = 8'b0; i <= 8'd159; i = i + 1'b1) begin
    
            for(logic [6:0] j = 7'b0; j <= 7'd119; j = j + 1'b1) begin

                    CLOCK_50 = ~CLOCK_50; // Rising edge

                    if(i == 8'd0 && j == 8'd0) begin
                        #1;
                        task3_checker(3'b000, 8'd0, 7'd1, 1'b1);
                        #4; 
                    end else begin
                        task3_checker(3'b000, i, j, 1'b1);
                        #5; 
                    end
                    CLOCK_50 = ~CLOCK_50; // Falling edge
                    #5;

            end  
        end

        // Initalize circle parameters - centre coordinates and offsets
        centre_x = 8'd80;
        centre_y = 7'd60;
        offset_x = 8'd40;
        offset_y = 7'd0;
        crit = -10'sd39;

        // Two clock cycles to compensate for delay between fillscreen finishing and start to be asserted for circle    
        CLOCK_50 = ~CLOCK_50; // Rising edge
        #5; 
        CLOCK_50 = ~CLOCK_50; // Falling edge
        #5; 
        CLOCK_50 = ~CLOCK_50; // Rising edge
        #5; 
        CLOCK_50 = ~CLOCK_50; // Falling edge
        #5; 

        // Checks output of circle for each pixel until offset_y <= offset_x which means Bresenham's circle algorithm has finished
        while(offset_y <= offset_x) begin
            CLOCK_50 = ~CLOCK_50; // Rising edge
            #5;
            CLOCK_50 = ~CLOCK_50; // Falling edge
            task3_checker(3'b010, centre_x + offset_x, centre_y + offset_y, 1'b1); 
            #5; 
            CLOCK_50 = ~CLOCK_50; // Rising edge
            #5; 
            CLOCK_50 = ~CLOCK_50; // Falling edge 
            task3_checker(3'b010, centre_x + offset_y, centre_y + offset_x, 1'b1); 
            #5; 
            CLOCK_50 = ~CLOCK_50; // Rising edge
            #5; 
            CLOCK_50 = ~CLOCK_50; // Falling edge 
            task3_checker(3'b010, centre_x - offset_x, centre_y + offset_y, 1'b1); 
            #5; 
            CLOCK_50 = ~CLOCK_50; // Rising edge
            #5; 
            CLOCK_50 = ~CLOCK_50; // Falling edge 
            task3_checker(3'b010, centre_x - offset_y, centre_y + offset_x, 1'b1); 
            #5; 
            CLOCK_50 = ~CLOCK_50; // Rising edge
            #5; 
            CLOCK_50 = ~CLOCK_50; // Falling edge 
            task3_checker(3'b010, centre_x - offset_x, centre_y - offset_y, 1'b1); 
            #5; 
            CLOCK_50 = ~CLOCK_50; // Rising edge
            #5; 
            CLOCK_50 = ~CLOCK_50; // Falling edge 
            task3_checker(3'b010, centre_x - offset_y, centre_y - offset_x, 1'b1); 
            #5; 
            CLOCK_50 = ~CLOCK_50; // Rising edge
            #5; 
            CLOCK_50 = ~CLOCK_50; // Falling edge 
            task3_checker(3'b010, centre_x + offset_x, centre_y - offset_y, 1'b1);
            //subtract = (tb_syn_task3.DUT.o.crit >= 8'sd0) ? -8'd1 : 8'd0;
            #5; 
            CLOCK_50 = ~CLOCK_50; // Rising edge
            #5; 
            CLOCK_50 = ~CLOCK_50; // Falling edge  
            task3_checker(3'b010, centre_x + offset_y, centre_y - offset_x, 1'b1); 
            #5; 
            offset_y++;
            if(crit <= 10'sd0) 
                crit = crit + (10'sd2 * offset_y) + 10'sd1; 
            else begin
                offset_x--;
                crit = crit + (10'sd2 * (offset_y - offset_x)) + 10'sd1;
            end
        end

        $stop; // End simulation
    end


endmodule: tb_syn_task3
