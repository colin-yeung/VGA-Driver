module tb_task2();

        // Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.

        reg ClOCK_50, [3:0] KEY;
        reg [9:0] SW;  
        reg [9:0] LEDR;
        reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
        reg [7:0] VGA_R, VGA_G, VGA_B;
        reg VGA_HS, VGA_VS, VGA_CLK;
        reg [7:0] VGA_X;
        reg [6:0] VGA_Y;
        reg [2:0] VGA_COLOUR;
        reg VGA_PLOT;

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

        initial begin
                CLOCK_50 = 1'b0;
                forever begin
                        #5;
                        CLOCK_50 = ~CLOCK_50;
                end
        end

        initial begin

                $display("Testbench");

                #100; 
                KEY[3] = 1'b0; 
                #10; 
                KEY[3] = 1'b1;

                #100000;

        end



endmodule: tb_task2
