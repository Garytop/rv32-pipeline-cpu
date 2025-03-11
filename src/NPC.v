`include "ctrl_encode_def.v"

module NPC(
    input  [31:0] PC,        // pc
    input  [4:0]  NPCOp,     // next pc operation
    input  [31:0] IMM,       // immediate
    input  [31:0] ALUOut,    // register data specified by rs
    input         stall,     // stall signal
    output reg [31:0] NPC    // next pc
); 
   
   wire [31:0] PCPLUS4;
   assign PCPLUS4 = PC + 4; // pc + 4
  
   always @(*) begin
        if (stall) begin
            NPC = PC;
        end
        else begin
            case (NPCOp)
                `NPC_PLUS4:  NPC = PCPLUS4;   // NPC computes addr
                `NPC_BRANCH: NPC = PC + IMM - 8;  // B type, NPC computes addr
                `NPC_JUMP:   NPC = PC + IMM - 8;  // J type, NPC computes addr
                `NPC_JALR:   NPC = ALUOut; // JALR type, NPC computes addr
                default:     NPC = PCPLUS4;
            endcase
        end
    end // end always

    always @(*) begin
        $display("NPC: %h, NPCOp: %b", NPC, NPCOp);
    end

endmodule
