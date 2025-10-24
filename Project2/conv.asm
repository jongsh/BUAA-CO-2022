.data
    Matrix1: .space 576
    Matrix2: .space 576
    Matrix3: .space 576
    Nextline: .asciiz "\n"
    Space: .asciiz " "
    
.macro end
    li $v0, 10
    syscall
.end_macro

.macro getindex(%ans, %i, %j)
    mul %ans, %i, 12
    add %ans, %ans, %j
    sll %ans, %ans, 2
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
    
.text
    Main:
        readInt($s1)            # m1
        readInt($s2)            # n1
        readInt($s3)            # m2
        readInt($s4)            # n2
        li $t0, 0               # i
        li $t1, 0               # j
        li $t2, 0               # k
        li $t3, 0               # l
        for_11_begin:
            beq $t0, $s1, for_11_end
            li $t1, 0
            for_12_begin:
                beq $t1, $s2, for_12_end
                la $t5, Matrix1
                getindex($t6, $t0, $t1)
                add $t5, $t5, $t6
                readInt($t4)
                sw $t4, 0($t5)
                addi $t1, $t1, 1
                j for_12_begin
            for_12_end:
            addi $t0, $t0, 1
            j for_11_begin 
        for_11_end:
        
        li $t0, 0               # i
        li $t1, 0               # j
        for_21_begin:
            beq $t0, $s3, for_21_end
            li $t1, 0
            for_22_begin:
                beq $t1, $s4, for_22_end
                la $t5, Matrix2
                getindex($t6, $t0, $t1)
                add $t5, $t5, $t6
                readInt($t4)
                sw $t4, 0($t5)
                addi $t1, $t1, 1
                j for_22_begin
            for_22_end:
            addi $t0, $t0, 1
            j for_21_begin 
        for_21_end:
        
        li $t0, 0               # i
        li $t1, 0               # j
        li $t2, 0               # k
        li $t3, 0               # l
        sub $s5, $s1, $s3       # m1-m2+1
        addi $s5, $s5, 1
        sub $s6, $s2, $s4       # n1-n2+1
        addi $s6, $s6, 1
        for_31_begin:
            beq $t0, $s5, for_31_end
            li $t1, 0
            for_32_begin:
                beq $t1, $s6, for_32_end
                li $t2, 0
                la $t5, Matrix3
                getindex($t6, $t0, $t1)
                add $t5, $t5, $t6
                lw $t7, 0($t5)     # m3[i][j]
                for_41_begin:
                    beq $t2, $s3, for_41_end
                    li $t3, 0
                    for_42_begin:
                        beq $t3, $s4, for_42_end
                        la $t5, Matrix1
                        add $s7, $t0, $t2   # i + k
                        add $t6, $t1, $t3   # j + l
                        getindex($a0, $s7, $t6)
                        add $t5, $t5, $a0
                        lw $t8, 0($t5)    # m1[i+k][j+l]
                        la $t5, Matrix2
                        getindex($t6, $t2, $t3)
                        add $t5, $t5, $t6
                        lw $t9, 0($t5)   # m2[k][l]
                        mul $t5, $t8, $t9
                        add $t7, $t7, $t5
                        addi $t3, $t3, 1
                        j for_42_begin
                    for_42_end:
                    addi $t2, $t2, 1
                    j for_41_begin
                for_41_end:
                la $t5, Matrix3
                getindex($t6, $t0, $t1)
                add $t5, $t5, $t6
                sw $t7, 0($t5)
                addi $t1, $t1, 1
                j for_32_begin
            for_32_end:
            addi $t0, $t0, 1
            j for_31_begin
        for_31_end:
        
        li $t0, 0               # i
        li $t1, 0               # j
        for_51_begin:
            beq $t0, $s5, for_51_end
            li $t1, 0
            for_52_begin:
                beq $t1, $s6, for_52_end
                la $t5, Matrix3
                getindex($t6, $t0, $t1)
                add $t5, $t5, $t6
                lw $t7, 0($t5)
                printInt($t7)
                printSpace
                addi $t1, $t1, 1
                j for_52_begin
            for_52_end:
            printNextLine
            addi $t0, $t0, 1
            j for_51_begin
        for_51_end:
        
        end













