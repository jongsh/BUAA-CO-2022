# P3 单周期 CPU 设计文档



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

### 2.1 PC

logisim 中实现 PC 模块直接使用**32位寄存器**即可，输入信号包括**异步复位信号，时钟信号，下一个 PC 值**， 输出信号有**当前 PC 值**。



### 2.2 NPC

NPC 模块实现对下一条指令的判断，根据对指令的归类，下一条指令可能来自于：**当前 PC 值加 4、 J 指令的26位立即数段直接置入新的 PC、 R型跳转指令16位立即数与当前 PC 做运算、jr 指令跳转到寄存器存储的指令地址**。

| 端口  | 方向  | 功能  |
|---|---|---|
|  imm_26| input[25:0]  | 26 位立即数  |
|  imm_16 | input[15:0] | 16 位立即数  |
| PC  | input[31:0] | 当前 PC 的值 |
|NPCop |input[1:0]|**00**：`PC+4`；**01**：`PC+4+signed[imm_16]+00`；**10**：`PC[31:28]+imm26+00`；**11**：`regdata` |
|  Reg_ra | input[31:0]| 用于 jr 指令 |
| COMPresult| input | 用于 R 型跳转指令的比较结果 |
|  PCnext | output[31:0] | 计算所得下一个 PC |



### 2.3 COMP

对操作数作比较，用于提供NPC模块所需的信号。

| 端口  | 方向  | 功能  |
|---|---|---|
|operationA| input[31:0]| 第一个操作数|
|operationB| input[31:0]| 第二个操作数|
|COMPop|input[2:0]|模块控制信号：**000：A=?=B；001：A\<?B有符号；010：A>?B有符号；011：A\<?B无符号；100：A>?B无符号；101：A!=B？**|
|COMPresult|output|根据 COMPop 输出一位结果，高电平为真|



### 2.4 ALU

提供各类运算功能。

| 端口  | 方向  | 功能  |
|---|---|---|
|operationA| input[31:0]| 第一个操作数|
|operationB| input[31:0]| 第二个操作数|
|shamtC|input[4:0]|用于 R 指令的移位数|
|ALUop| input[2:0]| 控制信号 **000**：A+B；**001**：A-B；**010**：A或B；**011**：A与B；**100**：B逻辑右移C；**101**：B逻辑左移 C；**110**：B算数右移C |
|COMPop|input[2:0]|模块控制信号 **000**：A=?=B；**001**：A\<?B有符号；**010**：A>?B有符号；**011**：A\<?B无符号；**100**：A>?B无符号；**101**：A!=B？|
|Y|output[31:0]| 32 位输出结果 |
|COMPresult|output|根据 COMPop 输出一位结果，高电平为真|

**为了简化顶层模块与连线，将 COMP 模块综合到 ALU 中，ALU 的外部信号也增加了 COMP 的端口**



### 2.5 DM

数据存储器，用于作内存，存储数据。

| 端口  | 方向  | 功能  |
|---|---|---|
|Reset|input|异步复位信号|
|clk|iinput|时钟控制信号，上升沿有效|
|MemAddr|input[4:0]|数据所在地址|
|MemWE|input|写入信号，高电平时，将数据端口数据写入对应地址当中|
|MemWD|input[31:0]|将要写入 RAM 内存里的数据|
|MemReadData|output[31:0]|根据 DataAddr 读出的数据|



### 2.6 EXT

实现有/无符号的扩展。

| 端口  | 方向  | 功能  |
|---|---|---|
|EXTin|input[15:0]|操作数|
|EXTout|output[31:0]|扩展得到的结果|
|EXTop|input[1:0]|控制信号 **00**：符号扩展，**01**：无符号扩展；**10**：低位补0|



### 2.7 GRF

32 位通用寄存器的读写模块。

| 端口  | 方向  | 功能  |
|---|---|---|
|reset| input|异步复位信号|
|WE|input|写控制信号，高电平有效|
|clk|input|时钟信号|
|A1|input[4:0]|第一个读寄存器的编号|
|A2|input[4:0]|第二个读寄存器的编号|
|A3|input[4:0]|用于写的寄存器的编号|
|WD|input[31:0]|用于写入 A3 寄存器的 32 位数据|
|RD1|output[31:0]|第一个读出的数据|
|RD2|output[31:0]|第二个读出的数据|



### 2.8 Controller

| 端口  | 方向  | 功能  |
|---|---|---|
|Instr_op|input[5:0]|读取指令的 opz 字段|
|Instr_func|input[5:0]|读取指令的 func 字段|
|RegWrite|output|寄存器文件GRF写控制信号 **1**：使能；**0**：不能写入|
|RegDst|ouput[1:0]|区分R型指令与I型指令的多路选择信号 **00**：选择instr_rd; **01**：选择instr_rt; **10**：写入31号寄存器ra|
|EXTop|output[1:0]|EXT模块区分有无符号扩展的控制信号 **00**：符号扩展；**01**：无符号扩展; **10**：低位补零|
|NPCop|output[1:0]|PCnext = **00**：PC+4； **01**： PC+4+signed[imm_16]+00; **10**: PC[31:28]+imm26+00; **11**：regdata|
|ALUSrc|output|选择ALU的操作数B **0**：RD2 **1**：扩展后的32位立即数|
|ALUop|output[2:0]|控制信号 **000**：A+B；**001**：A-B；**010**： A或B； **011**：A与B； **100**：B逻辑右移C; **101**: B逻辑左移C; **110**: B算数右移C|
|COMPop|output[2:0]|模块控制信号 **000**：A=?=B；**001**：A\<?B有符号；**010**：A>?B有符号；**011**：A\<?B无符号; **100**: A>?B无符号；**101**：A!=B？|
|MemWrite|output|写入信号，高电平时，将数据端口数据写入对应地址当中|
|DatatoReg|output[2:0]|GRF 输入端 WD 的选择信号，**000**：ALUresult；**001**：MemReadData；**010**：PC+4；**011**：写入 COMPresult|

注记：该设计已经把 **IM** 模块放在顶层设计了。

<br> 

## 三、指令实现
该部分则主要是根据要实现的指令特征对 Controller 的输入输出作分析。

* **ori 指令：**
  
  功能描述 : GPR[rt] <- GPR[rs] OR unsignedextend(immediate)
  |op|RegWrite|RegDst[1:0]|EXTop[1:0]|NPCop[1:0]|ALUSrc|ALUop[2:0]|COMPop[2:0]|MemWrite|DatatoReg[2:0]|
  |---|---|---|---|---|---|---|---|---|---|
  |001101|1|01|01|00|1|010|XXX|0|000|



* **add 指令：**

  功能描述：GPR[rd] <- GPR[rs]+GPR[rt]
  |op|func|RegWrite|RegDst[1:0]|EXTop[1:0]|NPCop[1:0]|ALUSrc|ALUop[2:0]|COMPop[2:0]|MemWrite|DatatoReg[2:0]|
  |---|---|---|---|---|---|---|---|---|---|---|
  |000000|100000|1|00|XX|00|0|000|XXX|0|000|

  

* **sub 指令：**

  功能描述 GPR[rd] <- GPR[rs] - GPR[rt]
  |op|func|RegWrite|RegDst[1:0]|EXTop[1:0]|NPCop[1:0]|ALUSrc|ALUop[2:0]|COMPop[2:0]|MemWrite|DatatoReg[2:0]|
  |---|---|---|---|---|---|---|---|---|---|---|
  |000000|100010|1|00|XX|00|0|001|XXX|0|000|

  

* **sw 指令：**

  功能描述：memory[GPR[base]+offset] <- GPR[rt]
  |op|RegWrite|RegDst[1:0]|EXTop[1:0]|NPCop[1:0]|ALUSrc|ALUop[2:0]|COMPop[2:0]|MemWrite|DatatoReg[2:0]|
  |---|---|---|---|---|---|---|---|---|---|
  |101011|0|XX|00|00|1|000|XXX|1|XXX|

  

* **lw 指令：**

  功能描述：GPR[rt] <= memory[GPR[base]+offset]
  |op|RegWrite|RegDst[1:0]|EXTop[1:0]|NPCop[1:0]|ALUSrc|ALUop[2:0]|COMPop[2:0]|MemWrite|DatatoReg[2:0]|
  |---|---|---|---|---|---|---|---|---|---|
  |100011|1|01|00|00|1|000|XXX|0|001|

  

* **lui 指令：**

  功能描述：GPR[rt] <- immediate||16'd0
  |op|RegWrite|RegDst[1:0]|EXTop[1:0]|NPCop[1:0]|ALUSrc|ALUop[2:0]|COMPop[2:0]|MemWrite|DatatoReg[2:0]|
  |---|---|---|---|---|---|---|---|---|---|
  |001111|1|01|10|00|1|000|XXX|0|000|

  

* **beq 指令：**

  功能描述：if (GPR[rs] == GPR[rt]) PC <- PC + 4 + sign_extend(offset||00) else PC <- PC + 4
  |op|RegWrite|RegDst[1:0]|EXTop[1:0]|NPCop[1:0]|ALUSrc|ALUop[2:0]|COMPop[2:0]|MemWrite|DatatoReg[2:0]|
  |---|---|---|---|---|---|---|---|---|---|
  |000100|0|XX|XX|01|X|XXX|000|0|XXX|

  

* **bne 指令：**

  功能描述：if (GPR[rs] ≠ GPR[rt]) PC <- PC + 4 + sign_extend(offset||00) else PC <- PC + 4
  |op|RegWrite|RegDst[1:0]|EXTop[1:0]|NPCop[1:0]|ALUSrc|ALUop[2:0]|COMPop[2:0]|MemWrite|DatatoReg[2:0]|
  |---|---|---|---|---|---|---|---|---|---|
  |000101|0|XX|XX|01|X|XXX|101|0|XXX|

  

* **J 指令：**

  功能描述：PC <- PC[31:28]||immediate||00
  |op|RegWrite|RegDst[1:0]|EXTop[1:0]|NPCop[1:0]|ALUSrc|ALUop[2:0]|COMPop[2:0]|MemWrite|DatatoReg[2:0]|
  |---|---|---|---|---|---|---|---|---|---|
  |000010|0|XX|XX|10|XX|XXX|XXX|0|XXX|

  

* **addi 指令：**
  
  功能描述：GPR[rt] <- GPR[rs]+ signedextend(immediate)
  |op|RegWrite|RegDst[1:0]|EXTop[1:0]|NPCop[1:0]|ALUSrc|ALUop[2:0]|COMPop[2:0]|MemWrite|DatatoReg[2:0]|
  |---|---|---|---|---|---|---|---|---|---|
  |001000|1|01|00|00|1|000|XXX|0|000|
  
  
  
* **slt 指令：**
  
  功能描述：GPR[rd] <- (GPR[rs] < GPR[rt])
  |op|func|RegWrite|RegDst[1:0]|EXTop[1:0]|NPCop[1:0]|ALUSrc|ALUop[2:0]|COMPop[2:0]|MemWrite|DatatoReg[2:0]|
  |---|---|---|---|---|---|---|---|---|---|---|
  |000000|101010|1|00|XX|00|0|XXX|001|0|011|
  
  
  
* **sll 指令：**

  功能描述：GPR[rd] <- GPR[rt] << s
  功能描述：GPR[rt] <- GPR[rs] + signedextend(immediate)

  |op|func|RegWrite|RegDst[1:0]|EXTop[1:0]|NPCop[1:0]|ALUSrc|ALUop[2:0]|COMPop[2:0]|MemWrite|DatatoReg[2:0]|
  |---|---|---|---|---|---|---|---|---|---|---|
  |000000|000000|1|00|XX|00|0|101|XXX|0|000|

  

* **jr 指令：**

  功能描述：PC <- GPR[rs]
  |op|func|RegWrite|RegDst[1:0]|EXTop[1:0]|NPCop[1:0]|ALUSrc|ALUop[2:0]|COMPop[2:0]|MemWrite|DatatoReg[2:0]|
  |---|---|---|---|---|---|---|---|---|---|---|
  |000000|001000|0|XX|XX|11|X|XXX|XXX|0|XXX|

  

* **jal 指令：**

  功能描述：PC <- (PC[31:28] || instr_immediate || 00)；GPR[31] <- PC + 4
  |op|RegWrite|RegDst[1:0]|EXTop[1:0]|NPCop[1:0]|ALUSrc|ALUop[2:0]|COMPop[2:0]|MemWrite|DatatoReg[2:0]|
  |---|---|---|---|---|---|---|---|---|---|
  |000011|1|10|XX|10|X|XXX|XXX|0|010|


<br> 

## 四、测试方案

> 声明：下列所有测试数据均是手捏数据，测试强度不能保证。

**ori 指令：**

```
ori $t0, $zero, 200
ori $t1, $t0, 65535
ori $zero, $t1, 100
```

**lui 指令：**

```
lui $a2, 123           
lui $a3, 0xffff         
lui $zero, 123
lui $a1, 0
```

**add 指令：**

```
lui $t1, 0    # t1 > 0
lui $t2, 0xffff # t2 < 0
ori $t1, 100
ori $t2, 100
nop
add $t3, $t2, $t2
add $t4, $t1, $t1
add $t5, $t1, $t2
add $0, $0, $t5
```

**sub 指令：**

```
lui $t1, 0    # t1 > 0
lui $t2, 0xffff # t2 < 0
ori $t1, 100
ori $t2, 100
nop
sub $t3, $t2, $t2
sub $t4, $t1, $t1
sub $t5, $t1, $t2
sub $t5, $t2, $t1
sub $0, $0, $t5
```

**sw 指令：**

```
ori $t0, $0, 16
ori $a0, 100
lui $a1, 0xf000
ori $a1, 0xff00
lui $a2, 0xffff
ori $a2, 0xffff
lui $a3, 0x8fff
ori $a3, 0xffff
sw $a0, 0($t0)
sw $a1, 4($t0)
sw $a2, 8($t0)
sw $a3, -4($t0)
```

**lw 指令：**

```
ori $t0, $0, 16
ori $a0, 100
lui $a1, 0xf000
ori $a1, 0xff00
lui $a2, 0xffff
ori $a2, 0xffff  #a2 = -1
lui $a3, 0x8fff
ori $a3, 0xffff
sw $a0, 0($t0)
sw $a1, 4($t0)
sw $a2, 8($t0)
sw $a3, -4($t0)
nop
lw $0, 0($t0)
lw $s0, -4($t0)
lw $s1, 4($t0)
lw $s2, 17($a2) 
```

**beq 指令：**

```
ori $a0, 1
ori $a1, 2
ori $a2, 3
beq $t0, $a0, state1
add $t0, $a0, $a0
beq $t0, $a1, state2
state1:
    add $t0, $t0, $a0
state2:
    beq $t0, $a1, state1
state3:
    beq $t0, $a1, state3
state4:
    beq $t0, $a2, state4
add $t0, $0, $0 
```

**综合测试：**

```
## 实现1加到100，结果给到 $s0,如果值为5050， 则把 $v0 置位 -1，存入指定位置里，再取出来
ori $t0, 1
ori $t1, 1
ori $t2, 101
ori $s1, 5050
loop_begin:
    beq $t1, $t2, loop_end
    add $s0, $s0, $t1
    add $t1, $t1, $t0
    j loop_begin
loop_end:
nop
if_begin:
    bne $s0, $s1, state2
    beq $s0, $s1, state1
state1:
    lui $v0, 0xffff
    ori $v0, $v0, 0xffff
state2:
    sw $v0, 16($0)
    lw $s1, 16($0)
```
