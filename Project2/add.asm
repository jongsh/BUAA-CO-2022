.data 
    matrix1: .space 400
    matrix2: .space 400
    matrix3: .space 400
    Nextline: .asciiz "\n"
    Space: .asciiz " "
    output: .asciiz "The result is:"

.macro readInt(%s)
    li $v0, 5
    syscall
    move %s, $v0
.end_macro

.macro end
    li $v0, 10
    syscall
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

.macro output
    la $a0, output
    li $v0, 4
    syscall
.end_macro

.macro getindex(%s, %i, %j)
    mul %s, %i, 10
    add %s, %s, %j
    sll %s, %s, 2
.end_macro

.text
    Main:
        readInt($s0)    # n
        readInt($s1)    # m
        li $t0, 0       # i
        
        for_11_begin:
            li $t1, 0   #j
            beq $t0, $s0, for_11_end
            for_12_begin:
                beq $t1, $s1, for_12_end
                readInt($t2)   # newdata
                la $t5, matrix1
                getindex($t3, $t0, $t1)
                sll $t3, $t3, 2
                add $t5, $t5, $t3
                sw $t2, 0($t5)
                addi $t1, $t1, 1
                j for_12_begin
            for_12_end:
            addi $t0, $t0, 1
            j for_11_begin
        for_11_end:
        
        li $t0, 0    # i
        for_21_begin:
            li $t1, 0   #j
            beq $t0, $s0, for_21_end
            for_22_begin:
                beq $t1, $s1, for_22_end
                readInt($t2)   # newdata
                la $t5, matrix2
                getindex($t3, $t0, $t1)
                sll $t3, $t3, 2
                add $t5, $t5, $t3
                sw $t2, 0($t5)
                addi $t1, $t1, 1
                j for_22_begin
            for_22_end:
            addi $t0, $t0, 1
            j for_21_begin
        for_21_end:

        li $t0, 0    # i
        for_31_begin:
            li $t1, 0   #j
            beq $t0, $s1, for_31_end
            for_32_begin:
                beq $t1, $s0, for_32_end
                la $t5, matrix1
                getindex($t3, $t1, $t0)
                sll $t3, $t3, 2
                add $t5, $t5, $t3
                lw $t2, 0($t5)   # matrix1[j][i]
                move $t4, $t2
                
                la $t5, matrix2
                getindex($t3, $t1, $t0)
                sll $t3, $t3, 2
                add $t5, $t5, $t3
                lw $t2, 0($t5)   # matrix2[j][i]
                add $t4, $t4, $t2
                
                la $t5, matrix3
                getindex($t3, $t0, $t1)
                sll $t3, $t3, 2
                add $t5, $t5, $t3
                sw $t4, 0($t5)
                addi $t1, $t1, 1
                j for_32_begin
            for_32_end:
            addi $t0, $t0, 1
            j for_31_begin
        for_31_end:

        output
        printNextLine
        li $t0, 0   #i
        for_41_begin: 
            li $t1, 0 #j
            beq $t0, $s1, for_41_end
            for_42_begin:
                beq $t1, $s0, for_42_end
                la $t5, matrix3
                getindex($t2, $t0, $t1)
                sll $t2, $t2, 2
                add $t5, $t5, $t2
                lw $t3, 0($t5)
                printInt($t3)
                if_begin:
                    addi $s3, $s0, -1  # n-1
                    addi $s4, $s1, -1  # m-1
                    beq $t1, $s3, state1
                    j state3
                state1:
                    beq $t0, $s4, state2
                    printNextLine
                    j if_end
                state2:
                    
                    j if_end
                state3:
                    printSpace
                if_end:
                addi $t1, $t1, 1
                j for_42_begin
            for_42_end:
            addi $t0, $t0, 1
            j for_41_begin
        for_41_end:
        
        end
