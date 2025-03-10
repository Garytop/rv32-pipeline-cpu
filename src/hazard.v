`include "ctrl_encode_def.v"

module Hazard_Detect(
    input clk,     // new
    input [4:0] IF_ID_rs1,
    input [4:0] IF_ID_rs2,
    input [4:0] ID_EX_rd,
    input ID_EX_MemRead,    // load-use hazard
    // input branch_taken,     // branch hazard
    // input jal_taken,        // jal hazard

    output reg stall
    // output reg fflush,
    // output reg jal_flush
);

    always @(*) begin
        // default
        stall = 1'b0;

        // load-use hazard
        if (ID_EX_MemRead && ((ID_EX_rd != 0) && ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2)))) begin
            stall = 1'b1;
        end
        $display("stall=%b", stall);
    end
endmodule

module Forwarding(
    input EX_MEM_RegWrite,
    input MEM_WB_RegWrite,
    // input EX_MEM_MemWrite,
    input [4:0] EX_MEM_rd,
    input [4:0] MEM_WB_rd,
    input [4:0] ID_EX_rs1,
    input [4:0] ID_EX_rs2,

    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);

    // ForwardA
    always @(*) begin
        ForwardA = `forwarding_none;    // default

        // Top priority: EX/MEM(latest) EX/M -> EX
        if (EX_MEM_RegWrite && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs1)) begin
            ForwardA = `forwarding_typeA;   // choose EX/MEM as the source
        end
        // Second priority: MEM/WB(earlier) MEM/W -> EX
        else if (MEM_WB_RegWrite && (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rs1)) begin
            ForwardA = `forwarding_typeB;   // choose MEM/WB as the source
        end 
    end

    // ForwardB
    always @(*) begin
        ForwardB = `forwarding_none;    // default

        if(EX_MEM_RegWrite && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs2)) begin
            ForwardB = `forwarding_typeA;   // choose EX/MEM as the source
        end
        else if(MEM_WB_RegWrite && (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rs2)) begin
            ForwardB = `forwarding_typeB;   // choose MEM/WB as the source
        end
    end

endmodule