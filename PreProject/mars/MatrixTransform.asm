.data
  array: .space 10000           # n x m Martrix
  space: .asciiz " "
  nextline: .asciiz "\n"
  .macro getindex(%ans, %i, %j) # line i   row j 
    mult %i, $t0
    mflo %ans
    add %ans, %ans, %j            # %ans = 50 * %i + %j
    sll %ans %ans 2
  .end_macro
    
.text 
  li $t0, 50                     # store the size of the matrix
  
  input:
    li $v0 5
    syscall
    move $s0, $v0                # $s0 = n
    li $v0 5
    syscall
    move $s1, $v0                # $s1 = m
    li $t1 0                    # $t1 = i
    for_1_begin:
      slt $s3 $t1 $s0
      beq $s3 $0 for_1_end
      li $t2 0                    # $t2 = j
      for_2_begin:
        slt $s2 $t2 $s1
        beq $s2 $0 for_2_end
        li $v0 5
        syscall
        getindex($t3 $t1 $t2)
        sw $v0 array($t3)
        addi $t2 $t2 1
        j for_2_begin
        
      for_2_end:
        addi $t1 $t1 1
        j for_1_begin
    
    for_1_end:
      nop
    
  output:
    move $t1 $s0
    for_3_begin:
      slt $s3 $0 $t1
      beq $s3 $zero for_3_end
      move $t2 $s1
      sub $t4 $t1 1             # line $t4
      for_4_begin:
        slt $s2 $0 $t2
        beq $s2 $zero for_4_end
        sub $t5 $t2 1         
        getindex($t3 $t4 $t5)
        lw $s4 array($t3)
        beq $s4 $zero noput
        move $a0 $t1
        li $v0 1
        syscall
        
        la $a0 space
        li $v0 4
        syscall
        
        move $a0 $t2
        li $v0 1
        syscall
        
        la $a0 space
        li $v0 4
        syscall
        
        move $a0 $s4
        li $v0 1
        syscall
        
        la $a0 nextline
        li $v0 4
        syscall
        noput:
        addi $t2 $t2 -1
        j for_4_begin
      for_4_end:
        sub $t1 $t1 1
        j for_3_begin
    for_3_end:
      nop
    
    
    
    