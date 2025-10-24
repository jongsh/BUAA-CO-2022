.data
    numb: .space 5000
    
.macro readInt(%s)
    li $v0, 5
    syscall
    move %s, $v0
.end_macro

.macro printInt(%s)
    move $a0, %s
    li $v0, 1
    syscall
.end_macro

.macro end
    li $v0, 10
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
        readInt($s0)     # n
        move $s2, $s0    # s
        li $s1, 1        # flag
        li $s4, 10       # 10
        la $t5, numb
        sw $s2, 0($t5)
        addi $s2, $s2, -1
        for_1_begin:
            slt $t2, $zero, $s2
            beq $t2, $zero, for_1_end
            move $a0, $s2
            jal Mult
            addi $s2, $s2, -1
            j for_1_begin
        for_1_end:
        
        li $t2, 1
        if_special:
            bne $s1, $t2, if_special_end
            la $t5, numb
            lw $t3, 0($t5)
            bne $t3, $zero, if_special_end
            printInt($t2)
            j for_3_end
        
        if_special_end:
        
        addi $t0, $s1, -1   #i
        for_3_begin:
            slt $t1, $t0, $zero
            bne $t1, $zero, for_3_end
            
            la $t5, numb
            sll $t2, $t0, 2
            add $t5, $t5, $t2
            lw $t6, 0($t5)
            printInt($t6)
            addi $t0, $t0, -1
            j for_3_begin
        for_3_end:
        end
        
    Mult:
        li $t0, 0    # i
        li $t1, 0    # cin
        for_2_begin:
            bne $t1, $zero, for_text
            slt $t2, $t0, $s1
            bne $t2, $zero, for_text
            j for_2_end
            for_text:
            sll $t2, $t0, 2
            la $t5, numb
            add $t5, $t5, $t2
            lw $t3, 0($t5)   # numb[i]
            mul $t3, $t3, $a0
            add $t3, $t1, $t3
            div $t3, $s4
            mflo $t1
            mfhi $t3
            sw $t3, 0($t5)
            
            addi $t0, $t0, 1
            j for_2_begin
        for_2_end:
        move $s1, $t0
        jr $ra
        
