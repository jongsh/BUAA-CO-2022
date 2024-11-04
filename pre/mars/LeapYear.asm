li $v0 5
syscall                       # read the n
move $s0 $v0                  # $s0 = n

li $s1 100
li $s2 4
li $s3 400

div $s0 $s1
mfhi $t0                      # $t0 = n % 100  
div $s0 $s2
mfhi $t1                      # $t1 = n % 4
div $s0 $s3
mfhi $t2                      # $t2 = n % 400

beq $t0 $zero if_1_end        
 beq $t1 $zero if_2_end
 li $a0 0
 j end
 
 if_2_end:
  li $a0 1
 j end
  
if_1_end:                     # if n % 100 == 0
 beq $t2 $zero if_3_end
 li $a0 0
 j end
 
 if_3_end:
  li $a0 1
  
end:
 li $v0 1
 syscall
 
