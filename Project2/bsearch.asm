.data
    num: .space 4000
    nextline: .asciiz "\n"
    
.macro end
    li $v0, 10
    syscall
.end_macro

.macro printnext
    li $v0, 4
    la $a0, nextline
    syscall
.end_macro

.macro printInt(%s)
    move $a0, %s
    li $v0, 1
    syscall
.end_macro

.macro readInt(%s)
    li $v0, 5
    syscall
    move %s, $v0
.end_macro

.text
    Main:  
        readInt($s0)    # m
        li $t0, 0       # i
        la $t5, num
        for_1_begin:
            beq $t0, $s0, for_1_end
            sll $t1, $t0, 2
            add $t1, $t5, $t1
            readInt($t2)
            sw $t2, 0($t1)
            addi $t0, $t0, 1
            j for_1_begin
        for_1_end:
        
        readInt($s1)    # n
        li $t0, 0       # i
        for_2_begin:
            beq $t0, $s1, for_2_end
            readInt($a1)  
            jal bsearch
            printInt($v1)
            printnext
            addi $t0, $t0, 1
            j for_2_begin
        for_2_end:
        
        end
        
    bsearch:
        
        li $t1, 0           # low
        addi $t2, $s0, -1   # high
        li $t4, 0           # count
        li $t6, 0           # count1
        li $v1, 0           # return value
         
        for_fun_begin:
            slt $t3, $t2, $t1
            bne $t3, $zero, for_fun_end
            addi $t4, $t4, 1
            add $t3, $t1, $t2   # mid
            sra $t3, $t3, 1
            if_judge:
                la $t5, num
                sll $t7, $t3, 2
                add $t5, $t5, $t7
                lw $t7, 0($t5)  # a[mid]
                slt $t5, $a1, $t7
                bne $t5, $zero state1    # <
                beq $a1, $t7, state3     # ==
                j state2                 # >
            state1:
                addi $t2, $t3, -1
                j if_judge_end
            state2:
                addi $t1, $t3, 1
                j if_judge_end
            state3:  
                li $v1, 1
                j for_fun_end
            if_judge_end:
            
            j for_fun_begin
        for_fun_end:
        
        jr $ra
        
        
        
      
    
