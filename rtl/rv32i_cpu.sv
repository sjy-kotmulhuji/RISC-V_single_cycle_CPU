`timescale 1ns / 1ps
`include "define.vh"

module rv32i_cpu (
    input         clk,
    input         rst,
    input  [31:0] instr_data,
    input  [31:0] drdata,
    output [31:0] instr_addr,
    output        dwe,
    output [ 2:0] o_funct3,    //data memory 저장용 
    output [31:0] daddr,       //Data Memory Write Address  
    output [31:0] dwdata
);

    logic rf_we, branch;
    logic [3:0] alu_control;
    logic [2:0] rfwd_src;
    logic alu_src;

    control_unit U_CONTROL_UNIT (
        .funct7     (instr_data[31:25]),
        .funct3     (instr_data[14:12]),
        .opcode     (instr_data[6:0]),
        .rf_we      (rf_we),
        .branch     (branch),
        .jal        (jal),
        .jalr       (jalr),
        .alu_src    (alu_src),
        .alu_control(alu_control),
        .rfwd_src   (rfwd_src),
        .o_funct3   (o_funct3),
        .dwe        (dwe)
    );

    rv32i_datapath U_DATAPATH (.*);

endmodule

module control_unit (
    input        [6:0] funct7,
    input        [2:0] funct3,
    input        [6:0] opcode,
    output logic       rf_we,
    output logic       branch,
    output logic       jal,
    output logic       jalr,
    output logic       alu_src,
    output logic [3:0] alu_control,
    output logic [2:0] rfwd_src,
    output logic [2:0] o_funct3,
    output logic       dwe
);

    always_comb begin
        rf_we       = 1'b0;
        branch      = 1'b0;
        jal         = 1'b0;
        jalr        = 1'b0;
        alu_src     = 1'b0;
        alu_control = 4'b0000;
        rfwd_src    = 3'b000;
        o_funct3    = 3'b000;
        dwe         = 1'b0;
        case (opcode)
            `R_TYPE: begin  //to write register file, alu_control
                rf_we       = 1'b1;
                branch      = 1'b0;
                jal         = 1'b0;
                jalr        = 1'b0;
                alu_src     = 1'b0;
                alu_control = {funct7[5], funct3};
                dwe         = 1'b0;
                o_funct3    = 3'b000;
                rfwd_src    = 3'b000;
            end
            `B_TYPE: begin
                rf_we       = 1'b0;
                branch      = 1'b1;
                jal         = 1'b0;
                jalr        = 1'b0;
                alu_src     = 1'b0;
                alu_control = {1'b0, funct3};
                o_funct3    = 3'b000;
                dwe         = 1'b0;
                rfwd_src    = 3'b000;
            end

            `S_TYPE: begin
                rf_we       = 1'b0;
                branch      = 1'b0;
                jal         = 1'b0;
                jalr        = 1'b0;
                alu_src     = 1'b1;
                alu_control = `ADD;
                dwe         = 1'b1;
                o_funct3    = funct3;
                rfwd_src    = 3'b000;
            end
            `JL_TYPE: begin  //JALR rd = pc+4, pc = rs1 + imm
                rf_we       = 1'b1;
                branch      = 1'b0;
                jal         = 1'b1;
                jalr        = 1'b1;
                alu_src     = 1'b1;     //don't care
                alu_control = 4'b0000;  //don't care
                o_funct3    = 3'b000;
                dwe         = 1'b0;
                rfwd_src    = 3'b100;  //pc + 4
            end
            `IL_TYPE: begin //LB, LH, LW, LBU, LHU
                rf_we       = 1'b1;
                branch      = 1'b0;
                jal         = 1'b0;
                jalr        = 1'b0;
                alu_src     = 1'b1;
                alu_control = 4'b0000;
                o_funct3    = funct3;
                dwe         = 1'b0;
                rfwd_src    = 3'b001;
            end
            `I_TYPE: begin  //ADDI, SLTI,,,
                rf_we   = 1'b1;
                branch  = 1'b0;
                jal     = 1'b0;
                jalr    = 1'b0;
                alu_src = 1'b1;
                if (funct3 == 3'b101) alu_control = {funct7[5], funct3};
                else alu_control = {1'b0, funct3};
                o_funct3 = funct3;
                dwe      = 1'b0;
                rfwd_src = 3'b000;
            end
            `UL_TYPE: begin  //LUI rd = imm
                rf_we       = 1'b1;
                branch      = 1'b0;
                jal         = 1'b0;
                jalr        = 1'b0;
                alu_src     = 1'b1;
                alu_control = 4'b0000;  //don't care
                o_funct3    = 3'b000;
                dwe         = 1'b0;
                rfwd_src    = 3'b010;  //imm
            end
            `U_TYPE: begin  //AUIPC rd = pc + imm
                rf_we       = 1'b1;
                branch      = 1'b0;
                jal         = 1'b0;
                jalr        = 1'b0;
                alu_src     = 1'b1;     //don't care
                alu_control = 4'b0000;  //don't care
                o_funct3    = 3'b000;
                dwe         = 1'b0;
                rfwd_src    = 3'b011;  //pc + imm
            end
            `J_TYPE: begin  //JAL rd = pc+4, pc += imm
                rf_we       = 1'b1;
                branch      = 1'b0;
                jal         = 1'b1;
                jalr        = 1'b0;
                alu_src     = 1'b1;     //don't care
                alu_control = 4'b0000;  //don't care
                o_funct3    = 3'b000;
                dwe         = 1'b0;
                rfwd_src    = 3'b100;  //pc + 4
            end

        endcase
    end

endmodule


