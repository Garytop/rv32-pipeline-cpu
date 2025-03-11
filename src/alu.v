`include "ctrl_encode_def.v"

module alu(
    input  signed [31:0] A, B,
    input         [4:0]  ALUOp,
    output reg signed [31:0] C,
    output Zero,  // condition flag: set if condition is true for B-type instruction
    output reg flush
   //  output reg stall, // new add
   //  input [4:0] IF_ID_rs1,
   //  input [4:0] IF_ID_rs2,
   //  input [4:0] ID_EX_rd,
   //  input ID_EX_MemRead    // load-use hazard
);

    integer i;

    always @( * ) begin
        case ( ALUOp )
            `ALUOp_lui : begin C = B; flush = 1'b0; end
            `ALUOp_add : begin C = A + B; flush = 1'b0; end
            `ALUOp_sub : begin C = A - B; flush = 1'b0; end  // delete beq
            `ALUOp_xor : begin C = A ^ B; flush = 1'b0; end
            `ALUOp_or  : begin C = A | B; flush = 1'b0; end
            `ALUOp_and : begin C = A & B; flush = 1'b0; end
            `ALUOp_sll : begin C = A << B; flush = 1'b0; end
            `ALUOp_srl : begin C = A >> B; flush = 1'b0; end
            `ALUOp_sra : begin C = A >>> B; flush = 1'b0; end
            `ALUOp_slt : begin C = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0; flush = 1'b0; end
            `ALUOp_sltu: begin C = ($unsigned(A) < $unsigned(B)) ? 32'b1 : 32'b0; flush = 1'b0; end
            `ALUOp_andi: begin C = A & B; flush = 1'b0; end
            `ALUOp_ori : begin C = A | B; flush = 1'b0; end
            `ALUOp_xori: begin C = A ^ B; flush = 1'b0; end
            `ALUOp_srli: begin C = A >> B; flush = 1'b0; end
            `ALUOp_srai: begin C = A >>> B; flush = 1'b0; end
            `ALUOp_slli: begin C = A << B; flush = 1'b0; end
            `ALUOp_slti: begin C = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0; flush = 1'b0; end
            `ALUOp_beq : begin C = {28'h0000000, 3'b000, (A != B)}; flush = (A == B); end
            `ALUOp_bne : begin C = {28'h0000000, 3'b000, (A == B)}; flush = (A != B); end 
            `ALUOp_bge : begin C = {28'h0000000, 3'b000, (A < B)}; flush = (A >= B); end
            `ALUOp_bgeu: begin C = {28'h0000000, 3'b000, ($unsigned(A) < $unsigned(B))}; flush = ($unsigned(A) > $unsigned(B)); end
            `ALUOp_blt : begin C = {28'h0000000, 3'b000, (A >= B)}; flush = (A < B); end 
            `ALUOp_bltu: begin C = {28'h0000000, 3'b000, ($unsigned(A) >= $unsigned(B))}; flush = ($unsigned(A) < $unsigned(B)); end
            `ALUOp_jal : begin C = A; flush = 1'b1; end
            `ALUOp_jalr: begin C = A + B; flush = 1'b1; end
            default    : begin C = A; flush = 1'b0; end
        endcase
    end // end always

    assign Zero = (C == 32'b0);

    // always @(*) begin
    //     $display("flush: %b", flush);
    //     $display("aluop: %b", ALUOp);
    //     $display("A: %d, B: %d, C: %d", A, B, C);
    // end

endmodule

