.data 
    cnt: .space 120
    index: .space 120
    space: .asciiz  " "
    next: .asciiz "\n"
    a: .asciiz "a"

.macro end
    li $v0, 10
    syscall
.end_macro
.macro printf(%c, %d)
    li $v0, 11
    move $a0, %c
    syscall
    la $a0, space
    li $v0, 4
    syscall
    move $a0, %d
    li $v0, 1
    syscall
    la $a0, next
    li $v0, 4
    syscall
.end_macro

.macro readInt(%s)
    li $v0, 5
    syscall
    move %s, $v0
.end_macro

.macro readChar(%s)
    li $v0, 12
    syscall
    move %s, $v0
.end_macro

.text
    Main:
        readInt($s0)     # n
        li $s2, 0        # sum
        li $t0, 0        # i
        la $t5, a
        lb $t3, 0($t5)   # a
        
        for_1_begin:
            beq $t0, $s0, for_1_end
            la $t5, cnt
            readChar($t1)   # temp
            sub $t1, $t1, $t3   # temp - 'a'
            sll $t2, $t1, 2
            add $t5, $t5, $t2
            lw $t2, 0($t5)      # cnt[temp-'a']
            if_1_begin:
                bne $t2, $zero, if_1_end
                la $t5, index
                sll $t4, $s2, 2
                add $t5, $t5, $t4
                sw $t1, 0($t5)
                addi $s2, $s2, 1
            if_1_end:
            la $t5, cnt
            sll $t4, $t1, 2
            add $t5, $t5, $t4
            addi $t2, $t2, 1
            sw $t2, 0($t5)
            
            addi $t0, $t0, 1
            j for_1_begin
        for_1_end:
        
        li $t0, 0   # i
        for_2_begin:
            beq $t0, $s2, for_2_end
            la $t5, index
            sll $t1, $t0, 2
            add $t5, $t5, $t1
            lw $t1, 0($t5)    # index[i]
            
            add $t2, $t1, $t3
            la $t5, cnt
            sll $t4, $t1, 2
            add $t5, $t5, $t4
            lw $t4, 0($t5)
            printf($t2, $t4)

            addi $t0, $t0, 1
            j for_2_begin
        for_2_end:
        
        end
