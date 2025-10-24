.data 
    Symbol: .space 32     # 4 x 8
    Array: .space 32
    Nextline: .asciiz "\n"
    Space: .asciiz " "

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
    move $a0, %s
    li $v0, 1
    syscall
.end_macro

.macro printNextLine
    la $a0, Nextline
    li $v0, 4
    syscall
.end_macro

.macro printSpace
    la $a0, Space
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
        readInt($s0)    # n
        li $a0, 0       # a0 = index
        jal Full
        end
        
    Full:
        move $t0, $a0   # t0 = index
        push($a0)       # store a0
        push($t1)       # store i
        push($ra)       # store $ra
        
        li $t1, 0       # t1 = i
        if_1_begin:
            slt $t2, $t0, $s0
            bne $t2, $zero, if_1_end
            li $t1, 0
            for_1_begin:
                beq $t1, $s0, for_1_end
                sll $t2, $t1, 2
                la $t5, Array
                add $t5, $t5, $t2
                lw $t2, 0($t5)
                printInt($t2)
                printSpace
                addi $t1, $t1, 1
                j for_1_begin
            for_1_end:
            printNextLine    
            pop($ra)
            pop($t1)
            pop($a0)
            jr $ra
        if_1_end:
        
        li $t1, 0
        for_2_begin:
            beq $t1, $s0, for_2_end
            if_2_begin:
                sll $t2, $t1, 2
                la $t5, Symbol
                add $t5, $t5, $t2
                lw $t2, 0($t5)    # t2 = symbol[i]
                bne $t2, $zero, if_2_end
                push($t5)
                li $t2, 1
                sw $t2, 0($t5)
                sll $t3, $t0, 2
                la $t5, Array
                add $t5, $t5, $t3
                addi $t3, $t1, 1
                sw $t3, 0($t5)   # t3 = array[index]
                addi $a0, $t0, 1
                push($t0)
                jal Full
                pop($t0)
                pop($t5)        
                li $t2, 0
                sw $t2, 0($t5)
            if_2_end:
            addi $t1, $t1, 1
            j for_2_begin
        for_2_end:
        
        pop($ra)
        pop($t1)
        pop($a0)
        jr $ra
         




