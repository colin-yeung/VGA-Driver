// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.

`timescale 1 ps/ 1 ps

module tb_rtl_fillscreen();

        reg clk, rst_n, start, done, vga_plot;
        reg [2:0] colour, vga_colour;
        reg [7:0] vga_x;
        reg [6:0] vga_y;

        reg err; 
        reg [7:0] expected_x;
        reg [6:0] expected_y;
    
        fillscreen DUT(
            .clk(clk),
            .rst_n(rst_n),
            .colour(colour),
            .start(start),
            .done(done),
            .vga_x(vga_x),
            .vga_y(vga_y),
            .vga_colour(vga_colour),
            .vga_plot(vga_plot)
        );

        // This task checks the ouputs of fillscreen to the expected values, colour, vga_x, vga_y, and done
        task check_screen;
        
                input [2:0] expected_colour;
                input [7:0] expected_x;
                input [6:0] expected_y;
                input expected_done; 

                if(tb_rtl_fillscreen.DUT.colour != expected_colour) begin
                    $display("error, colour is: %b, expect: %b", tb_rtl_fillscreen.DUT.colour, expected_colour);
                     err = 1'b1;
                end
                if(tb_rtl_fillscreen.DUT.vga_x != expected_x) begin
                    $display("Error, vga_x is %b, expected %b", tb_rtl_fillscreen.DUT.vga_x, expected_x);
                    err = 1'b1; 
                end

                if(tb_rtl_fillscreen.DUT.vga_y != expected_y) begin
                    $display("Error, vga_y is %b, expected %b", tb_rtl_fillscreen.DUT.vga_y, expected_y);
                    err = 1'b1; 
                end

                if(tb_rtl_fillscreen.DUT.done != expected_done) begin
                    $display("Error, done is %b, expected %b", tb_rtl_fillscreen.DUT.done, expected_done);
                    err = 1'b1; 
                end

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

            start = 1'b0;

            // Initialize expected x/y
            expected_x = 8'b0;
            expected_y = 7'b0;
            #15;
            start = 1'b1;


            // Loop through all x and y coordinates and check output at each
            for(logic [7:0] i = 8'b0; i <= 8'd159; i = i + 1'b1) begin
                if(expected_y == 7'd119)
                    #10;
                expected_y = 7'b0;
                for(logic [6:0] j = 7'b0; j < 7'd119; j = j + 1'b1) begin
                    if(!(i == 8'b0 && j == 7'b0)) 
                        check_screen(expected_x % 8, expected_x, expected_y, 1'b0);
                    expected_y = expected_y + 1'b1;
                    #10;
                end
                
                if(expected_x < 8'd159)
                    expected_x = expected_x + 1'b1;   
            end

            // Reset back to 0
            expected_x = 8'b0;
            expected_y = 7'b0;

            #10;
            check_screen(expected_x % 8, expected_x, expected_y, 1'b1);

            $stop;
            
        end

endmodule: tb_rtl_fillscreen