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
    li $v0, 36
    move $a0, %s
    syscall
.end_macro

.text
    Main:
        readInt($s0)     # n
        li $s1, 0        # sum
        li $t1, 1        # temp
        li $t0, 1        # i
        for_begin:
            slt $t2, $s0, $t0
            bne $t2, $zero, for_end
            mul $t1, $t1, $t0
            addu $s1, $s1, $t1
            
            addi $t0, $t0, 1
            j for_begin
        for_end:
        
        printInt($s1)
        end
        
        
        end