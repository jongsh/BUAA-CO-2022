.data
    Puzzle: .space 400
    index: .space 400
    
.macro end
    li $v0, 10
    syscall
.end_macro

.macro getindex(%ans, %i, %j)
    mul %ans, %i, 10
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

.macro push(%s)
    sw %s, 0($sp)
    addi $sp, $sp, -4
.end_macro

.macro pop(%s)
    addi $sp, $sp, 4
    lw %s, 0($sp)
.end_macro 

.text:
    Main:
        readInt($s0)   # n
        readInt($s1)   # m
        
        li $t0, 0      # i
        li $t1, 0      # j
        li $t2, 10     # temp = 10
        for_11_begin:
            beq $t0, $t2, for_11_end
            li $t1, 0
            for_12_begin:
                beq $t1, $t2, for_12_end
                getindex($t4, $t0, $t1) # t4
                la $t5, index
                add $t5, $t5, $t4
                li $t4, 1
                sw $t4, 0($t5)
                
                addi $t1, $t1, 1
                j for_12_begin
            for_12_end:
            addi $t0, $t0, 1
            j for_11_begin
        for_11_end:
        
        li $t0, 1    # i = 1
        li $t1, 1    # j = 1 
        for_21_begin:
            slt $t3, $s0, $t0
            bne $t3, $zero, for_21_end
            li $t1, 1
            for_22_begin:
                slt $t3, $s1, $t1
                bne $t3, $zero, for_22_end
                
                readInt($t4)   #  read
                la $t5, Puzzle
                getindex($t6, $t0, $t1)
                add $t5, $t5, $t6
                sw $t4, 0($t5)
                la $t5, index
                add $t5, $t5, $t6
                sw $zero, 0($t5)
                
                addi $t1, $t1, 1
                j for_22_begin
            for_22_end:
            addi $t0, $t0, 1
            j for_21_begin
        for_21_end:
        
        readInt($s2)   # from1
        readInt($s3)   # from2
        readInt($s4)   # to1
        readInt($s5)   # to2
        
        li $s6, 0        # ans
        move $a0, $s2    # from1 -- $a0
        move $a1, $s3    # from2 -- $a1
        jal Fun
        
        printInt($s6)
        end
        
        
    Fun:
        push($ra)    # store the return address
        
        if_begin:
            bne $a0, $s4, if_state2
            bne $a1, $s5, if_state2 
        
        if_state1:
            addi $s6, $s6, 1  # ans += 1
            pop($ra)
            jr $ra
        if_state2:
            getindex($t0, $a0, $a1)
            la $t5, index
            add $t5, $t5, $t0
            li $t6, 1
            sw $t6, 0($t5)   # t6 = index[i][j]
            move $t0, $a0    # i
            move $t1, $a1    # j
            
            if_1_begin:
                addi $t2, $t0, -1  # tempi
                addi $t3, $t1, 0   # tempj
                getindex($t4, $t2, $t3)
                la $t5, index
                add $t5, $t5, $t4
                lw $t6, 0($t5)
                bne $t6, $zero, if_1_end
                la $t5, Puzzle
                add $t5, $t5, $t4
                lw $t6, 0($t5)
                bne $t6, $zero, if_1_end
                push($t0)
                push($t1)
                push($a0)    # i
                push($a1)    # j
                move $a0, $t2
                move $a1, $t3
                jal Fun
                pop($a1)
                pop($a0)
                pop($t1)
                pop($t0)
                
            if_1_end:
            
            
            if_2_begin:
                addi $t2, $t0, 0  # tempi
                addi $t3, $t1, 1   # tempj
                getindex($t4, $t2, $t3)
                la $t5, index
                add $t5, $t5, $t4
                lw $t6, 0($t5)
                bne $t6, $zero, if_2_end
                la $t5, Puzzle
                add $t5, $t5, $t4
                lw $t6, 0($t5)
                bne $t6, $zero, if_2_end
                push($t0)
                push($t1)
                push($a0)    # i
                push($a1)    # j
                move $a0, $t2
                move $a1, $t3
                jal Fun
                pop($a1)
                pop($a0)
                pop($t1)
                pop($t0)
            if_2_end:
            
            
            if_3_begin:
                addi $t2, $t0, 1   # tempi
                addi $t3, $t1, 0   # tempj
                getindex($t4, $t2, $t3)
                la $t5, index
                add $t5, $t5, $t4
                lw $t6, 0($t5)
                bne $t6, $zero, if_3_end
                la $t5, Puzzle
                add $t5, $t5, $t4
                lw $t6, 0($t5)
                bne $t6, $zero, if_3_end
                push($t0)
                push($t1)
                push($a0)    # i
                push($a1)    # j
                move $a0, $t2
                move $a1, $t3
                jal Fun
                pop($a1)
                pop($a0)
                pop($t1)
                pop($t0)
            if_3_end:
            
            if_4_begin:
                addi $t2, $t0, 0   # tempi
                addi $t3, $t1, -1  # tempj
                getindex($t4, $t2, $t3)
                la $t5, index
                add $t5, $t5, $t4
                lw $t6, 0($t5)
                bne $t6, $zero, if_4_end
                la $t5, Puzzle
                add $t5, $t5, $t4
                lw $t6, 0($t5)
                bne $t6, $zero, if_4_end
                push($t0)
                push($t1)
                push($a0)    # i
                push($a1)    # j
                move $a0, $t2
                move $a1, $t3
                jal Fun
                pop($a1)
                pop($a0)
                pop($t1)
                pop($t0)
            if_4_end:
            
            getindex($t0, $a0, $a1)
            la $t5, index
            add $t5, $t5, $t0
            sw $zero, 0($t5)
            
        if_end:
        
        pop($ra)
        jr $ra
    