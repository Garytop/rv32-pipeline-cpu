# rv32-pipeline-cpu

## Overview

该项目基于```risc-v 32```架构，构建能够处理30条指令以及处理数据冒险，load-use冒险，控制冒险。

## 项目细节

- 本项目在单周期cpu上进行改进
- 成功实现如下指令：

```plaintext
add, sub, xor, and, srl, sra, sll
lui, addi, lw, sw
slt, sltu
andi, ori, xori, srli, srai, slli, slti, sltui
beq, bne, bge, bgeu, blt, bltu
jal, jalr
```

- 能够正确处理流水线CPU中的数据冒险与分支控制冒险：
  - 数据旁路：实现MEM->EX, WB->EX, WB->MEM旁路
  - 冒险控制：检测到load-use数据冒险时进行阻塞
  - 指令清除：对B型和J型指令发生跳转时进行指令清除

- 目前可以通过如下测试：
  - fwd.dat
  - jmpflush.dat
  - jmpfwd0.dat
  - jmpfwd1.dat
  - rv32_pl_sim.dat
  - Test_30_Instr.dat
  - riscv_sidascsorting_sim.dat

## 实现

1. 修改对应的测试文件路径
2. 在ModelSim中进行仿真
3. 在rars或者mars上进行比对，注意选择```self-modifying code```并在```memory configuration```中选择```compact, text at address 0```

对饮测试文件路径：

```verilog
// plcomp_tb.v
initial begin
    // input instructions for simulation
    $readmemh("riscv_sidascsorting_sim.dat", plcomp.U_imem.RAM); //( 21 ins-25cycles )
    clk = 0;
    rstn = 1;
    #50 ;
    rstn = 0;
  end
// need to modify the file in readmemh
// test file path: /test/filename
```

---

本人第一次写CPU，有些代码有些冗余，可以自行修改，如有问题欢迎大家反应。
