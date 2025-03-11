`include "ctrl_encode_def.v"

module ctrl(
    input  [6:0] Op,       // opcode
    input  [6:0] Funct7,   // funct7
    input  [2:0] Funct3,   // funct3
    input        Zero,
    output       RegWrite, // control signal for register write
    output       MemWrite, // control signal for memory write
    output       MemRead,  // control signal for memory read
    output [5:0] EXTOp,    // control signal to signed extension
    output [4:0] ALUOp,    // ALU operation
    output [4:0] NPCOp,    // next pc operation
    output       ALUSrc,   // ALU source for B 
    output [1:0] WDSel     // (register) write data selection
    
    // output branch_taken,   // branch hazard
    // output jal_taken      // jal hazard 
);

  // LUI
  wire LUI = ~Op[6] & Op[5] & Op[4] & ~Op[3] & Op[2] & Op[1] & Op[0];

  // r format 0110011
  wire rtype  = ~Op[6] & Op[5] & Op[4] & ~Op[3] & ~Op[2] & Op[1] & Op[0]; // 0110011
  wire i_add  = rtype & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; // add 0000000 000
  wire i_sub  = rtype & ~Funct7[6] &  Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; // sub 0100000 000
  wire i_or   = rtype & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] &  Funct3[2] &  Funct3[1] & ~Funct3[0]; // or 0000000 110
  wire i_and  = rtype & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] &  Funct3[2] &  Funct3[1] &  Funct3[0]; // and 0000000 111
  wire i_xor  = rtype & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] &  Funct3[2] & ~Funct3[1] & ~Funct3[0]; // xor 0000000 100
  wire i_sll  = rtype & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & ~Funct3[2] & ~Funct3[1] &  Funct3[0]; // sll 0000000 001
  wire i_srl  = rtype & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] &  Funct3[2] & ~Funct3[1] &  Funct3[0]; // srl 0000000 101
  wire i_sra  = rtype & ~Funct7[6] &  Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] &  Funct3[2] & ~Funct3[1] &  Funct3[0]; // sra 0100000 101
  wire i_slt  = rtype & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & ~Funct3[2] &  Funct3[1] & ~Funct3[0]; // slt 0000000 010
  wire i_sltu = rtype & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & ~Funct3[2] &  Funct3[1] &  Funct3[0]; // sltu 0000000 011

  // i format load 0000011
  wire itype_l = ~Op[6] & ~Op[5] & ~Op[4] & ~Op[3] & ~Op[2] &  Op[1] &  Op[0]; // 0000011

  // i format 0010011
  wire itype_r = ~Op[6] & ~Op[5] &  Op[4] & ~Op[3] & ~Op[2] &  Op[1] &  Op[0]; // 0010011
  wire i_addi  = itype_r & ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; // addi 000
  wire i_andi  = itype_r &  Funct3[2] &  Funct3[1] &  Funct3[0]; // andi 111
  wire i_ori   = itype_r &  Funct3[2] &  Funct3[1] & ~Funct3[0]; // ori 110
  wire i_xori  = itype_r &  Funct3[2] & ~Funct3[1] & ~Funct3[0]; // xori 100
  wire i_slti  = itype_r & ~Funct3[2] &  Funct3[1] & ~Funct3[0]; // slti 010
  wire i_sltui = itype_r & ~Funct3[2] &  Funct3[1] &  Funct3[0]; // sltui 011
  wire i_srli  = itype_r & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] &  Funct3[2] & ~Funct3[1] &  Funct3[0]; // srli 0000000 101
  wire i_srai  = itype_r & ~Funct7[6] &  Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] &  Funct3[2] & ~Funct3[1] &  Funct3[0]; // srai 0100000 101
  wire i_slli  = itype_r & ~Funct7[6] & ~Funct7[5] & ~Funct7[4] & ~Funct7[3] & ~Funct7[2] & ~Funct7[1] & ~Funct7[0] & ~Funct3[2] & ~Funct3[1] &  Funct3[0]; // slli 0000000 001


  // sb format 1100011
  wire sbtype =  Op[6] &  Op[5] & ~Op[4] & ~Op[3] & ~Op[2] &  Op[1] &  Op[0]; // 1100011
  wire i_beq  = sbtype & ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; // beq 000
  wire i_bne  = sbtype & ~Funct3[2] & ~Funct3[1] &  Funct3[0]; // bne 001
  wire i_bge  = sbtype &  Funct3[2] & ~Funct3[1] &  Funct3[0]; // bge 101
  wire i_bgeu = sbtype &  Funct3[2] &  Funct3[1] &  Funct3[0]; // bgeu 111
  wire i_blt  = sbtype &  Funct3[2] & ~Funct3[1] & ~Funct3[0]; // blt 100
  wire i_bltu = sbtype &  Funct3[2] &  Funct3[1] & ~Funct3[0]; // bltu 110

  // i format jalr 1100111
  wire i_jalr =  Op[6] &  Op[5] & ~Op[4] & ~Op[3] &  Op[2] &  Op[1] &  Op[0]; // jalr 1100111

  // j format jal 1101111
  wire i_jal  =  Op[6] &  Op[5] & ~Op[4] &  Op[3] &  Op[2] &  Op[1] &  Op[0]; // jal 1101111

  // s format 0100011
  wire stype  =  ~Op[6] &  Op[5] & ~Op[4] & ~Op[3] & ~Op[2] &  Op[1] &  Op[0]; // 0100011

  // Control signal generation
  assign RegWrite = rtype | itype_r | LUI | itype_l | i_jal | i_jalr; // register write
  assign MemWrite = stype; // memory write
  assign MemRead  = itype_l;              // memory read
  assign ALUSrc = itype_r | LUI | itype_l | stype | i_jal | i_jalr; // ALU B is from instruction immediate

  assign EXTOp[5] = i_srli | i_srai | i_slli | i_slti;
  assign EXTOp[4] = i_addi | itype_l | i_andi | i_ori | i_xori | i_sltui | i_jalr;
  assign EXTOp[3] = stype;
  assign EXTOp[2] = sbtype;
  assign EXTOp[1] = LUI;
  assign EXTOp[0] = i_jal;

  assign WDSel[1] = i_jal | i_jalr;
  assign WDSel[0] = itype_l;

  assign NPCOp[4] = 0;
  assign NPCOp[3] = 0;
  assign NPCOp[2] = i_jalr;
  assign NPCOp[1] = i_jal;
  assign NPCOp[0] = sbtype;

  // assign jal_taken = i_jal;

  // assign branch_taken = (sbtype & Zero);
  // always @(*) begin
  //   $write("branch_taken:%b\n", branch_taken);
  // end

  assign ALUOp[4] = i_srl | i_sra | i_srli | i_srai | i_bge | i_bgeu | i_blt | i_bltu | i_jal | i_jalr | i_bne | i_beq;
  assign ALUOp[3] = i_slt | i_sltu | i_xor | i_or | i_and | i_sll | i_ori | i_xori | i_slli| i_slti | i_sltui | i_andi | i_jalr | i_bne | i_beq;
  assign ALUOp[2] = i_sub | i_xor | i_or | i_and | i_sll | i_ori | i_xori | i_slli | i_andi | i_bgeu | i_blt | i_bltu | i_jal;
  assign ALUOp[1] = i_add | i_slt | i_sltu | i_sll | i_andi | i_slli | i_slti | i_sltui | i_and | itype_l | stype | i_jal | i_addi | i_bge | i_bltu | i_jal | i_beq;
  assign ALUOp[0] = LUI | i_add | i_sltu | i_or | i_sll | i_sra | i_ori | i_srai | i_slli | i_sltui | itype_l | stype | i_jal | i_addi | i_bge | i_blt | i_jal | i_bne;

  // always @(*) begin
  //   $write("ALUOp:%b\n", ALUOp);
  // end

  // always @(*) begin
  //   $write("NPCOp:%b\n", NPCOp);
  // end

endmodule
