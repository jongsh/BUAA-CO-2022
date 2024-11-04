####  initial $a1 - $a2
####  
####
.text 0x3000
    nop # Timer --- control:0x7f00  present:0x7f04 count:0x7f08
    nop # UART --- Data:0x7f30  State:0x7f34
    nop # Digital Tube---- 0x7f50
    nop # DipSwitch --- Team 0-3:0x7f60  Team 4-7:0x7f64 
    nop # Key --- 0x7f68
    nop # LED --- 0x7f70
initial:
    addi $a1, $0, -1
    sw $a1, 0($0)
    sw $a1, 4($0)
    sw $a1, 8($0)
    sw $a1, 12($0)
    
    addi $a1, $0, 25000000
    sw $a1, 0x7f04($0)
    addi $a1, $0, 0x1401
    mtc0 $a1, $12

input:
    addi $a1, $0, 0
    sw $a1, 0x7f00($0)  # disable Timer
    lw $s0, 0x7f68($0)  # $s0 = key
    lw $s1, 0x7f60($0)  # $s1 = group 0-3
    lw $s2, 0x7f64($0)  # $s2 = group 4-7
    sw $s0, 0($0)       # keep key
    sw $s1, 4($0)       # keep group 0-3
    sw $s2, 8($0)       # keep group 4-7
    andi $t0, $s0, 1
    beq $t0, $0, Calculator
    nop
    
###########################
###########################
Counter:
    andi $t0, $s0, 4
    bne $t0, $0, Counter2
    nop
   
Counter1:   # add count
    addi $s3, $0, 0
    addi $v1, $0, 1
  loop_Counter1:
    lw $s0, 0x7f68($0)  # $s0 = key
    lw $s1, 0x7f60($0)  # $s1 = group 0-3
    lw $s2, 0x7f64($0)  # $s2 = group 4-7
    lw $t0, 0($0)
    lw $t1, 4($0)
    lw $t2, 8($0)
    bne $s0, $t0, input
    nop
    bne $s1, $t1, input
    nop
    bne $s2, $t2, input
    nop
  if_Counter1:
    bne $s1, $s3, if_Counter1_end
    nop
    sw $0, 0x7f00($0)  # disable Timer
  if_Counter1_end:
    jal output
    nop
    addi $a1, $0, 0xb
    sw $a1, 0x7f00($0)
    jal loop_Counter1
    nop
################################
################################
Counter2:  # sub count
    add $s3, $0, $s1
    addi $v1, $0, -1
   loop_Counter2:
    lw $s0, 0x7f68($0)  # $s0 = key
    lw $s1, 0x7f60($0)  # $s1 = group 0-3
    lw $s2, 0x7f64($0)  # $s2 = group 4-7
    lw $t0, 0($0)
    lw $t1, 4($0)
    lw $t2, 8($0)
    bne $s0, $t0, input
    nop
    bne $s1, $t1, input
    nop
    bne $s2, $t2, input
    nop
  if_Counter2:
    bne $s3, $0, if_Counter2_end
    nop
    sw $0, 0x7f00($0)  # disable Timer
  if_Counter2_end:
    jal output
    nop
    addi $a1, $0, 0xb
    sw $a1, 0x7f00($0)
    jal loop_Counter2
    nop
######################
######################
Calculator:
    andi $t0, $s0, 4
    bne $t0, $0, add
    nop
    andi $t0, $s0, 8
    bne $t0, $0, sub
    nop
    andi $t0, $s0, 16
    bne $t0, $0, mult
    nop
    andi $t0, $s0, 32
    bne $t0, $0, div
    nop
    andi $t0, $s0, 64
    bne $t0, $0, and
    nop
    andi $t0, $s0, 128
    bne $t0, $0, or
    nop
    jal default 
    nop
  add:
    add $s3, $s2, $s1
    jal Calculator_end
    nop
  sub:
    sub $s3, $s2, $s1
    jal Calculator_end
    nop
  mult:
    mult $s2, $s1
    mflo $s3
    jal Calculator_end
    nop
  div:
    div $s2, $s1
    mflo $s3
    jal Calculator_end
    nop
  and:
    and $s3, $s2, $s1
    jal Calculator_end
    nop
  or:
    or $s3, $s2, $s1
    jal Calculator_end
    nop
  default:
    nop
  Calculator_end:   
    jal output
    nop
    jal input
    nop   
      
#######################
#######################
output:
    lw $t3, 12($0)
  if_output: 
    bne $t3, $s3, if_output_end
    nop
    jr $ra
    nop
  if_output_end:
    sw $s3, 12($0)
    andi $t0, $s0, 2
    bne $t0, $0, output_UART
    nop
output_LED:
    sw $s3, 0x7f70($0)
    sw $s3, 0x7f50($0)
    jr $ra
    nop

output_UART:
    lb $t3, 15($0)
  loop_UART1:
    lw $t4, 0x7f34($0)
    beq $t4, $0, loop_UART1
    nop
    sb $t3, 0x7f32($0)
    nop
    nop
    nop
    lb $t3, 14($0)
  loop_UART2:
    lw $t4, 0x7f34($0)
    beq $t4, $0, loop_UART2
    nop
    sb $t3, 0x7f32($0)
    nop
    nop
    nop
    lb $t3, 13($0)
  loop_UART3:
    lw $t4, 0x7f34($0)
    beq $t4, $0, loop_UART3
    nop
    sb $t3, 0x7f32($0)
    nop
    nop
    nop
    lb $t3, 12($0)
  loop_UART4:
    lw $t4, 0x7f34($0)
    beq $t4, $0, loop_UART4
    nop
    sb $t3, 0x7f32($0)
    
    jr $ra
    nop


.ktext 0x4180
    mfc0 $v0, $13
    andi $t4, $v0, 0x1000
    bne $t4, $0, handler_UART
    nop
    
  handler_Counter:
    add $s3, $s3, $v1
    eret
    nop
     
  handler_UART:
    lb $s4, 0x7f30($0)
   loop_handler_UART:
    lw $t4, 0x7f34($0)
    beq $t4, $0, loop_handler_UART
    nop
    sb $s4, 0x7f32($0)
   loop_handler_UART_end:
    eret
    nop    
    
    
    
 
