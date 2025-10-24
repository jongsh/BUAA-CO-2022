.data
    Matrix1: .space 256
    Matrix2: .space 256
    Matrix3: .space 256
    Nextline: .asciiz "\n"
    Space: .asciiz " "
    
.macro end
    li $v0, 10
    syscall
.end_macro

.macro getindex(%ans, %i, %j)
    sll %ans, %i, 3
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
        readInt($s1)         # s1 = n
        
        li $t0, 0            # i
        li $t1, 0            # j 
        for_1_begin:
           beq $s1, $t0, for_1_end 
           li $t1, 0
           for_2_begin:
               beq $s1, $t1, for_2_end
               readInt($t5)
               getindex($t3, $t0, $t1)
               la $t4, Matrix1
               add $t4, $t4, $t3
               sw $t5, 0($t4)
               addi $t1, $t1, 1
               j for_2_begin    
           for_2_end:
           addi $t0, $t0, 1
           j for_1_begin
        for_1_end:
        
        li $t0, 0            # i
        li $t1, 0            # j 
        for_3_begin:
           beq $s1, $t0, for_3_end 
           li $t1, 0
           for_4_begin:
               beq $s1, $t1, for_4_end
               readInt($t5)
               getindex($t3, $t0, $t1)
               la $t4, Matrix2
               add $t4, $t4, $t3
               sw $t5, 0($t4)
               addi $t1, $t1, 1
               j for_4_begin    
           for_4_end:
           addi $t0, $t0, 1
           j for_3_begin
        for_3_end:
        
        li $t0, 0            # i
        li $t1, 0            # j 
        li $t2, 0            # x
        for_51_begin:
            beq $s1, $t0, for_51_end 
            li $t1, 0
            for_52_begin:
                beq $s1, $t1, for_52_end
                li $t2, 0
                la $t4, Matrix3
                getindex($t3, $t0, $t1)
                add $t4, $t4, $t3
                lw $t5, 0($t4)
                for_53_begin:
                    beq $t2, $s1, for_53_end
                    la $t4, Matrix1
                    getindex($t3, $t0, $t2)
                    add $t4, $t4, $t3
                    lw $t6, 0($t4)
                    la $t4, Matrix2
                    getindex($t3, $t2, $t1)
                    add $t4, $t4, $t3
                    lw $t7, 0($t4)
                    mul $t8, $t6, $t7
                    add $t5, $t5, $t8
                    addi $t2, $t2, 1
                    j for_53_begin
                for_53_end:
                la $t4, Matrix3
                getindex($t3, $t0, $t1)
                add $t4, $t4, $t3
                sw $t5, 0($t4)
                addi $t1, $t1, 1
                j for_52_begin
            for_52_end:
            addi $t0, $t0, 1
            j for_51_begin
        for_51_end:
        
        # output the answer
        li $t0, 0            # i
        li $t1, 0            # j 
        for_61_begin:
           beq $s1, $t0, for_61_end 
           li $t1, 0
           for_62_begin:
               beq $s1, $t1, for_62_end
               getindex($t3, $t0, $t1)
               la $t4, Matrix3
               add $t4, $t4, $t3
               lw $t5, 0($t4)
               printInt($t5)
               printSpace
               addi $t1, $t1, 1
               j for_62_begin    
           for_62_end:
           printNextLine
           addi $t0, $t0, 1
           j for_61_begin
        for_61_end:
        
        end
        
