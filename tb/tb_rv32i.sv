`timescale 1ns / 1ps

module tb_rv32i ();
    logic clk, rst;
    logic [31:0] drdata;

    rv32i_top dut (.*);

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;

        @(negedge clk);
        @(negedge clk);
        rst = 0;

        repeat (200) @(negedge clk);
        $stop;
    end
endmodule
