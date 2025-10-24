.text 0x3000
    nop # Timer --- control:0x7f00  present:0x7f04 count:0x7f08
    nop # UART --- Data:0x7f30  State:0x7f34
    nop # Digital Tube---- 0x7f50
    nop # DipSwitch --- Team 0-3:0x7f60  Team 4-7:0x7f64 
    nop # Key --- 0x7f68
    nop # LED --- 0x7f70
initial:
    addi $v0, $0, 0       
    addi $v1, $0, 0x21373307
    addi $s4, $0, 0x63  # c
    
    addi $a1, $0, -1
    sw $a1, 0($0)
    sw $0, 12($0) 
    addi $a1, $0, 25000000
    sw $a1, 0x7f04($0)
    addi $a1, $0, 0x1401
    mtc0 $a1, $12
    nop
#######################  
input: 
    addi $a1, $0, 0
    sw $a1, 0x7f00($0)  # disable Timer
    lw $s0, 0x7f68($0)  # $s0 = key
    lw $s1, 0x7f60($0)  # $s1 = group 0-3
    lw $s2, 0x7f64($0)  # $s2 = group 4-7
    sw $s0, 0($0)       # keep key
##############################
  
Function:
    addi $a1, $0, 0xb
    sw $a1, 0x7f00($0)  # enable Timer
    
loop_Function:
  if_1:  
    lw $s0, 0x7f68($0)
    lw $t0, 0($0)
    bne $t0, $s0, input
    nop
  if_1_end:
  
  if_2:
    bne $v0, $s4, if_2_end
    nop
    sw $0, 0x7f00($0)
    jal end
    nop
  if_2_end:
  
  if_3:
    bne $s2, $0, if_3_end
    nop
    sw $0, 0x7f00($0)
  if_3_end:
  
    jal output
    nop
    jal loop_Function
    nop
  
###########################################
output:
    lw $t3, 12($0)
  if_output: 
    bne $t3, $s3, if_output_end
    nop
    jr $ra
    nop
  if_output_end:  
    sw $s3, 12($0)
    andi $t3, $s3, 1
    beq $t3, $0, output_UART
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

end:
   beq $0, $0, end
   nop
  
.ktext 0x4180
    nop
    mfc0 $v0, $13
    andi $t4, $v0, 0x1000
    bne $t4, $0, handler_UART
    nop
handler_Timer:
    andi $t0, $s0, 1
    bne $t0, $0, add
    nop
    andi $t0, $s0, 2
    bne $t0, $0, sub
    nop
    andi $t0, $s0, 4
    bne $t0, $0, mult
    nop
    andi $t0, $s0, 8
    beq $t0, $0, default
    nop
    bne $s1, $0, div
    nop
    addi $s3, $0, 0
    add $s2, $0, $s3
    eret
    nop 
  add:
    add $s3, $s2, $s1
    add $s2, $0, $s3
    eret
    nop
  sub:
    sub $s3, $s2, $s1
    add $s2, $0, $s3
    eret
    nop
  mult:
    mult $s2, $s1
    mflo $s3
    add $s2, $0, $s3
    eret
    nop
  div:
    div $s2, $s1
    mflo $s3
    add $s2, $0, $s3
    eret
    nop
  default:
    nop
    eret
    nop
    
handler_UART:
    lb $v0, 0x7f30($0)
  if_UART:
    bne $v0, $s4, if_UART_end
    nop
    sw $v1, 0x7f70($0)
    sw $v1, 0x7f50($0)
  if_UART_end:
    nop
    eret
    nop
    
