.data
    next: .asciiz "\n"
.macro end
    li $v0, 10
    syscall
.end_macro 

.macro readInt(%s)
    li $v0, 5
    syscall
    move %s, $v0
.end_macro

.macro printInt(%s)
    li $v0, 1
    move $a0, %s
    syscall
    la $a0, next
    li $v0, 4
    syscall
.end_macro

.text
    Main:
        readInt($s0)    # m
        readInt($s1)    # n
        move $t0, $s0   # i
        
        loop_begin:
            be $t0, $s1, loop_end
            
            if_begin:
                move $a1, $t0
                jal Check
                beq $v1, $zero, if_end
                printInt($t0)
                
            if_end:
            addi $t0, $t0, 1
            j loop_begin
        loop_end:
        end
    Check:
        li $v1, 0
        li $t2, 10
        div $a1, $t2
        div $a2, $a1, $t2
        mfhi $t6      # low
        div $a2, $t2
        mfhi $t5      # mid
        mflo $t4      # hi
        mul $t2, $t6, $t6
        mul $t2, $t2, $t6
        add $t3, $zero, $t2
        mul $t2, $t5, $t5
        mul $t2, $t2, $t5
        add $t3, $t3, $t2
        mul $t2, $t4, $t4
        mul $t2, $t2, $t4
        add $t3, $t3, $t2
        bne $t3, $a1, checkend
        li $v1, 1
        checkend:
        jr $ra
