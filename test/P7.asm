andi $sp,$sp,0
ori $sp,$sp,0x10
jal test_AdES
nop
jal test_AdEL
nop
jal test_Syscall
nop
jal test_RI
nop
jal test_Ov
nop
jal test_specials
nop
jal End
nop
test_AdES:
lui $1, 0x7fff
sw $2, 0x7fff($1)
sh $2, 0x7fff($1)
sb $2, 0x7fff($1)
sw $2, 0x7fff($0)
sw $2, 0x3004($0)
sw $2, 0x7f24($0)
sw $2, 0x7f98($0)
sw $2, 0x4184($0)
sh $2, 0x7fff($0)
sh $2, 0x3004($0)
sh $2, 0x7f24($0)
sh $2, 0x7f98($0)
sh $2, 0x4184($0)
sb $2, 0x7fff($0)
sb $2, 0x3004($0)
sb $2, 0x7f24($0)
sb $2, 0x7f98($0)
sb $2, 0x4184($0)
sw $2, 0x7f08($0)
sw $2, 0x7f18($0)
sh $2, 0x7f08($0)
sh $2, 0x7f18($0)
sb $2, 0x7f08($0)
sb $2, 0x7f18($0)
sh $2, 0x7f00($0)
sh $2, 0x7f02($0)
sh $2, 0x7f10($0)
sh $2, 0x7f12($0)
sb $2, 0x7f00($0)
sb $2, 0x7f02($0)
sb $2, 0x7f10($0)
sb $2, 0x7f12($0)
sw $2, 0x1($0)
sw $2, 0x2($0)
sw $2, 0x3($0)
sh $2, 0x1($0)
sh $2, 0x3($0)
jr $ra
nop
test_AdEL:
lui $1, 0x7fff
lw $2, 0x7fff($1)
lh $2, 0x7fff($1)
lb $2, 0x7fff($1)
lw $2, 0x7fff($0)
lw $2, 0x3004($0)
lw $2, 0x7f24($0)
lw $2, 0x7f98($0)
lw $2, 0x4184($0)
lh $2, 0x7fff($0)
lh $2, 0x3004($0)
lh $2, 0x7f24($0)
lh $2, 0x7f98($0)
lh $2, 0x4184($0)
lb $2, 0x7fff($0)
lb $2, 0x3004($0)
lb $2, 0x7f24($0)
lb $2, 0x7f98($0)
lb $2, 0x4184($0)
lh $2, 0x7f00($0)
lh $2, 0x7f02($0)
lh $2, 0x7f10($0)
lh $2, 0x7f12($0)
lb $2, 0x7f00($0)
lb $2, 0x7f02($0)
lb $2, 0x7f10($0)
lb $2, 0x7f12($0)
lw $2, 0x1($0)
lw $2, 0x2($0)
lw $2, 0x3($0)
lh $2, 0x1($0)
lh $2, 0x3($0)
wPC1:
andi $1, $1, 0x0
ori $1, $1, 0x8fff
jr $1
nop
wPC2:
andi $1, $1, 0x0
ori $1, $1, 0x3002
jr $1
nop
wPC3:
andi $1, $1, 0x0
ori $1, $1, 0x2ff8
jr $1
nop
wPC4:
andi $1, $1, 0x0
ori $1, $1, 0x77f8
jr $1
nop
test_wPC_end:
jr $ra
nop
test_Syscall:
syscall
jr $ra
nop
test_RI:
nop
test_RI_1:
nop
test_RI_End:
nop
test_Ov:
andi $1, $1, 0x0
lui $1, 0x7fff
add $1, $1, $1
addi $1, $1, 0x7fff
lui $1, 0x7fff
lui $2, 0x8001
sub $1, $1, $1
jr $ra
nop
test_specials:
mult $1, $1
nop
multu $1, $1
nop
div $1, $2
nop
divu $1, $2
nop
mfhi $1
nop
mflo $1
nop
mthi $1
nop
mtlo $1
nop
beq $0, $0, epc1
lw $2, 0x3($0)
epc1:
beq $0, $0, epc2
lw $2, 0x3($0)
epc2:
beq $0, $0, epc3
lw $2, 0x3($0)
epc3:
lw $1, 0x4($0)
sw $1, 0x4($0)
lw $1, 0x4($0)
addi $1, $1, 0x1
jr $ra
nop
End:
beq $0, $0,EndOfAll
nop


RI1:
nop
RI2:
nop

.ktext 0x4180
ori $s0,$s0,0x8fff
ori $s1,$s1,0x3002
ori $s2,$s2,0x2ff8
ori $s3,$s3,0x77f8
la $s6,test_RI
la $s7,test_RI_1
mfc0 $k0,$14
mfc0 $k1,$13
mfc0 $s4,$12
sw $s4,($sp)
addi $sp,$sp,4
sw $k0,($sp)
addi $sp,$sp,4
sw $k1,($sp)
addi $sp,$sp,4
beq $k0,$s0,return0
nop
beq $k0,$s1,return1
nop
beq $k0,$s2,return2
nop
beq $k0,$s3,return3
nop
beq $k0,$s6,return4
nop
beq $k0,$s7,return5
add $k0,$k0,4
mtc0 $k0,$14
eret
ori $10,$10,5
return0:
la $s5,wPC2
mtc0 $s5,$14
eret
return1:
la $s5,wPC3
mtc0 $s5,$14
eret
return2:
la $s5,wPC4
mtc0 $s5,$14
eret
return3:
la $s5,test_wPC_end
mtc0 $s5,$14
eret
return4:
la $s5,test_RI_1
mtc0 $s5,$14
eret
return5:
la $s5,test_RI_End
mtc0 $s5,$14
eret
EndOfAll:
