# P6 流水线 CPU 设计文档



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

**IM**：存放指令的存储器。

| 端口  | 方向  | 功能  |
|---|---|---|
|i_inst_addr|input[31:0]|F级指令所在的地址|
|i_inst_rdata| output[31:0] |F级32位指令机器码，为 IM[F_PC[13:2]]|
在 P6 实验中 IM 已经外置。

i_inst_addr 连接 F_PC；i_inst_rdata[31:0] 连接 F_instr。

**PC**：F级指令的地址寄存器。

| 端口  | 方向  | 功能  |
|---|---|---|
|clk|input|时钟控制信号，上升沿写入|
|reset|input|同步复位信号|
|F_PC_EN|input|PC模块使能端，高电平有效，用于阻塞|
|F_PCnext|input[31:0]|F级的下一条指令地址|
|F_PC|output[31:0]|当前F级的指令所在地址，流水进入下一级|

对于 **PC 模块的输入端口 F_PCnext 来自 D 级的 NPC 模块输出**。这是因为 PC 的下一条取值只有在译码阶段才能确定，包括分支指令的条件判断也都在 D 级中实现。更重要的一点在于，PC 的下一取值实际上只有两种，**一种是当前 F_PC 加 4，另一种是跳转**。而在跳转时，本实验采用了**延迟槽**，也就是跳转前会执行当前指令的下一条指令，一般为 nop 指令,所以当前 F 级信号流入 D 级时，D 级产生的 D_NPC_PCnext 为 F_PC + 4,更新成新的 F_PC 不会出错。



### 2.2 D 级模块
该级包括 EXT、NPC、GRF、CMP 、CU、F_D_REG 模块。

**EXT**：用于进行立即数扩展。

| 端口  | 方向  | 功能  |
|---|---|---|
|D_EXT_imm16|input[15:0]|用于被扩展的16位立即数|
|D_EXTop|input[3:0]|EXT 模块功能选择控制信号： **0000：符号扩展；0001：无符号扩展; 0010: 低位补0；0011：低位补1**|
|D_EXT_imm32|output[31:0]|扩展得到的32位结果|

**CMP**：得到两个源操作数的比较结果。

| 端口  | 方向  | 功能  |
|---|---|---|
|D_CMP_opA|input[31:0]|32位源操作数A|
|D_CMP_opB|input[31:0]|32位源操作数B|
|D_CMPop|input[3:0]|CMP模块功能选择控制信号:**0000：A=?=B; 0001；A<?B有符号; 0010: A>?B有符号;  0011：A<?B无符号; 0100: A>?B无符号; 0101：A!=B？**|
|D_CMP_result|output[31:0]|比较结果|

为了提高 CPU 吞吐率，将比较功能从 ALU 中分离出来，这是**为了实现在 D级就能够判断下一条指令地址**而做的改变。

**GRF**：寄存器文件，存储寄存器数据。

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

**NPC**：根据指令译码结果，计算下一条进入流水线的指令地址。

| 端口  | 方向  | 功能  |
|---|---|---|
|D_NPC_PC|input[31:0]|NPC 模块计算的基地址|
|D_NPCop|input[3:0]|NPC 模块功能控制信号：**0000：PC+4； 0001： PC+4+signed[imm16]+00; 0010: PC[31:28]+imm26+00; 0011：regdata**|
|D_NPC_imm16|input[15:0]|指令16位立即数|
|D_NPC_imm26|input[25:0]|指令26位立即数|
|D_CMP_result|input[31:0]|CMP 的比结果|
|D_NPC_RegData|input[31:0]|寄存器存储的跳转地址|
|D_NPC_PCnext|output[31:0]|计算得到的新PC|

**F_D_REG**：F 到 D级流水线寄存器。

  | 端口  | 方向  | 功能  |
  |---|---|---|
  |clk|input|时钟控制信号|
  |reset|input|高电平有效，同步复位信号，用于清空寄存器|
  |F_D_GRF_EN|input|高电平有效，寄存器使能信号|
  |F_PC|input[31:0]|F 级的指令地址|
  |F_instr|input[31:0]|F 级的指令机器码|
  |D_PC|output[31:0]|D 级的指令地址|
  |D_instr|output[31:0]|D 级的指令机器码|

**CU**：集中式译码，产生指令流水过程的各种控制信号，不包括冲突控制信号。

| 端口  | 方向  | 功能  |
|---|---|---|
|D_CU_opcode|input[5:0]|指令的opcode字段|
|D_CU_func|input[5:0]|指令|
|D_EXTop|output[3:0]|D 级指令产生的 EXT 控制信号：**0000：符号扩展；0001：无符号扩展; 0010: 低位补0；0011：低位补1**|
|D_NPCop|output[3:0]|D 级指令产生的 NPC 控制信号：**0000：PC+4； 0001： PC+4+signed[imm16]+00; 0010: PC[31:28]+imm26+00; 0011：regdata**|
|D_CMPop|output[3:0]|D 级指令产生的 CMP 控制信号：**0000：A=?=B; 0001；A<?B有符号; 0010: A>?B有符号;  0011：A<?B无符号; 0100: A>?B无符号; 0101：A!=B？**|
|D_GRF_write|output|D 级指令产生的寄存器写信号，将流水至下一级|
|D_ALUop|output[4:0]|D 级指令产生的 ALU 控制信号，将流水至下一级: **00000：A+B； 00001：A-B； 00010：A或B； 00011：A与B； 00100：B逻辑右移C; 00101: B逻辑左移C; 00110: B算数右移C; 00111；A<?B有符号; 01000: A>?B有符号;  01001：A<?B无符号; 01010: A>?B无符号**|
|D_DM_write|output|D 级指令产生的 DM 写信号，将流水至下一级|
|D_GRF_DatatoReg|output[3:0]|D 级指令写入寄存器的数据选择信号：**0000：ALUout;  0001：DMout; 0010：PC+8; 0011：写入CMPresult; 0100：MDUout**|
|D_GRF_A3_sel|output[2:0]|D 级指令目的寄存器选择控制信号：**000：rd；001：rt；010：31号寄存器**|
|D_ALU_Bsel|output[2:0]|D 级指令产生的 ALU B端口数据选择信号：**000：RD2 001：扩展后的32位立即数**|
|D_rs_Tuse|output[3:0]|D 级指令rs段对应的寄存器使用所需时间|
|D_rt_Tuse|output[3:0]|D 级指令rt段对应的寄存器使用所需时间|
|D_Tnew|output[3:0]|D 级指令产生写入寄存器的数据所需时间|
|D_DMop|output[1:0]|D 级指令产生的 DM 控制信号：**W(00)、H(01)、B(10)**|
|D_BEop|output[2:0]|D 级指令产生的 BE 控制信号：**000：无扩展；001：无符号字节数据扩展；010：符号字节数据扩展；011：无符号半字数据扩展；100：符号半字数据扩展**|
|D_MDU_start|output|D 级指令的 MDU 开始工作信号|
|D_MDUop|output[3:0]|D 级指令的 MDU 功能选择信号：**0000：无操作；0001：符号乘 A*B；0010：无符号乘 A*B；0011：符号除 A/B； 0100：无符号除 A/B；0101：写 HI 寄存器；0110：写 LO 寄存器**|
|D_MDUout_sel|output|D 级指令 MDU 输出结果选择信号：**0：HI 寄存器；1：LO 寄存器**|

由于采用无脑转发的冒险解决方式，如果某一个字段的寄存器不被用到，那么其 Tuse 设置为 7，避免被 AT 法误判产生阻塞信号。



### 2.3 E 级模块
该级主要包括 ALU、D_E_REG、MDU 模块。

**ALU**：有计算功能的模块。

| 端口  | 方向  | 功能  |
|---|---|---|
|E_ALU_opA|input[31:0]|ALU 模块的第一个操作数|
|E_ALU_opB|input[31:0]|ALU 模块的第二个操作数|
|E_ALU_opC|input[4:0]|ALU 模块的第三个操作数，对应 R 型指令的shamt 字段|
|E_ALUop|input[4:0]|ALU 功能选择控制信号: **00000：A+B； 00001：A-B； 00010：A或B； 00011：A与B； 00100：B逻辑右移C; 00101: B逻辑左移C; 00110: B算数右移C**|
|E_ALU_result|output[31:0]|32位计算结果|

**D_E_REG**：D 到 E级流水线寄存器。

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
|D_MDU_start|input|D 级指令的 MDU 开始信号|
|D_MDUop|input[3:0]|D 级指令的 MDU 功能选择信号|
|D_MDUout_sel|input|D 级指令 MDU 输出结果选择信号|
|D_BEop|input[2:0]|D 级指令产生的 BE 控制信号|
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
|E_MDU_start|output|E 级指令的 MDU 开始信号|
|E_MDUop|output[3:0]|E 级指令的 MDU 功能选择信号|
|E_MDUout_sel|output|E 级指令 MDU 输出结果选择信号|
|E_BEop|output[2:0]|E 级指令产生的 BE 控制信号|
|E_DMop|output[1:0]|E 级指令的 DM 控制信号|
|E_rs_Tuse|output[3:0]|E 级指令rs段对应的寄存器使用所需时间|
|E_rt_Tuse|output[3:0]|E 级指令rt段对应的寄存器使用所需时间|
|E_Tnew|output[3:0]|E 级指令产生写入寄存器的数据所需时间|

**MDU**：乘除模块。

| 端口  | 方向  | 功能  |
|---|---|---|
|clk|input|时钟控制信号|
|reset|input|同步复位信号|
|start|input|表示 MDU 即将工作的信号，维持一周期|
|E_MDU_opA|input[31:0]|MDU 模块第一个操作数|
|E_MDU_opB|input[31:0]|MDU 模块第二个操作数|
|E_MDUop|input[3:0]|MDU 功能选择信号：**0000：无操作；0001：符号乘 A*B；0010：无符号乘 A*B；0011：符号除 A/B； 0100：无符号除 A/B；0101：写 HI 寄存器；0110：写 LO 寄存器**|
|busy|output|MDU 工作信号，高位表示正在使用|
|HI|output[31:0]|HI 寄存器的数据|
|LO|output[31:0]|LO 寄存器的数据|
乘除模块只会阻塞需要用到该模块的指令即 MULT、 MULTU、 DIV、 DIVU、MFHI、MFLO、MTHI、MTLO，其他指令可以从 D 级流水至 E 级，这就要求增加 HCU 的功能。



### 2.4 M 级模块
该级主要包括 DM、E_M_REG、DM_CU、BE模块。

**DM**：数据存储器。

| 端口  | 方向  | 功能  |
|---|---|---|
|m_inst_addr|input[31:0]|M 级 PC|
|m_data_byteen|input[3:0]|数据存储器功能选择信号，具体见下表|
|m_data_addr|input[31:0]|待写入/读出的数据存储器相应地址|
|m_data_wdata|input[31:0]|待写入数据存储器相应数据|
|m_data_rdata|output[31:0]|数据存储器存储的相应数据|

|byteen|功能|
|---|---|
|1111|**m_data_wdata[31:24]** 写入 **byte3**；**m_data_wdata[23:16]** 写入 **byte2**；**m_data_wdata[15:8]** 写入 **byte1**；**m_data_wdata[7:0]** 写入 **byte0**|
|0011|**m_data_wdata[15:8]** 写入 **byte1**；**m_data_wdata[7:0]** 写入 **byte0**|
|1100|**m_data_wdata[31:24]** 写入 **byte3**；**m_data_wdata[23:16]** 写入 **byte2**|
|0001| **m_data_wdata[7:0]** 写入 **byte0**|
|0010| **m_data_wdata[15:8]** 写入 **byte1**|
|0100| **m_data_wdata[23:16]** 写入 **byte2**|
|1000| **m_data_wdata[31:24]** 写入 **byte3**|

P6 实验中该模块已外置。由于 DM 写入地址只在 ALU 产生，因此需增加编码 m_data_byteen 的功能，因此将增加 DM_CU 模块。 

m_inst_addr 连接 M_PC；m_data_byteen 连接新增模块 DM_CU 的输出（M_byteen）；m_data_addr 连接 M_ALUout；m_data_wdata 连接 DM_CU 输出（M_DM_WD）；m_data_rdata 连接 M_BE_in。

**DM_CU**：DM 控制信号译码器。

| 端口  | 方向  | 功能  |
|---|---|---|
|M_DM_write|input|数据存储器写使能信号|
|M_RD2_new|input[31:0]|M 级转发后的 RD2|
|M_ALUout|input[31:0]|M 级指令产生的 ALU 计算结果|
|M_DMop|input[1:0]|M 级指令的 DM 控制信号,用于判断字，半字，字节指令|
|M_byteen|output[3:0]|四位字节使能|
|M_DM_WD|output[31:0]|经过处理的 DM 写数据，主要是配合DM规格的使用|

**BE**：数据存储器的数据扩展模块。

| 端口  | 方向  | 功能  |
|---|---|---|
|M_BE_addr|input[31:0]|从数据存储器读出的数据地址，连接ALUout|
|M_BE_in|input[31:0]|从数据存储器读出的数据|
|M_BEop|input[2:0]|BE 模块功能选择信号：**000：无扩展；001：无符号字节数据扩展；010：符号字节数据扩展；011：无符号半字数据扩展；100：符号半字数据扩展**|
|M_BEout|output[31:0]|扩展得到的32位数据，连接 M_DMout|

**E_M_REG**：E 到 M级流水线寄存器。

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
|E_BEop|input[2:0]|E 级指令产生的 BE 控制信号|
|E_MDUout|input[31:0]|E 级指令的MDU计算结果|
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
|M_BEop|output[2:0]|M 级指令产生的 BE 控制信号|
|M_MDUout|output[31:0]|M 级指令的MDU计算结果|
|M_GRF_A3|output[4:0]|M 级指令的目的寄存器|
|M_GRF_write|output|M 级指令的寄存器堆写信号|
|M_GRF_DatatoReg|output[3:0]|M 级指令写入寄存器的数据选择信号|
|M_CMP_result|output[31:0]|M 级指令 CMP 比较结果|
|M_rs_Tuse|output[3:0]|M 级指令rs段对应的寄存器使用所需时间|
|M_rt_Tuse|output[3:0]|M 级指令rt段对应的寄存器使用所需时间|
|M_Tnew|output[3:0]|M 级指令产生写入寄存器的数据所需时间|



### 2.5 W 级模块

该级主要包括 GRF、M_W_REG 模块。

**M_W_REG**：M 到 W 级流水线寄存器。

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
|M_MDUout|input[31:0]|M 级指令的MDU计算结果|
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
|W_MDUout|output[31:0]|W 级指令的MDU计算结果|
|W_CMP_result|output[31:0]|W 级指令 CMP 比较结果|
|W_rs_Tuse|output[3:0]|W 级指令rs段对应的寄存器使用所需时间|
|W_rt_Tuse|output[3:0]|W 级指令rt段对应的寄存器使用所需时间|
|W_Tnew|output[3:0]|W 级指令产生写入寄存器的数据所需时间|

**HCU**：冒险（hazard）控制单元，在下一部分重点分析。

<br> 

## 三、冒险控制单元设计

在流水线 CPU 中最大最重要的问题就是冒险问题。为了解决这一问题，我专门设置了一个冒险控制单元，产生冒险控制信号。在我的设计中，冒险控制单元的逻辑基于 **AT 法**，属于无脑转发的方式，同时，为了处理乘除指令的冲突，还需要根据 busy，start信号以及对 mflo，mfhi 作特判。接下来从几个问题的回答来辅助设计冒险控制单元。

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
* 可能写入寄存器堆的数据有 **E_CMP_result、E_PC+8、M_PC+8、M_ALUout、M_CMP_result、M_MDUout、W_PC+8、W_ALUout、W_DMout、W_CMP_result、W_MUDout**。
* 当前指令的所在阶段的 Tuse >= 之后流水线中指令的 Tnew 时，可以继续流水，反之则必须阻塞（实验要求阻塞必须在 D级）。这也意味着我们必须对处在 D 级的指令做好判断，如果阻塞，需要同时清空 E 级流水线寄存器（插入一个气泡）。

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
  |E_GRF_DatatoReg|input[3:0]|E 级指令写入寄存器的数据选择信号:**0000：ALUout;  0001：DMout; 0010：PC+8; 0011：写入CMPresult; 0100：MDUout**|
  |M_GRF_A3|input[4:0]|M 级指令的目的寄存器|
  |M_GRF_write|input|用于判断 M 级指令是否为写寄存器指令|
  |M_GRF_DatatoReg|input[3:0]|M 级指令写入寄存器的数据选择信号:**0000：ALUout;  0001：DMout; 0010：PC+8; 0011：写入CMPresult; 0100：MDUout**|
  |W_GRF_A3|input[4:0]|W 级指令的目的寄存器|
  |W_GRF_write|input|用于判断 W 级指令是否为写寄存器指令|
  |W_GRF_DatatoReg|input[3:0]|W 级指令写入寄存器的数据选择信号:**0000：ALUout;  0001：DMout; 0010：PC+8; 0011：写入CMPresult; 0100：MDUout**|
  |E_busy|input|E 级指令的 MDU 使用信号|
  |E_start|input|E 级指令的 MDU 开始使用信号|
  |D_start|input|D 级指令的 MDU 开始使用信号|
  |stall|output|阻塞信号，高电平有效，如果阻塞，则 stall 接到D_E_REG复位端，取反接到 PC 使能端，F_D_REG 使能端|
  |D_FW_rs_sel|output[4:0]|D 级指令 rs 端寄存器转发选择信号:**00000: keep; 00001: E_PC+8; 00010: E_CMP_result; 00011: M_PC+8; 00100: M_ALUout; 00101: M_CMP_result; 00110: M_MDUout**|
  |D_FW_rt_sel|output[4:0]|D 级指令 rt 端寄存器转发选择信号:**00000: keep; 00001: E_PC+8; 00010: E_CMP_result; 00011: M_PC+8、00100: M_ALUout; 00101: M_CMP_result; 00110: M_MDUout**|
  |E_FW_rs_sel|output[4:0]|E 级指令 rs 端寄存器转发选择信号:**00000: keep; 00001: M_ALUout; 00010: M_PC+8; 00011: M_CMP_result; 00100: M_MDUout; 00101: W_ALUout; 00110: W_DMout; 00111: W_PC+8; 01000: W_CMP_result; 01001: W_MDUout**|
  |E_FW_rt_sel|output[4:0]|E 级指令 rt 端寄存器转发选择信号:**00000: keep; 00001: M_ALUout; 00010: M_PC+8; 00011: M_CMP_result; 00100: M_MDUout; 00101: W_ALUout; 00110: W_DMout; 00111: W_PC+8; 01000: W_CMP_result; 01001: W_MDUout**|
  |M_FW_rt_sel|output[4:0]|M 级指令 rt 端寄存器转发选择信号: **00000: keep; 00001: W_ALUout; 00010: W_DMout; 00011: W_PC+8; 00100: W_CMP_result; 00101: W_MDUout**|
  |E_flush|output|E 级流水线寄存器的清空信号|

<br> 

## 四、指令实现

**ori 指令**：

功能描述 : GPR[rt] <- GPR[rs] OR unsignedextend(immediate)

|op|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|001101|1|0|001|0000|0001|00010|00|000|0000|0000|0000|001|X|0|4'd1|4'd7|4'd2|


**lui 指令**：

功能描述：GPR[rt] <- immediate||16'd0

|op|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|001111|1|0|001|0000|0010|00000|00|000|0000|0000|XXXX|001|0|0|4'd1|4'd7|4'd2|


**jal 指令**：

功能描述：PC <- (PC[31:28] || instr_immediate || 00); GPR[31] <- PC + 4

|op|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|000011|1|0|010|0010|XXXX|XXXXX|00|000|0000|0010|XXXX|000|0|0|4'd7|4'd7|4'd1|

**jr 指令**：

功能描述：PC <- GPR[rs]

|op|func|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|000000|001000|0|0|XXX|XXXX|XXXX|XXXXX|00|000|0000|0011|XXXX|000|0|0|4'd0|4'd7|4'd0|


**add 指令**：

功能描述：GPR[rd] <- GPR[rs]+GPR[rt]

|op|func|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|000000|100000|1|0|000|0000|XXXX|00000|00|000|0000|0000|XXXX|000|0|0|4'd1|4'd1|4'd2|


**sub 指令**：

功能描述 GPR[rd] <- GPR[rs] - GPR[rt]

|op|func|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|000000|100010|1|0|000|0000|XXXX|00001|00|000|0000|0000|XXXX|000|0|0|4'd1|4'd1|4'd2|


**beq 指令**：

功能描述：if (GPR[rs] == GPR[rt]) PC <- PC + 4 + sign_extend(offset||00) else PC <- PC + 4

|op|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|000100|0|0|XXX|XXXX|XXXX|XXXXX|00|000|0000|0001|0000|XXX|0|0|4'd0|4'd0|4'd0|


**lw 指令**：

功能描述：GPR[rt] <= memory[GPR[rs]+offset]
  |op|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
  |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
  |100011|1|0|001|0001|0000|00000|00|000|0000|0000|0000|001|0|0|4'd1|4'd7|4'd3|


**sw 指令**：

功能描述：memory[GPR[rs]+offset] <- GPR[rt]
  |op|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
  |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
  |101011|0|1|XXX|XXXX|0000|00000|00|000|0000|0000|XXXX|001|0|0|4'd1|4'd2|4'd0|


**mult 指令**：

功能描述：(HI, LO) <- GPR[rs]×GPR[rt]
  |op|func|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
  |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
  |000000|011000|0|0|000|0000|XXXX|00000|00|000|0001|0000|XXXX|000|0|1|4'd1|4'd1|4'd0|


**div 指令**：

功能描述：(HI, LO) <- GPR[rs] / GPR[rt]
  |op|func|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
  |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
  |000000|011010|0|0|000|0000|XXXX|00000|00|000|0011|0000|XXXX|000|0|1|4'd1|4'd1|4'd0|

**multu 指令**：

功能描述：(HI, LO) <- GPR[rs]×GPR[rt]
  |op|func|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
  |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
  |000000|011001|0|0|000|0000|XXXX|00000|00|000|0010|0000|XXXX|000|0|1|4'd1|4'd1|4'd0|

**divu 指令**：

功能描述：(HI, LO) <- GPR[rs] / GPR[rt]
  |op|func|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
  |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
  |000000|011011|0|0|000|0000|XXXX|00000|00|000|0100|0000|XXXX|000|0|1|4'd1|4'd1|4'd0|

**mfhi 指令**：

功能描述：GPR[rd] <- HI
  |op|func|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
  |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
  |000000|010000|1|0|000|0100|XXXX|00000|00|000|0000|0000|XXXX|000|0|0|4'd7|4'd7|4'd2|

**mflo 指令**：

功能描述：GPR[rd] <- LO
  |op|func|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
  |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
  |000000|010010|1|0|000|0100|XXXX|00000|00|000|0000|0000|XXXX|000|1|0|4'd7|4'd7|4'd2|

**mthi 指令**：

功能描述：HI <- GPR[rs]
  |op|func|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
  |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
  |000000|010001|0|0|000|0000|XXXX|00000|00|000|0101|0000|XXXX|000|0|1|4'd1|4'd7|4'd0|

**mtlo 指令**：

功能描述：LO <- GPR[rs]
  |op|func|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
  |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
  |000000|010011|0|0|000|0000|XXXX|00000|00|000|0110|0000|XXXX|000|0|1|4'd1|4'd7|4'd0|

**and 指令**：

功能描述：GPR[rd] <- GPR[rs] and GPR[rt]
  |op|func|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
  |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
  |000000|100100|1|0|000|0000|XXXX|00011|00|000|0000|0000|XXXX|000|0|0|4'd1|4'd1|4'd2|

**or 指令**：

功能描述：GPR[rd] <- GPR[rs] or GPR[rt]
  |op|func|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
  |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
  |000000|100101|1|0|000|0000|XXXX|00010|00|000|0000|0000|XXXX|000|0|0|4'd1|4'd1|4'd2|

**slt 指令**：

功能描述：GPR[rd] <- (GPR[rs] < GPR[rt])
  |op|func|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
  |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
  |000000|101010|1|0|000|0000|XXXX|00111|00|000|0000|0000|0000|000|0|0|4'd1|4'd1|4'd2|

**sltu 指令**：

功能描述：GPR[rd] <- (0||GPR[rs]< 0||GPR[rt])
  |op|func|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
  |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
  |000000|101011|1|0|000|0000|XXXX|01001|00|000|0000|0000|0000|000|0|0|4'd1|4'd1|4'd2|


**addi 指令**：

功能描述: GPR[rt] <- GPR[rs] + signed_extend(immediate)
  |op|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|001000|1|0|001|0000|0000|00000|00|000|0000|0000|0000|001|0|0|4'd1|4'd7|4'd2|


**andi 指令**：

功能描述: GPR[rt] <- GPR[rs] AND zero_extend(immediate)
  |op|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|001100|1|0|001|0000|0001|00011|00|000|0000|0000|0000|001|0|0|4'd1|4'd7|4'd2|


**bne 指令**：

功能描述：if (GPR[rs] != GPR[rt]) PC <- PC + 4 + sign_extend(offset||00) else PC <- PC + 4
  |op|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
  |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
  |000101|0|0|XXX|XXXX|XXXX|XXXXX|00|000|0000|0001|0101|XXX|0|0|4'd0|4'd0|4'd0|

**sh 指令**：

功能描述：memory[Addr]15+16byte..16byte <- GPR[rt]15:0

|op|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|101001|0|1|XXX|XXXX|0000|00000|01|000|0000|0000|XXXX|001|0|0|4'd1|4'd2|4'd0|


**sb 指令**：

功能描述：memory[Addr]7+8byte..8byte <- GPR[rt]7:0
  |op|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
  |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
  |101000|0|1|XXX|XXXX|0000|00000|10|000|0000|000|XXXX|001|0|0|4'd1|4'd2|4'd0|

**lh 指令**：

功能描述：GPR[rt] <- sign_ext(memword15+16byte..16byte)

|op|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|100001|1|0|001|0001|0000|00000|01|100|0000|0000|XXXX|001|0|0|4'd1|4'd7|4'd3|

**lb 指令**：

功能描述：GPR[rt] <- sign_ext(memword7+8byte..8byte)

|op|GRF_write|DM_write|GRF_A3sel[2:0]|DatatoReg[3:0]|EXTop[3:0]|ALUop[4:0]|DMop[1:0]|BEop[2:0]|MDUop[3:0]|NPCop[3:0]|CMPop[3:0]|ALU_Bsel[2:0]|MDUout_sel|MDU_start|rs_Tuse[3:0]|rt_Tuse[3:0]|Tnew[3:0]|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
|100000|1|0|001|0001|0000|00000|10|010|0000|0000|XXXX|001|0|0|4'd1|4'd7|4'd3|

<br> 

## 五、测试方案

根据指令产生写数据，以及使用寄存器数据的情况可以把指令分类：

    ----按 Tnew 分类-----
    S1.Tnew = 0： j, jr, beq, bne, sw, sh, sb, mult, multu, div, divu, mthi, mtlo, syscall, mtc0, eret
    S2.Tnew = 1: jal
    S3.Tnew = 2: ori, lui, add, sub, mfhi, mflo, and, or, slt, sltu, addi, andi
    S4.Tnew = 3: lw, lh, lb, mfc0 
    
    ----按 Min_Tuse 分类-----
    K1.Tuse = 0: beq, bne, jr, eret
    K2.Tuse = 1: add, sub, and, or, slt, sltu, lui, addi, andi, ori, lui, lb, lh, lw, sw, sh, sb, mult, multu, div, divu, mthi, mtlo
    K3.Tuse = 2: mtc0
    K4.无 Tuse : mfhi, mflo, jal, mfc0, syscall, eret
    
    ----按乘除部件使用情况分类------
    T1: mult, multu, divu, div
    T2: mflo, mfhi
    T3：mthi, mtlo
    T4：others

**测试阻塞**： 

| Decode | Execute | Memory | WriteBack |
| ------ | ------- | ------ | --------- |
| K1     | S3/S4   | \*     | \*        |
| K1     | \*      | S4     | \*        |
| K2     | S4      | \*     | \*        |

**测试转发：** 转发的数据可能来自 PC+8，ALUout，DMout。

| Decode | Execute | Memory   | WriteBack |
| ------ | ------- | -------- | --------- |
| K1     | S2      | \*       | \*        |
| K2     | S2\S3   | \*       | \*        |
| K2     | \*      | S2\S3\S4 | \*        |
| K2     | \*      | \*       | s2\s3\s4  |

**对乘除指令单独测试，保证没有内部异常情况**：

| Decode | Execute | Memory | WriteBack |
| ------ | ------- | ------ | --------- |
| T1     | T1      | \*     | \*        |
| T2     | T1      | \*     | \*        |
| T3     | T1      | \*     | \*        |
| T2     | T3      | \*     | \*        |
| T4     | T1      | \*     | \*        |

除了保证乘除指令间可以正确阻塞以外，还应测试当乘除部件 busy 时，是否可以继续正确执行其他无关指令，保证流水线效率。需要额外关注寄存器为 $0 的情况。

<br> 

## 六、思考题解答

**Q1**：为什么需要有单独的乘除法部件而不是整合进 ALU？为何需要有独立的 HI、LO 寄存器？

**A**：一方面，因为乘除指令运算非常慢，而实验中我们的 CPU 要模拟这种时间延迟。另一方面，对于大部分指令是用不到乘除结果的，只有mfhi，mflo这样的指令需要等待乘除指令结束，为了不让乘除法拖慢速度，我们设立单独的乘除法部件，其他无关指令可以继续执行，使用 ALU 部件。

有独立的 HI、LO 寄存器是为了保存乘除计算结果。不把它们放入 GRF 中，也是为了提高指令并行效率。



**Q2**：请结合自己的实现分析，你是如何处理 Busy 信号带来的周期阻塞的？

**A**：我将 E 级的 start、busy 信号传给冒险控制单元，在控制单元中判断 D 级指令是否需要用到乘除结果，依据二者输出阻塞信号。



**Q3**：请问采用字节使能信号的方式处理写指令有什么好处？（提示：从清晰性、统一性等角度考虑）

**A**：字节使能通过屏蔽部分输入数据，实现仅写入数据中的指定字节。未被写入的字节保留之前写入的值。写入数据的内容直接与使能信号相对应，非常清晰。字节使能完全按照高电平的位置写入字节，将写使能信号同写入数据方式统一起来。这样统一设计的功能使端口更简洁，使用更方便。



**Q4**：请思考，我们在按字节读和按字节写时，实际从 DM 获得的数据和向 DM 写入的数据是否是一字节？在什么情况下我们按字节读和按字节写的效率会高于按字读和按字写呢？

**A**：不是。按字节读出的是字节所在的字的数据，写入的数据是对应字地址换成指定字节数据，其他字节保留得到的32位数据。存储器按字节编址情况下。



**Q5**：为了对抗复杂性你采取了哪些抽象和规范手段？这些手段在译码和处理数据冲突的时候有什么样的特点与帮助？

**A**：设计中采用集中式译码，遵循“高内聚，低耦合”的原理。译码器中仅仅译出和数据路径，功能部件有关的信号，与单周期 CPU 类似。而转发，阻塞信号全权交给冒险控制单元处理。在命名上采用流水线级+功能部件信号来区分，避免混淆。



**Q6**：在本实验中你遇到了哪些不同指令类型组合产生的冲突？你又是如何解决的？

**A**：P6 的数据冒险可以分成两类，一部分是依靠 AT 法，依照 P5 的策略可以解决，另一种是涉及到乘除指令的情况。而乘除指令只有在 Decode阶段时 mflo，mfhi指令，Execute阶段的乘除部件正在使用时才有冲突，只需要增加特殊判断即可解决。具体类别在“测试方案”部分中指出。



**Q7**：如果你是手动构造的样例，请说明构造策略，说明你的测试程序如何保证覆盖了所有需要测试的情况；如果你是完全随机生成的测试样例，请思考完全随机的测试程序有何不足之处；如果你在生成测试样例时采用了特殊的策略，比如构造连续数据冒险序列，请你描述一下你使用的策略如何结合了随机性达到强测的效果。

**A**：手动构造数据，为避免大量重复构造，首先单独验证所有指令各自的数据通路是否正确。再对其进行分类，列举转发，阻塞的情况，按类别构造测试数据，具体可见测试方案部分。
