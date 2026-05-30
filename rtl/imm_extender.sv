/*
`timescale 1ns / 1ps

module imm_extender (
    input [31:0] instr_data,
    output logic [31:0] imm_data
);

    // logic [11:0] imm;
    //
    // assign imm = {funct7, }
    //
    // always_comb begin
    // mm_out = {imm[11] * 21, imm[10:0]};
    // end

    always_comb begin
        imm_data = 32'd0;
        case (instr_data[6:0])
            `S_TYPE: begin
                imm_data = {
                    {20{instr_data[31]}}, instr_data[31:25], instr_data[11:7]
                };
            end
        endcase
    end
endmodule

module mux_2x1 (
    input [31:0] in0,
    input [31:0] in1,
    input mux_sel,
    output logic [31:0] out_mux
);

assign outmux = (mux_sel) ? in1 : in0;
    
endmodule
*/