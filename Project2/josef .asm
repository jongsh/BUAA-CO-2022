.data
    book: .space 404
    next: .asciiz "\n"

.macro readInt(%s)
    li $v0, 5
    syscall
    move %s, $v0
.end_macro

.macro printInt(%s)
    move $a0, %s
    li $v0, 1
    syscall
    la $a0, next
    li $v0, 4
    syscall
.end_macro

.macro end
    li $v0, 10
    syscall
.end_macro

.text
    Main:
        readInt($s0)     # n
        readInt($s1)     # m
        li $t0, 0        # i
        li $t1, 0        # cnt
        li $t2, 0        # flag
        while_begin:
            beq $t2, $s0, while_end 
            if_begin:
                sll $t3, $t0, 2
                la $t5, book
                add $t5, $t5, $t3
                lw $t3, 0($t5)     # book[i]
                bne $t3, $zero, state2
                
            state1:
                addi $t4, $s1, -1   # m-1
                bne $t1, $t4, if_end
                addi $t4, $t0, 1   # i + 1
                printInt($t4)
                addi $t2, $t2, 1
                li $t3, 1
                sw $t3, 0($t5)
                
                j if_end
            state2:
                addi $t0, $t0, 1
                div $t0, $s0
                mfhi $t0
                
                j while_begin
            if_end:
                
            addi $t1, $t1, 1
            div $t1, $s1
            mfhi $t1    
            addi $t0, $t0, 1
            div $t0, $s0
            mfhi $t0
            
            j while_begin
        while_end:
        
        end
