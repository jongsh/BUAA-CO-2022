# P5 流水线 CPU 设计文档



## 一、指令分析

MIPS所有指令大致可分成三类，对它们做一一分析。

### 1.1 R 型指令

R型指令的指令格式为：

```
[31:26]op（R型指令全0
[25:21]rs（源操作数
[20:16]rt（源操作数
[15:11]rd（目的操作数
[10:6]shamt（位移量
[5:0]func（辅助op决定指令类型） 
```

R 型指令又可具体分成三种: 

1. 第一种类似 `add` 指令 两个源寄存器 `rs` 和 `rt` 进行运算，结果存到第目标寄存器 `rd`，由 `func` 段决定具体功能，`shamt` 段全为 0
2. 第二种用于移位运算， 例如 `sll` 指令、`sra` 指令。此时 `shamt` 段指示移位量， `rs` 全为 0
3. 第三种就是 `jr` 指令， 只有 `op`、`rs`、`func` 段不为零



### 1.2 I 型指令

I 型指令格式为： 

```
[31:26]op（决定指令类型）
[25:21]rs（第一个源操作数）
[20:16]rt（目的操作数）
[15:0]immediate（第二个源操作数）
```

I 型指令具体又分成三种：

1. 第一种，类似 `addi` 指令，将 `rs` 与 `immediate` 做运算，结果存到目的寄存器 `rt` 中。
1. 第二种，类似于 `lw` 指令， 将 两个操作数 `rs`、`immediate` 直接相加作为数据段内存 RAM 的地址加以操作。
1. 第三种，例如 `beq` 指令， 对 `rs`、`rt` 作比较， 根据结果判断是否利用 `immediate` 段对pc做操作。



### 1.3 J 型指令

J 型指令的格式：

```
[31:26]op（决定指令类型）
[25:0]immediate（立即数）
```

J 型指令又细分两种：

1. 第一种如  `j`，根据 `immediate` 段直接得到 PC 的值。

2. 第二种如 `jal`, 功能类似上一条，但是多了一步，跳转之前会把当前 `PC+4` 存入 ra 寄存器 中

<br> 

## 二、模块设计

### 2.1 F 级模块
该级主要包含 IM、PC模块。

**IM：**存放指令的存储器。

  | 端口  | 方向  | 功能  |
  |---|---|---|
  |F_PC|input[31:0]|F级指令所在的地址|
  |F_instr| output[31:0] |F级32位指令机器码，为IM[F_PC[13:2]]|

**PC：**F 级指令的地址寄存器。

| 端口  | 方向  | 功能  |
|---|---|---|
|clk|input|时钟控制信号，上升沿写入|
|reset|input|同步复位信号|
|F_PC_EN|input|PC模块使能端，高电平有效，用于阻塞|
|F_PCnext|input[31:0]|F级的下一条指令地址|
|F_PC|output[31:0]|当前F级的指令所在地址，流水进入下一级|

对于 **PC 模块的输入端口 F_PCnext 来自 D 级的 NPC 模块输出**。这是因为 PC 的下一条取值只有在译码阶段才能确定，包括分支指令的条件判断也都在 D 级中实现。更重要的一点在于，PC 的下一取值实际上只有两种，**一种是当前 F_PC 加 4，另一种是跳转**。而在跳转时，本实验采用了**延迟槽**，也就是跳转前会执行当前指令的下一条指令，一般为 nop 指令，所以当前 F 级信号流入 D 级时，D 级产生的 D_NPC_PCnext 为 F_PC + 4，更新成新的 F_PC 不会出错。




### 2.2 D 级模块

该级包括 EXT、NPC、GRF、CMP 、CU、F_D_REG 模块。

**EXT：**用于进行立即数扩展。

| 端口  | 方向  | 功能  |
|---|---|---|
|D_EXT_imm16|input[15:0]|用于被扩展的16位立即数|
|D_EXTop|input[3:0]|EXT 模块功能选择控制信号： **0000：符号扩展；0001：无符号扩展; 0010: 低位补0；0011：低位补1**|
|D_EXT_imm32|output[31:0]|扩展得到的 32 位结果|

**CMP：**得到两个源操作数的比较结果。

  | 端口  | 方向  | 功能  |
  |---|---|---|
  |D_CMP_opA|input[31:0]|32位源操作数A|
  |D_CMP_opB|input[31:0]|32位源操作数B|
  |D_CMPop|input[3:0]|CMP模块功能选择控制信号:**0000：A=?=B; 0001；A<?B有符号; 0010: A>?B有符号;  0011：A<?B无符号; 0100: A>?B无符号; 0101：A!=B？**|
  |D_CMP_result|output[31:0]|比较结果|

为了提高 CPU 吞吐率，将比较功能从 ALU 中分离出来，这是**为了实现在 D级就能够判断下一条指令地址**而做的改变。输出结果为32位，主要是为了方便 slt 这样的指令实现。CMP 的比较结果会流水到 E 级，与 ALU 的计算结果做选择流入下一级。

**GRF：**寄存器文件，存储寄存器数据。

  | 端口  | 方向  | 功能  |
  |---|---|---|
  |clk|input|时钟控制信号|
  |reset|input|同步复位信号|
  |GRF_write|input|写控制信号，高电平有效|
  |GRF_A1|input[4:0]|第一个读寄存器地址|
  |GRF_A2|input[4:0]|第二个读寄存器地址|
  |GRF_A3|input[4:0]|写寄存器的地址|
  |GRF_WD|input[31:0]|写寄存器的32位数据|
  |GRF_RD1|output[31:0]|第一个读寄存器的数据|
  |GRF_RD2|output[31:0]|第二个读寄存器的数据|

在 GRF 中，**支持内部转发**，即在模块内自行判断 A3 和 A1， A2 相同的情况。

**NPC：**根据指令译码结果，计算下一条进入流水线的指令地址。

  | 端口  | 方向  | 功能  |
  |---|---|---|
  |D_NPC_PC|input[31:0]|NPC 模块计算的基地址|
  |D_NPCop|input[3:0]|NPC 模块功能控制信号：**0000：PC+4； 0001： PC+4+signed[imm16]+00; 0010: PC[31:28]+imm26+00; 0011：regdata**|
  |D_NPC_imm16|input[15:0]|指令16位立即数|
  |D_NPC_imm26|input[25:0]|指令26位立即数|
  |D_CMP_result|input[31:0]|CMP 的比结果|
  |D_NPC_RegData|input[31:0]|寄存器存储的跳转地址|
  |D_NPC_PCnext|output[31:0]|计算得到的新PC|

**F_D_REG：**F 到 D级流水线寄存器。

  | 端口  | 方向  | 功能  |
  |---|---|---|
  |clk|input|时钟控制信号|
  |reset|input|高电平有效，同步复位信号，用于清空寄存器|
  |F_D_GRF_EN|input|高电平有效，寄存器使能信号|
  |F_PC|input[31:0]|F 级的指令地址|
  |F_instr|input[31:0]|F 级的指令机器码|
  |D_PC|output[31:0]|D 级的指令地址|
  |D_instr|output[31:0]|D 级的指令机器码|

**CU：**集中式译码，产生指令流水过程的各种控制信号，不包括冲突控制信号。

  | 端口  | 方向  | 功能  |
  |---|---|---|
  |D_CU_opcode|input[5:0]|指令的opcode字段|
  |D_CU_func|input[5:0]|指令|
  |D_EXTop|output[3:0]|D 级指令产生的 EXT 控制信号：**0000：符号扩展；0001：无符号扩展; 0010: 低位补0；0011：低位补1**|
  |D_NPCop|output[3:0]|D 级指令产生的 NPC 控制信号：**0000：PC+4； 0001： PC+4+signed[imm16]+00; 0010: PC[31:28]+imm26+00; 0011：regdata**|
  |D_CMPop|output[3:0]|D 级指令产生的 CMP 控制信号：**0000：A=?=B; 0001；A<?B有符号; 0010: A>?B有符号;  0011：A<?B无符号; 0100: A>?B无符号; 0101：A!=B？**|
  |D_GRF_write|output|D 级指令产生的寄存器写信号，将流水至下一级|
  |D_ALUop|output[4:0]|D 级指令产生的 ALU 控制信号，将流水至下一级: **00000：A+B； 00001：A-B； 00010：A或B； 00011：A与B； 00100：B逻辑右移C; 00101: B逻辑左移C; 110: B算数右移C**|
  |D_DM_write|output|D 级指令产生的 DM 写信号，将流水至下一级|
  |D_GRF_DatatoReg|output[3:0]|D 级指令写入寄存器的数据选择信号：**0000：ALUout;  0001：DMout; 0010：PC+8; 0011：写入CMPresult**|
  |D_GRF_A3_sel|output[2:0]|D 级指令目的寄存器选择控制信号：**000：rd；001：rt；010：31号寄存器**|
  |D_ALU_Bsel|output[2:0]|D 级指令产生的 ALU B端口数据选择信号：**000：RD2 001：扩展后的32位立即数**|
  |D_rs_Tuse|output[3:0]|D 级指令rs段对应的寄存器使用所需时间|
  |D_rt_Tuse|output[3:0]|D 级指令rt段对应的寄存器使用所需时间|
  |D_Tnew|output[3:0]|D 级指令产生写入寄存器的数据所需时间|
  |D_DMop|output[1:0]|D 级指令产生的 DM 控制信号：**W(00)、H(01)、B(10)**|

由于采用无脑转发的冒险解决方式，如果某一个字段的寄存器不被用到，那么其 Tuse 设置为 7，避免被 AT 法误判产生阻塞信号。



### 2.3 E 级模块

该级主要包括 ALU、D_E_REG 模块

**ALU：**有计算功能的模块。

| 端口  | 方向  | 功能  |
|---|---|---|
|E_ALU_opA|input[31:0]|ALU 模块的第一个操作数|
|E_ALU_opB|input[31:0]|ALU 模块的第二个操作数|
|E_ALU_opC|input[4:0]|ALU 模块的第三个操作数，对应 R 型指令的shamt 字段|
|E_ALUop|input[4:0]|ALU 功能选择控制信号: **00000：A+B； 00001：A-B； 00010：A或B； 00011：A与B； 00100：B逻辑右移C; 00101: B逻辑左移C; 00110: B算数右移C**|
|E_ALU_result|output[31:0]|32位计算结果|

**D_E_REG：**D 到 E级流水线寄存器。

  | 端口  | 方向  | 功能  |
  |---|---|---|
  |clk|input|时钟控制信号|
  |reset|input|高电平有效，同步复位信号，用于清空寄存器|
  |D_E_GRF_EN|input|高电平有效，使能信号|
  |D_PC|input[31:0]|D 级的指令地址|
  |D_instr|input[31:0]|D 级的指令机器码|
  |D_ALUop|input[4:0]|D 级指令产生的 ALU 控制信号|
  |D_DM_write|input|D 级指令产生的 DM 写信号|
  |D_GRF_write|input|D 级指令产生的 GRF 写信号|
  |D_RD1|input[31:0]|从寄存器读出的第一个数据，已经过一次转发|
  |D_RD2|input[31:0]|从寄存器读出的第二个数据，已经过一次转发|
  |D_instr_shamt|input[4:0]|D 级指令 shamt 段数据|
  |D_EXT_imm32|input[31:0]|D 级 EXT 扩展的32位立即数|
  |D_GRF_A3|input[4:0]|D 级指令的目的寄存器地址|
  |D_CMP_result|input[31:0]|D 级指令 CMP 比较结果|
  |D_GRF_DatatoReg|input[3:0]|D 级指令写入寄存器的数据选择信号|
  |D_ALU_Bsel|input[2:0]|D 级指令产生的 ALU B端口数据选择信号|
  |D_DMop|input[1:0]|D 级指令的 DM 控制信号|
  |D_rs_Tuse|input[3:0]|D 级指令rs段对应的寄存器使用所需时间|
  |D_rt_Tuse|input[3:0]|D 级指令rt段对应的寄存器使用所需时间|
  |D_Tnew|input[3:0]|D 级指令得到写入寄存器的数据所需时间|
  |E_RD1|output[31:0]|从 D 级流水至 E 级的第一个寄存器数据|
  |E_RD2|output[31:0]|从 D 级流水至 E 级的第二个寄存器数据|
  |E_instr_shamt|output[4:0]|E 级指令 shamt 段数据|
  |E_EXT_imm32|output[31:0]|从 D 级流水至 E 级的扩展后的32位立即数|
  |E_GRF_A3|output[4:0]|E 级指令的目的寄存器地址|
  |E_PC|output[31:0]|E 级的指令地址|
  |E_instr|output[31:0]|E 级的指令机器码|
  |E_ALUop|output[31:0]|E 级指令产生的 ALU 控制信号|
  |E_DM_write|output|E 级指令产生的 DM 写信号|
  |E_GRF_write|output|E 级指令产生的 GRF 写信号|
  |E_CMP_result|output[31:0]|E 级指令 CMP 比较结果|
  |E_GRF_DatatoReg|output[3:0]|E 级指令写入寄存器的数据选择信号|
  |E_ALU_Bsel|output[2:0]|E 级指令产生的 ALU B端口数据选择信号|
  |E_DMop|output[1:0]|E 级指令的 DM 控制信号|
  |E_rs_Tuse|output[3:0]|E 级指令rs段对应的寄存器使用所需时间|
  |E_rt_Tuse|output[3:0]|E 级指令rt段对应的寄存器使用所需时间|
  |E_Tnew|output[3:0]|E 级指令产生写入寄存器的数据所需时间|



### 2.4 M 级模块

该级主要包括 DM、E_M_REG 模块。

**DM：**数据存储器。

  | 端口  | 方向  | 功能  |
  |---|---|---|
  |clk|input|时钟控制信号|
  |reset|input|同步复位信号|
  |M_DM_write|input|DM 的写控制信号|
  |M_DMop|input[1:0]|DM数据处理类型，主要辨别 **W(00)、H(01)、B(10)** 类型指令|
  |M_DM_addr|input[31:0]|DM 输入地址信号|
  |M_DM_WD|input[31:0]|DM 32位写数据|
  |M_DM_ReadData|output[31:0]|DM 读出的数据|


**E_M_REG：**E 到 M级流水线寄存器。

  | 端口  | 方向  | 功能  |
  |---|---|---|
  |clk|input|时钟控制信号|
  |reset|input|同步复位信号，高电平有效|
  |E_M_REG_EN|input|高电平有效，使能信号|
  |E_PC|input[31:0]|E 级指令的地址|
  |E_instr|input[31:0]|E 级指令的32位机器码|
  |E_RD2|input[31:0]|E 级指令读出的第二个寄存器数据|
  |E_DM_write|input|E 级指令的 DM 写控制信号|
  |E_DMop|input[1:0]|E 级指令的 DM 控制信号|
  |E_ALUout|input[31:0]|E 级指令的 ALU 计算结果|
  |E_GRF_A3|input[4:0]|E 级指令的目的寄存器|
  |E_GRF_write|input|E 级指令的寄存器堆写信号|
  |E_GRF_DatatoReg|input[3:0]|E 级指令写入寄存器的数据选择信号|
  |E_CMP_result|input[31:0]|E 级指令 CMP 比较结果|
  |E_rs_Tuse|input[3:0]|E 级指令rs段对应的寄存器使用所需时间|
  |E_rt_Tuse|input[3:0]|E 级指令rt段对应的寄存器使用所需时间|
  |E_Tnew|input[3:0]|E 级指令产生写入寄存器的数据所需时间|
  |M_PC|output[31:0]|M 级指令的地址|
  |M_instr|output[31:0]|M 级指令的32位机器码|
  |M_RD2|output[31:0]|M 级指令读出的第二个寄存器数据|
  |M_ALUout|output[31:0]|M 级指令的 ALU 计算结果|
  |M_DM_write|output|M 级指令的 DM 写控制信号|
  |M_DMop|output[1:0]|M 级指令的 DM 控制信号|
  |M_GRF_A3|output[4:0]|M 级指令的目的寄存器|
  |M_GRF_write|output|M 级指令的寄存器堆写信号|
  |M_GRF_DatatoReg|output[3:0]|M 级指令写入寄存器的数据选择信号|
  |M_CMP_result|output[31:0]|M 级指令 CMP 比较结果|
  |M_rs_Tuse|output[3:0]|M 级指令rs段对应的寄存器使用所需时间|
  |M_rt_Tuse|output[3:0]|M 级指令rt段对应的寄存器使用所需时间|
  |M_Tnew|output[3:0]|M 级指令产生写入寄存器的数据所需时间|



### 2.5 W 级模块

该级主要包括 GRF、M_W_REG 模块

**M_W_REG：**M 到 W 级流水线寄存器。

  | 端口  | 方向  | 功能  |
  |---|---|---|
  |clk|input|时钟控制信号|
  |reset|input|同步复位信号，高电平有效|
  |M_W_REG_EN|input|高电平有效，使能信号|
  |M_PC|input[31:0]|M 级指令的地址|
  |M_instr|input[31:0]|M 级指令的32位机器码|
  |M_ALUout|input[31:0]|M 级指令的 ALU 计算结果|
  |M_GRF_A3|input[4:0]|M 级指令的目的寄存器|
  |M_DMout|input[31:0]|M 级指令从 DM 读出的数据|
  |M_GRF_write|input|M 级指令的寄存器堆写控制信号|
  |M_GRF_DatatoReg|input[3:0]|M 级指令写入寄存器的数据选择信号|
  |M_CMP_result|input[31:0]|M 级指令 CMP 比较结果|
  |M_rs_Tuse|input[3:0]|M 级指令rs段对应的寄存器使用所需时间|
  |M_rt_Tuse|input[3:0]|M 级指令rt段对应的寄存器使用所需时间|
  |M_Tnew|input[3:0]|M 级指令产生写入寄存器的数据所需时间|
  |W_PC|output[31:0]|W 级指令的地址|
  |W_instr|output[31:0]|W 级指令的32位机器码|
  |W_GRF_write|output|W 级指令的寄存器堆写控制信号|
  |W_GRF_A3|output[4:0]|W 级指令的目的寄存器|
  |W_GRF_DatatoReg|output[3:0]|W 级指令写入寄存器的数据选择信号|
  |W_ALUout|output[31:0]|W 级指令的 ALU 计算结果|
  |W_DMout|output[31:0]|W 级指令从 DM 读出的数据|
  |W_CMP_result|output[31:0]|W 级指令 CMP 比较结果|
  |W_rs_Tuse|output[3:0]|W 级指令rs段对应的寄存器使用所需时间|
  |W_rt_Tuse|output[3:0]|W 级指令rt段对应的寄存器使用所需时间|
  |W_Tnew|output[3:0]|W 级指令产生写入寄存器的数据所需时间|


**HCU：**冒险（hazard）控制单元，在下一部分重点分析

<br> 

## 三、冒险控制单元设计

在流水线 CPU 中最大最重要的问题就是冒险问题。为了解决这一问题，我专门设置了一个冒险控制单元，产生冒险控制信号。在我的设计中，冒险控制单元的逻辑全是基于 **AT 法**，属于无脑转发的方式。接下来从几个问题的回答来辅助设计冒险控制单元。

在流水线 CPU 中冒险的种类可以细分为：

* **结构冒险**：在 CO 实验体系结构中，结构冒险指寄存器文件需要在 D 级和 W 级同时被使用（读写）时并且读和写的寄存器为同一个寄存器时。本质还是一种数据冒险，我们采用 GRF 内部转发解决。
* **控制冒险**：指分支指令（如 beq ）的判断结果会影响接下来指令的执行流的情况。在判断结果产生之前，我们无法预测分支是否会发生。然而，此时流水线还会继续取指，让后续指令进入流水线。这时就有可能导致错误的产生，即不该被执行的指令进入到了指令的执行流中。课程选择了延迟槽来解决这一冒险。
* **数据冒险**：流水线之所以会产生数据冒险，就是因为后面指令需求的数据，正好就是前面指令供给的数据，而后面指令在需要使用数据时，前面供给的数据还没有存入寄存器堆，从而导致后面的指令不能正常地读取到正确的数据，这也是我们重点需要关注的冒险种类。

冒险的解决方案：

* **转发**：简而言之，转发就是前方流水中已经得到结果而当前阶段有需要，不等该结果写回寄存器而直接重定向到当前阶段，提高吞吐率。不难发现，需要转发的地方是需要寄存器数据的地方，主要在于 D 级和 E 级。能够提供转发数据的地方主在 E 级，M 级和 W 级。
* **阻塞**：阻塞是指当发生数据依赖时，只让前一条指令执行，而后一条指令被阻塞在流水线的某个阶段，并不向下执行，等待前一条指令执行完成（或者执行到没有冲突的时候），再解除后一条的阻塞状态。显然阻塞降低 CPU 的性能，所以只在必要时刻才阻塞。

什么时候转发和阻塞：

* **转发的需求者**应该在当前阶段需要用到寄存器的数据，有 D 级（CMP，NPC）、E 级（ALU）、E 级（DM）。
* **转发的供给者**应当在当前阶段的流水线寄存器中保存了会写入寄存器堆的数据。（*注意，本实验要求解决数据冒险而设计的转发数据来源必须是某级流水线寄存器，不允许对功能部件的输出直接进行转发。*）
* 可能写入寄存器堆的数据有 **E_CMP_result、E_PC+8、M_PC+8、M_ALUout、M_CMP_result、W_PC+8、W_ALUout、W_DMout、W_CMP_result**。
* 当前指令的所在阶段的 Tuse 大于等于之后流水线中指令的 Tnew 时，可以继续流水，反之则必须阻塞（实验要求阻塞必须在 D级）。这也意味着我们必须对处在 D 级的指令做好判断，如果阻塞，需要同时清空 E 级流水线寄存器（插入一个气泡）。

至此，我们就可以进行模块的设计：

| 端口  | 方向  | 功能  |
|---|---|---|
|D_instr|input[31:0]|用于解析 D 级指令的两个源寄存器编号 rs rt|
|D_rs_Tuse|input[3:0]|D 级指令 rs 寄存器使用时钟周期|
|D_rt_Tuse|input[3:0]|D 级指令 rt 寄存器使用时钟周期|
|E_instr|input[31:0]|用于解析 E 级指令的两个源寄存器编号 rs rt|
|E_rs_Tuse|input[3:0]|E 级指令 rs 寄存器使用时钟周期|
|E_rt_Tuse|input[3:0]|E 级指令 rt 寄存器使用时钟周期|
|E_Tnew|input[3:0]|E 级指令产生写入结果的时钟周期|
|M_instr|input[31:0]|用于解析 M 级指令的一 个源寄存器编号 rt|
|M_rt_Tuse|input[3:0]|M 级指令 rt 寄存器使用时钟周期|
|M_Tnew|input[3:0]|M 级指令产生写入结果的时钟周期|
|W_Tnew|input[3:0]|W 级指令产生写入结果的时钟周期|
|E_GRF_A3|input[4:0]|E 级指令的目的寄存器|
|E_GRF_write|input|用于判断 E 级指令是否为写寄存器指令|
|E_GRF_DatatoReg|input[3:0]|E 级指令写入寄存器的数据选择信号：**0000：ALUout;  0001：DMout; 0010：PC+8; 0011：写入CMPresult**|
|M_GRF_A3|input[4:0]|M 级指令的目的寄存器|
|M_GRF_write|input|用于判断 M 级指令是否为写寄存器指令|
|M_GRF_DatatoReg|input[3:0]|M 级指令写入寄存器的数据选择信号：**0000：ALUout;  0001：DMout; 0010：PC+8; 0011：写入CMPresult**|
|W_GRF_A3|input[4:0]|W 级指令的目的寄存器|
|W_GRF_write|input|用于判断 W 级指令是否为写寄存器指令|
|W_GRF_DatatoReg|input[3:0]|W 级指令写入寄存器的数据选择信号：**0000：ALUout;  0001：DMout; 0010：PC+8; 0011：写入CMPresult**|
|stall|output|阻塞信号，高电平有效，如果阻塞，则 stall 接到D_E_REG复位端，取反接到 PC 使能端，F_D_REG 使能端|
|D_FW_rs_sel|output[4:0]|D 级指令 rs 端寄存器转发选择信号：**00000: keep; 00001: E_PC+8; 00010: E_CMP_result; 00011: M_PC+8; 00100: M_ALUout; 00101: M_CMP_result**|
|D_FW_rt_sel|output[4:0]|D 级指令 rt 端寄存器转发选择信号：**00000: keep; 00001: E_PC+8; 00010: E_CMP_result; 00011: M_PC+8、00100: M_ALUout; 00101: M_CMP_result**|
|E_FW_rs_sel|output[4:0]|E 级指令 rs 端寄存器转发选择信号：**00000: keep; 00001: M_ALUout; 00010: M_PC+8; 00011: M_CMP_result; 00100: W_ALUout; 00101: W_DMout; 00110: W_PC+8; 00111: W_CMP_result**|
|E_FW_rt_sel|output[4:0]|E 级指令 rt 端寄存器转发选择信号：**00000: keep; 00001: M_ALUout; 00010: M_PC+8; 00011: M_CMP_result; 00100: W_ALUout; 00101: W_DMout; 00110: W_PC+8; 00111: W_CMP_result**|
|M_FW_rt_sel|output[4:0]|M 级指令 rt 端寄存器转发选择信号：**00000: keep; 00001: W_ALUout; 00010: W_DMout; 00011: W_PC+8; 00100: W_CMP_result**|
|E_flush|output|E 级流水线寄存器的清空信号|

<br> 

## 四、指令实现

**ori 指令：**
功能描述 : GPR[rt] <- GPR[rs] OR unsignedextend(immediate)

|op|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|001101|1|0|001|0000|0001|00010|00|0000|0000|001|4'd1|4'd7|4'd2|

**lui 指令：**
功能描述：GPR[rt] <- immediate||16'd0

|op|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|001111|1|0|001|0000|0010|00000|00|0000|XXXX|001|4'd1|4'd7|4'd2|

**jal 指令：**
功能描述：PC <- (PC[31:28] || instr_immediate || 00); GPR[31] <- PC + 4

|op|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|000011|1|0|010|0010|XXXX|XXXXX|00|0010|XXXX|000|4'd7|4'd7|4'd1|

**jr 指令：**
功能描述：PC <- GPR[rs]

|op|func|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|000000|001000|0|0|XXX|XXXX|XXXX|XXXXX|00|0011|XXXX|000|4'd0|4'd7|4'd0|

**add 指令：**
功能描述：GPR[rd] <- GPR[rs]+GPR[rt]

|op|func|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|000000|100000|1|0|000|0000|XXXX|00000|00|0000|XXXX|000|4'd1|4'd1|4'd2|

**sub 指令：**
功能描述 GPR[rd] <- GPR[rs] - GPR[rt]

|op|func|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|000000|100010|1|0|000|0000|XXXX|00001|00|0000|XXXX|000|4'd1|4'd1|4'd2|

**beq 指令：**
功能描述：if (GPR[rs] == GPR[rt]) PC <- PC + 4 + sign_extend(offset||00) else PC <- PC + 4

|op|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|000100|0|0|XXX|XXXX|XXXX|XXXXX|00|0001|0000|XXX|4'd0|4'd0|4'd0|

**lw 指令：**
功能描述：GPR[rt] <= memory[GPR[rs]+offset]

|op|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|100011|1|0|001|0001|0000|00000|00|0000|0000|001|4'd1|4'd7|4'd3|

**sw 指令：**
功能描述：memory[GPR[rs]+offset] <- GPR[rt]

|op|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|101011|0|1|XXX|XXXX|0000|00000|00|0000|XXXX|001|4'd1|4'd2|4'd0|

<br> 


## 五、测试方案

~~由于不懂自动化，只能选择手动构造数据~~

测试样例主要分两部分，一种是测试单一指令的正确性，一种测试冒险的处理。单一指令的测试可以沿用之前 project 的数据，只需要在指令间多加几个 nop 即可。

|指令|rs_Tuse|rt_Tuse|Tnew|
|:-:|:-:|:-:|:-:|
|add|1|1|2|
|sub|1|1|2|
|ori|1|X|2|
|lui|1|X|2|
|lw|1|X|3|
|sw|1|2|X|
|beq|0|0|X|
|jal|X|X|1|
|jr|0|X|X|

类1：不需要寄存器数据的指令：jal

类2：Decode 阶段需要寄存器数据的指令：jr、beq

类3：Execute 阶段需要寄存器数据的指令：add、sub、ori、lui、lw、sw

类4：Memory 阶段需要寄存器数据的指令：sw

类5：不产生写寄存器数据的指令：beq、sw、jr

类6：Execute 阶段才产生稳定写数据的指令：jal

类7：Memory 阶段才产生稳定写数据的指令：add、sub、ori、lui

类8：WriteBack 阶段才产生稳定写数据的指令：lw

**测试代码**：

  - **E 阻塞 D**：  类7/类8 + 类2
  - **M 阻塞 D**：  类8 + 无数据冒险 + 类2/类3
  - **E 转发 D**:   类6 + 类2/类3/类4
  - **M 转发 D**:   类7/类6 + 无数据冒险 + 类2/类3/类4
  - **W 转发 D**：  类8/类7/类6 + 无数据冒险 + 无数据冒险 + 类2/类3/类4
  - **特殊情况**：  测试 0 号寄存器的数据冒险

<br> 


## 六、思考题解答
**Q1**：我们使用提前分支判断的方法尽早产生结果来减少因不确定而带来的开销，但实际上这种方法并非总能提高效率，请从流水线冒险的角度思考其原因并给出一个指令序列的例子。

**A**：由于分支指令需要用到寄存器的数据，而且在 Decode 阶段就需要使用。而对于大多数指令而言，产生写入数据结果往往在 Execute 和 Memory 阶段，这样意味着如果分支指令前的指令写入数据没有到达 E 级，就需要阻塞 D 级指令，即阻塞下一条指令进入 CPU。这反而降低了效率。下面给出一个指令序列的例子。

```assembly
ori $t1, $t1, 10
sw $t1, 0($0)
lw $t2, 0($0)
beq $t1, $t2, target
nop
target: 
nop
```


**Q2**：因为延迟槽的存在，对于 jal 等需要将指令地址写入寄存器的指令，要写回 PC + 8，请思考为什么这样设计？

**A**：因为延迟槽的存在，所以跳转分支指令的下一条指令一定会被执行，所以我们写入PC+8，避免跳转回来再次执行延迟槽中的指令，而是直接执行第一条没有被执行的指令。



**Q3**：我们要求大家所有转发数据都来源于流水寄存器而不能是功能部件（如 DM 、ALU ），请思考为什么？

**A**：流水线和多周期 CPU 的性能很大一部分在于把指令分成若干个阶段，从而降低各个阶段的关键路径长度，减少时钟周期。如果转发数据来源功能部件，意味转发需求者需要等待转发供给者所在阶段快结束时产生相应数据，无疑大大拉长了需求者关键路径长度，也就必须增大时钟周期，违背了流水线设计的初衷。



**Q4**：我们为什么要使用 GPR 内部转发？该如何实现？

**A**：使用 GRF 内部转发内部可以解决 D 和 W 的冒险问题。这样做的好处是减少冒险控制单元的工作，另一点在于由于写入 GRF 的数据和地址都是经过选择后的，在内部实现转发非常方便。实现方式代码如下

```verilog
always @(*) begin
   if (GRF_A3 == GRF_A1 && GRF_A3 != 5'd0 && GRF_write == 1'b1) begin
      GRF_RD1 = GRF_WD;
    end else begin
      GRF_RD1 = reg_GRF[GRF_A1];
    end
  
    if (GRF_A3 == GRF_A2 && GRF_A3 != 5'd0 && GRF_write == 1'b1) begin
      GRF_RD2 = GRF_WD;
    end else begin
      GRF_RD2 = reg_GRF[GRF_A2];
    end
end

// 或者
assign GRF_RD1 = (GRF_A3 == GRF_A1 && GRF_A3 != 5'd0 && GRF_write == 1'b1) ? GRF_WD : reg_GRF[GRF_A1];
assign GRF_RD2 = (GRF_A3 == GRF_A2 && GRF_A3 != 5'd0 && GRF_write == 1'b1) ? GRF_WD : reg_GRF[GRF_A2];
```


**Q5**：我们转发时数据的需求者和供给者可能来源于哪些位置？共有哪些转发数据通路？

**A**：转发的需求者应该在当前阶段需要用到寄存器的数据，有 D 级（CMP，NPC）、E 级（ALU）、E 级（DM）。转发的供给者应当在当前阶段的流水线寄存器中保存了会写入寄存器堆的数据，有 E 级，M 级，W 级的流水线寄存器。转发的数据通路有 E_CMP_result、E_PC+8、M_PC+8、M_ALUout、M_CMP_result、W_PC+8、W_ALUout、W_DMout、W_CMP_result。



**Q6**：在课上测试时，我们需要你现场实现新的指令，对于这些新的指令，你可能需要在原有的数据通路上做哪些扩展或修改？提示：你可以对指令进行分类，思考每一类指令可能修改或扩展哪些位置。

**A**：计算类的指令：需要拓展 ALU 模块的功能，拓展 EXT 模块的功能。

条件写存储器的指令：需要拓展 M 级流水线寄存器的功能，增加一些特判情况。

条件分支的指令：需要拓展 CMP 模块的功能，可能会要求增加清空延迟槽，此时就需要增加数据通路，使分支指令即将进入 E 阶段时给 D 级流水线级寄存器一个清空信号。这个时候需要增加控制器的输出结合阻塞信号来判断是否清空 D 级流水线寄存器



**Q7**：简要描述你的译码器架构，并思考该架构的优势以及不足。

**A**：我采用的是集中式译码。不足在于需要流水的信号太多，容易写错；另外对于一些条件型指令，就需要增加流水线寄存器的功能，会破坏功能的整体性。优势在于，一次译码，一直使用，减少耦合度，减少了增量开发的负担。

译码风格我选择控制信号驱动型。这种方法在指令数量较多时适用，且代码量易于压缩，便于增加指令。缺陷是如错添或漏添了某条指令，很难锁定出现错误的位置。
