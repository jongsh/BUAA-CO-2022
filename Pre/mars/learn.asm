.data
    numb: .space 40   # max = 10
    str: .asciiz "The number are\n"
    space: .asciiz " "

.macro getint(%s)
    li $v0, 5
    syscall
    move %s, $v0
.end_macro
.macro printint(%s)
    move $a0, %s
    li $v0, 1
    syscall
.end_macro
.macro printspace
    la $a0, space
    li $v0, 4
    syscall
.end_macro
.macro printstr
    la $a0, str
    li $v0, 4
    syscall
.end_macro

.text
    main:
        getint($s0)     # $s0 = n
        li $t0, 0       # $t0 = i
        loop:
            beq $t0, $s0, loop_end
            getint($t1)
            la $s1, numb
            mul $t2, $t0, 4
            add $s1, $s1, $t2
            sw $t1, 0($s1)
            addi $t0, $t0, 1
            j loop
        loop_end:
        
        printstr
        li $t0, 0
        la $s1, numb
        loop_2:
            beq $t0, $s0, loop_2_end
            mul $t2, $t0, 4
            add $t1, $s1, $t2
            lw $t3, 0($t1)
            printint($t3)
            printspace
            addi $t0, $t0, 1
            j loop_2      
        loop_2_end:
        
     