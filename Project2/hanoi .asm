.data
    print1: .asciiz "move disk "
    print2: .asciiz " from "
    print3: .asciiz " to "
    nextline: .asciiz "\n"
    A: .ascii "A"
    B: .ascii "B"
    C: .ascii "C"
    

.macro readInt(%s)
    li $v0, 5
    syscall
    move %s, $v0
.end_macro

.macro end
    li $v0, 10
    syscall
.end_macro

.macro movef(%id, %from, %to)
    la $a0, print1
    li $v0, 4
    syscall
    li $v0, 1
    move $a0, %id
    syscall
    la $a0, print2
    li $v0, 4
    syscall
    move $a0, %from
    li $v0, 11
    syscall
    la $a0, print3
    li $v0, 4
    syscall
    move $a0, %to
    li $v0, 11
    syscall
    la $a0, nextline
    li $v0, 4
    syscall
.end_macro

.macro push(%s)
    sw %s, 0($sp)
    addi $sp, $sp, -4
.end_macro

.macro pop(%s)
    addi $sp, $sp, 4
    lw %s, 0($sp)
.end_macro 

.text
    Main: 
        readInt($s0)       # n
        la $t5, A
        lb $s1, 0($t5)        # A
        la $t5, B
        lb $s2, 0($t5)        # B
        la $t5, C
        lb $s3, 0($t5)        # C
        push($s0)        # base
        push($s1)        # from
        push($s2)        # via
        push($s3)        # to
        jal hanoi
        end
     
    hanoi:
        pop($t3)         # to
        pop($t2)         # via
        pop($t1)         # from
        pop($t0)         # base 
        push($ra)
        
        if_1_begin:
            bne $t0, $zero, if_1_end
            movef($t0, $t1, $t2)
            movef($t0, $t2, $t3)
            pop($ra)
            jr $ra
        if_1_end:
        
        # protect
        push($t0)
        push($t1)
        push($t2)
        push($t3)
        
        addi $t0, $t0, -1 # base - 1
        push($t0)
        push($t1)
        push($t2)
        push($t3)
        jal hanoi
        pop($t3)   # to
        pop($t2)   # via
        pop($t1)   # from
        pop($t0)   # base
        movef($t0, $t1, $t2)
        
        # protect
        push($t0)
        push($t1)
        push($t2)
        push($t3)
        
        addi $t0, $t0, -1 # base - 1
        push($t0)
        push($t3)
        push($t2)
        push($t1)
        jal hanoi
        pop($t3)   # to
        pop($t2)   # via
        pop($t1)   # from
        pop($t0)   # base
        movef($t0, $t2, $t3)
        
        # protect
        push($t0)
        push($t1)
        push($t2)
        push($t3)
        
        addi $t0, $t0, -1 # base - 1
        push($t0)
        push($t1)
        push($t2)
        push($t3)
        jal hanoi
        pop($t3)   # to
        pop($t2)   # via
        pop($t1)   # from
        pop($t0)   # base
        
        pop($ra)
        jr $ra
        
