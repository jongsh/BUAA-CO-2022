.data
    graphy: .space 400           # 10 X 10 graphy  
    book: .space 40
    stack: .space 400

.macro end
    li $v0, 10
    syscall
.end_macro
.macro getint(%s)
    li $v0, 5
    syscall
    move %s, $v0
.end_macro
.macro printint(%s)
    li $v0, 1
    move $a0, %s
    syscall
.end_macro
.macro push(%s)
    sw %s, 0($sp)
    addi $sp, $sp, 4
.end_macro
.macro pop(%s)
    addi $sp, $sp, -4
    lw %s, 0($sp)
.end_macro
.macro printstr(%s)
    li $v0, 4
    move $a0, %s              # set $a0 to the content address of %s
    syscall
.end_macro
.macro getindex(%ans, %i, %j)  
    mul %ans, %i, 10
    add %ans, %ans, %j
    sll %ans, %ans, 2
.end_macro 

.text 
    main:
        la $sp, stack
    	li $s5, 1
    	li $s6, 0
    
    	getint($s0)               # $s0 = n
    	getint($s1)               # $s1 = m
    	li $t1, 0                 # $t1 = i from 0 to m-1
    	for_1_begin:
            beq $t1, $s1, for_1_end
            getint($s2)
            getint($s3)
            getindex($t0,$s2,$s3)
            sw $s5, graphy($t0)
            getindex($t0,$s3,$s2)
            sw $s5, graphy($t0) 
            addi $t1, $t1, 1
            j for_1_begin
    	for_1_end:
    	
        li $t1, 1
        li $a0, 1   # start from vert-1
        jal dfs
        printint($v1)
        
        end
    
    dfs:
    	push($t1)                # push the vert
    	push($t2)                # push the address of vert in book
    	push($ra)                # push the function address
    	push($t4)
    	move $t1, $a0            # deliver the parameter searching vert-$a0
    	mul $t2, $t1, 4
  	sw $s5, book($t2)        # book = 1
    	li $t3, 1                # flag = 1
    	li $t4, 0                # $t4 = 0
    	for_2_begin:
        	beq $t4, $s0, for_2_end
        	addi $t4, $t4, 1 
        	mul $t5, $t4, 4 
        	lw $t6, book($t5)
        	and $t3, $t3, $t6    # flag & book
        	j for_2_begin
    	for_2_end:
 
    	getindex($t4, $t1, $s5)  # the address G[x][1]
    	lw $t5, graphy($t4)      # $t5 = G[x][1]
    	and $t3, $t5, $t3        # $t3 = flag & $t5 
    
    	if_1_begin:
       		beq $t3, $zero, if_1_end
        	li $v1, 1
        	j end_dfs
    	if_1_end:    
    
    
    	li $t4, 0                # $t4 = i
    	for_3_begin:
       	    beq $t4, $s0, for_3_end
       	    addi $t4, $t4, 1
    	    mul $t5, $t4, 4
    	    lw $t6, book($t5)
    	    getindex($t3, $t1, $t4)
    	    lw $t7, graphy($t3)            # $t7 = G[x][i]
    	    if_2_begin: 
                beq $t6, $s5, if_2_end     # $t6 == 0
            
      	        if_3_begin: 
     	            beq $t7, $zero, if_3_end
    	            move $a0, $t4
                    jal dfs
                    nop
                if_3_end:
                nop  
            if_2_end: 
            beq $v1, $s5, for_3_end
            j for_3_begin     
    	for_3_end:    
        
    	end_dfs:
        sw $s6, book($t2)         # book = 0
        pop($t4)
        pop($ra)
        pop($t2)
        pop($t1)
        jr $ra                    # return 
        
          
            
              
                
                  
                    
                      
                        
                            
