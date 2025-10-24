.data
    String: .space 20
    
.macro end
    li $v0, 10
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

.macro printInt(%s)
    move $a0, %s
    li $v0, 1
    syscall
.end_macro

.text
    Main:
        readInt($s1)     # s1 = length of the string
        li $t0, 0       
        for_1_begin:
            beq $t0, $s1 for_1_end
            readChar($s2)
            la $t5, String
            add $t5, $t5, $t0
            sb $s2, 0($t5)
            addi $t0, $t0, 1
            j for_1_begin
        for_1_end:
        
        li $t0, 0
        addi $t1, $s1, -1
        li $s2, 0         # ans
        for_2_begin:
            slt $t3, $t0, $t1
            beq $t3, $zero, for_2_end
            la $t5, String
            add $t5, $t5, $t0
            lb $s3, 0($t5)
            la $t5, String
            add $t5, $t5, $t1
            lb $s4, 0($t5)
            if_1_begin:
                beq $s4, $s3, if_1_end
                printInt($s2)
                end
            if_1_end:
            addi $t0, $t0, 1
            addi $t1, $t1, -1
            j for_2_begin
        for_2_end:
        
        li $s2, 1
        printInt($s2)
        end