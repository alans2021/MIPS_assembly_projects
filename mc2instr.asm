.data
	msg: 	.asciiz		"Please enter a machine code (hexadecimal): "
	add:	.asciiz		"add"
	addi:	.asciiz		"addi"
	and: 	.asciiz		"and"
	andi: 	.asciiz		"andi"
	sub: 	.asciiz		"sub"
	or:	.asciiz		"or"
	ori:	.asciiz		"ori"
	nor: 	.asciiz		"nor"
	slt: 	.asciiz		"slt"
	slti: 	.asciiz		"slti"
	sll:	.asciiz		"sll"
	srl:	.asciiz		"srl"
	beq: 	.asciiz		"beq"
	bne: 	.asciiz		"bne"
	j: 	.asciiz		"j"
	jal:	.asciiz		"jal"
	jr:	.asciiz		"jr"
	lw: 	.asciiz		"lw"
	sw: 	.asciiz		"sw"
	lh: 	.asciiz		"lh"
	sh:	.asciiz		"sh"
	lb:	.asciiz		"lb"
	sb: 	.asciiz		"sb"
	.align 3
	zeroes:	.asciiz		"00"
	.align 3
	buffer: .space		9
	.align 3
	eight:	.asciiz		"08 "
	C:	.asciiz		"0c "
	D:	.asciiz		"0d "
	A:	.asciiz		"0a "
	four:	.asciiz		"04 "
	five:	.asciiz		"05 "
	two:	.asciiz		"02 "
	three:	.asciiz		"03 "
	two3:	.asciiz		"23 "
	twoB:	.asciiz		"2b "
	two1:	.asciiz		"21 "
	two9:	.asciiz		"29 "
	two0:	.asciiz		"20 "
	two8:	.asciiz		"28 "
	two4:	.asciiz		"24 "
	two2:	.asciiz		"22 "
	two5:	.asciiz		"25 "
	two7:	.asciiz		"27 "
	twoA:	.asciiz		"2a "
	
	
.text
	loop:
		addi $v0, $zero, 4	#Initial message to enter hexadecimal
		la $a0, msg
		syscall
		
		addi $v0, $zero, 8	#Read in string
		la $a0, buffer
		addi $a1, $zero, 9
		syscall
		
		addi $a0, $zero, 10	#Make newLine character
		addi $v0, $zero, 11
		syscall
				
		la $a0, buffer
		la $a1, zeroes
		jal _strCompOp
		add $s0, $zero, $v0
		
		bne $s0, $zero, noFunc	#If opcode is not 00, go to noFunc branch
		j Func			#If it is, go to Func branch
		
	noFunc:
		la $a0, buffer
		la $a1, eight
		jal _strCompOp
		add $s0, $zero, $v0
		beq $s0, $zero, printaddi	#If match, print addi, if not, continue next comparison
		
		la $a0, buffer
		la $a1, C
		jal _strCompOp
		add $s0, $zero, $v0
		beq $s0, $zero, printandi
		
		la $a0, buffer
		la $a1, D
		jal _strCompOp
		add $s0, $zero, $v0
		beq $s0, $zero, printori
		
		la $a0, buffer
		la $a1, A
		jal _strCompOp
		add $s0, $zero, $v0
		beq $s0, $zero, printslti
		
		la $a0, buffer
		la $a1, four
		jal _strCompOp
		add $s0, $zero, $v0
		beq $s0, $zero, printbeq
		
		la $a0, buffer
		la $a1, five
		jal _strCompOp
		add $s0, $zero, $v0
		beq $s0, $zero, printbne
		
		la $a0, buffer
		la $a1, two
		jal _strCompOp
		add $s0, $zero, $v0
		beq $s0, $zero, printj
		
		la $a0, buffer
		la $a1, three
		jal _strCompOp
		add $s0, $zero, $v0
		beq $s0, $zero, printjal
		
		la $a0, buffer
		la $a1, two3
		jal _strCompOp
		add $s0, $zero, $v0
		beq $s0, $zero, printlw
		
		la $a0, buffer
		la $a1, twoB
		jal _strCompOp
		add $s0, $zero, $v0
		beq $s0, $zero, printsw
		
		la $a0, buffer
		la $a1, two1
		jal _strCompOp
		add $s0, $zero, $v0
		beq $s0, $zero, printlh		
		
		la $a0, buffer
		la $a1, two9
		jal _strCompOp
		add $s0, $zero, $v0
		beq $s0, $zero, printsh
		
		la $a0, buffer
		la $a1, two0
		jal _strCompOp
		add $s0, $zero, $v0
		beq $s0, $zero, printlb
		
		la $a0, buffer
		la $a1, two8
		jal _strCompOp
		add $s0, $zero, $v0
		beq $s0, $zero, printsb
		
		printaddi:
			la $a0, addi
			addi $v0, $zero, 4
			syscall
			add $a0, $zero, 10
			addi $v0, $zero, 11
			syscall
			j loop
		printandi:
			la $a0, andi
			addi $v0, $zero, 4
			syscall
			add $a0, $zero, 10
			addi $v0, $zero, 11
			syscall
			j loop
		printori:
			la $a0, ori
			addi $v0, $zero, 4
			syscall
			add $a0, $zero, 10
			addi $v0, $zero, 11
			syscall
			j loop
		printslti:
			la $a0, slti
			addi $v0, $zero, 4
			syscall
			add $a0, $zero, 10
			addi $v0, $zero, 11
			syscall
			j loop
		printbeq:
			la $a0, beq
			addi $v0, $zero, 4
			syscall
			add $a0, $zero, 10
			addi $v0, $zero, 11
			syscall
			j loop
		printbne:
			la $a0, bne
			addi $v0, $zero, 4
			syscall
			add $a0, $zero, 10
			addi $v0, $zero, 11
			syscall
			j loop
		printj:
			la $a0, j
			addi $v0, $zero, 4
			syscall
			add $a0, $zero, 10
			addi $v0, $zero, 11
			syscall
			j loop
		printjal:
			la $a0, jal
			addi $v0, $zero, 4
			syscall
			add $a0, $zero, 10
			addi $v0, $zero, 11
			syscall
			j loop
		printlw:
			la $a0, lw
			addi $v0, $zero, 4
			syscall
			add $a0, $zero, 10
			addi $v0, $zero, 11
			syscall
			j loop
		printsw:
			la $a0, sw
			addi $v0, $zero, 4
			syscall
			add $a0, $zero, 10
			addi $v0, $zero, 11
			syscall
			j loop
		printlh:
			la $a0, lh
			addi $v0, $zero, 4
			syscall
			add $a0, $zero, 10
			addi $v0, $zero, 11
			syscall
			j loop
		printsh:
			la $a0, sh
			addi $v0, $zero, 4
			syscall
			add $a0, $zero, 10
			addi $v0, $zero, 11
			syscall
			j loop
		printlb:
			la $a0, lb
			addi $v0, $zero, 4
			syscall
			add $a0, $zero, 10
			addi $v0, $zero, 11
			syscall
			j loop
		printsb:
			la $a0, sb
			addi $v0, $zero, 4
			syscall
			add $a0, $zero, 10
			addi $v0, $zero, 11
			syscall
			j loop	
	Func:
		la $a0, buffer
		la $a1, two0
		jal _strCompFunc
		add $s0, $zero, $v0
		beq $s0, $zero, printadd	#If match, print add, if not, continue next comparison			
		
		la $a0, buffer
		la $a1, two4
		jal _strCompFunc
		add $s0, $zero, $v0
		beq $s0, $zero, printand
		
		la $a0, buffer
		la $a1, two2
		jal _strCompFunc
		add $s0, $zero, $v0
		beq $s0, $zero, printsub
		
		la $a0, buffer
		la $a1, two5
		jal _strCompFunc
		add $s0, $zero, $v0
		beq $s0, $zero, printor
		
		la $a0, buffer
		la $a1, two7
		jal _strCompFunc
		add $s0, $zero, $v0
		beq $s0, $zero, printnor
		
		la $a0, buffer
		la $a1, twoA
		jal _strCompFunc
		add $s0, $zero, $v0
		beq $s0, $zero, printslt
		
		la $a0, buffer
		la $a1, zeroes
		jal _strCompFunc
		add $s0, $zero, $v0
		beq $s0, $zero, printsll
		
		la $a0, buffer
		la $a1, two
		jal _strCompFunc
		add $s0, $zero, $v0
		beq $s0, $zero, printsrl
		
		la $a0, buffer
		la $a1, eight
		jal _strCompFunc
		add $s0, $zero, $v0
		beq $s0, $zero, printjr
		
		printadd:
			la $a0, add
			addi $v0, $zero, 4
			syscall
			add $a0, $zero, 10
			addi $v0, $zero, 11
			syscall
			j loop
		printand:
			la $a0, and
			addi $v0, $zero, 4
			syscall
			add $a0, $zero, 10
			addi $v0, $zero, 11
			syscall
			j loop
		printor:
			la $a0, or
			addi $v0, $zero, 4
			syscall
			add $a0, $zero, 10
			addi $v0, $zero, 11
			syscall
			j loop
		printslt:
			la $a0, slt
			addi $v0, $zero, 4
			syscall
			add $a0, $zero, 10
			addi $v0, $zero, 11
			syscall
			j loop
		printsub:
			la $a0, sub
			addi $v0, $zero, 4
			syscall
			add $a0, $zero, 10
			addi $v0, $zero, 11
			syscall
			j loop
		printnor:
			la $a0, nor
			addi $v0, $zero, 4
			syscall
			add $a0, $zero, 10
			addi $v0, $zero, 11
			syscall
			j loop
		printsll:
			la $a0, sll
			addi $v0, $zero, 4
			syscall
			add $a0, $zero, 10
			addi $v0, $zero, 11
			syscall
			j loop
		printsrl:
			la $a0, srl
			addi $v0, $zero, 4
			syscall
			add $a0, $zero, 10
			addi $v0, $zero, 11
			syscall
			j loop
			
		printjr:
			la $a0, jr
			addi $v0, $zero, 4
			syscall
			add $a0, $zero, 10
			addi $v0, $zero, 11
			syscall
			j loop
		
# _strCompOp
#
# Compare two null-terminated strings. If first two characters of inputted string in $a0 matches,
# 0 will be returned. Otherwise, -1 will be returned.
#
# Arguments:
#   - $a0: an address of the first null-terminated string
#   - $a1: an address of the second null-terminated string
# Return Value
#   - $v0: 0 if first two characters of inputted string matches. Otherwise, -1
_strCompOp:
	addi $sp, $sp, -8	#Adjust stack
	sw $s1, 0($sp)
	sw $s2, 4($sp)
	
	lh $s1, 0($a0)		#Load byte in $s1, which is two characters
	lh $s2, 0($a1)		#Load two characters in $s2
	bne $s1, $s2, notEqual	#If two registers not equal, go to notEqual
	j Equal			#
	
	Equal:
		addi $v0, $zero, 0	#Store 0 to $v0, then go to done
		j done
	notEqual:
		addi $v0, $zero, -1	#Store -1 to $v0, then go to done
		j done
	done:
		lw $s1, 0($sp)
		lw $s2, 4($sp)
		addi $sp, $sp, 8
		jr   $ra

# _strCompFunc
#
# Compare two null-terminated strings. If last two characters of inputted string in $a0 matches,
# 0 will be returned. Otherwise, -1 will be returned.
#
# Arguments:
#   - $a0: an address of the first null-terminated string
#   - $a1: an address of the second null-terminated string
# Return Value
#   - $v0: 0 if first two characters of inputted string matches. Otherwise, -1
_strCompFunc:
	addi $sp, $sp, -8	#Adjust stack
	sw $s1, 0($sp)
	sw $s2, 4($sp)
	
	lh $s1, 6($a0)		#Load $s1, which is two characters
	lh $s2, 0($a1)		#Load two characters in $s2
	bne $s1, $s2, notEqualf	#If two registers not equal, go to notEqual
	j Equalf			#
	
	Equalf:
		addi $v0, $zero, 0	#Store 0 to $v0, then go to done
		j donef
	notEqualf:
		addi $v0, $zero, -1	#Store -1 to $v0, then go to done
		j donef
	donef:
		lw $s1, 0($sp)
		lw $s2, 4($sp)
		addi $sp, $sp, 8
		jr   $ra
		
	
