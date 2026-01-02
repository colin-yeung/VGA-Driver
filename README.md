# VGA-Driver

The VGA adapter displays a grid of 160×120 pixels, where the (x,y) position (0,0) is located on the top-left corner and (159,119) is at the other extreme end. The pixel colours are stored in on-chip memory.

Initially, all pixels have a value that depends on how the FPGA was powered up. To change the colour of a pixel, we write to the framebuffer memory by driving the x input with the x position of the pixel, drive the y input with the y position of the pixel, and colour with the colour desired. After positions and colour are set, drive the plot signal high. At the next rising clock edge, the new colour is written to the framebuffer. At some point in the near future, during the next screen refresh cycle, the entire framebuffer is read out and all of the then-current pixel colours will be drawn on the screen.
