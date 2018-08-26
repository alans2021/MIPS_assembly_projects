.data
	nLine:	.asciiz 	"\n"

.text
	add $t0, $zero, $zero		#Counter for inner loop
	add $t2, $zero, $zero		#Counter for outer loop
	addi $t1, $zero, 9		# 9 stored in $t1 for number of rows and number of columns
	la $s0, 0xffff8000		#Load address 0xffff8000 into $s0
	
	outerLoop:	
		beq $t2, $t1, outerDone	#Jump to outerDone when counter for outer loop equals 9
		innerLoop:
			beq $t0, $t1, innerDone	#Jump to innerDone when counter equals 9
			lb $t3, 0($s0)
			addi $v0, $zero, 1
			add $a0, $zero, $t3
			syscall
			addi $s0, $s0, 1	#Increment address
			addi $t0, $t0, 1	#Increment $t0 by 1
			j innerLoop
		innerDone:
			addi $v0, $zero, 4
			la $a0, nLine
			syscall
			add $t0, $zero, $zero	#Reset $t0 to 0
			addi $t2, $t2, 1	#Increment $t2 by 1
			j outerLoop		#Jump to outerLoop
	outerDone:
		la $a0, 0xffff8000		#Load memory in address 0xffff0000 into $a0
		add $a1, $zero, $zero		#Set row to $a1, which is zero
		add $a2, $zero, $zero		#Set column to $a2, which is zero
		jal _solveSudoku
		addi $v0, $zero, 10
		syscall

# _solveSudoku
#
# Recursive Method
# Read in the memory address of location of sudoku puzzle
# Solve the puzzle
#
# Argument:
#   - $a0: Address of element in sudoku puzzle
#   - $a1: row number
#   - $a2: column number
# Return Value
#   - $v0: Returns if function is 1 for 'true' or 0 for 'false'
_solveSudoku:
	addi $sp, $sp, -24	#Adjust stack
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $ra, 20($sp)
	
	add $s0, $zero, $a0		#Store $a0 value into $s0
	add $s2, $zero, $a1
	add $s3, $zero, $a2
	mul $s4, $s2, 9			#Multiply row number by 9
	add $s0, $s0, $s4		#Add $s4 to memory address
	add $s0, $s0, $s3		#Add column number to memory address
	beq $s3, 9, seeRow	#If column number is past the sudoku, go to seeRow
	j cont
	seeRow:
		beq $s2, 8, return	#If row number is 8, go to return
		add $s3, $zero, $zero	#If row number is not 8, just reset column number to 0
		addi $s2, $s2, 1	#Increment row number by 1
	
	cont:	
	lb $s1, 0($s0)		#Get the number at that address
	bne $s1, 0, nextAddress	#If a location in grid already stores a number, go to nextAddress
	
	addi $t0, $zero, 1	#Counter for loop
	addi $t1, $zero, 10	#If $t0 reaches 10, break out of loop
	
	sudoLoop:
		beq $t0, $t1, backtrack		#1-9 don't work, go to backtrack
		add $a0, $zero, $t0		#$a0 stores value of $t0
		add $a1, $zero, $s2		#$a1 stores row number
		add $a2, $zero, $s3		#$a2 stores column number
		
		addi $sp, $sp, -8		#Adjust stack before calling function
		sw $t0, 0($sp)
		sw $t1, 4($sp)
		jal _checkRow			#Go to checkRow function
		lw $t0, 0($sp)			#Restore stack
		lw $t1, 4($sp)
		addi $sp, $sp, 8
		
		beq $v0, $zero, nextNum		#If $v0 equals 0, go to nextNum branch
		
		addi $sp, $sp, -8		#Adjust stack before calling function
		sw $t0, 0($sp)
		sw $t1, 4($sp)
		jal _checkColumn		#Go to checkRow function
		lw $t0, 0($sp)			#Restore stack
		lw $t1, 4($sp)
		addi $sp, $sp, 8
		
		beq $v0, $zero, nextNum		#If $v0 equals 0, go to nextNum branch
		
		addi $sp, $sp, -8		#Adjust stack before calling function
		sw $t0, 0($sp)
		sw $t1, 4($sp)
		jal _checkSubGrid		#Go to checkSubGrid function
		lw $t0, 0($sp)			#Restore stack
		lw $t1, 4($sp)
		addi $sp, $sp, 8
		
		beq $v0, $zero, nextNum		#If $v0 equals 0, go to nextNum branch
		sb $t0, 0($s0)			#Store $t0 value into memory address if all three functions return 1
		
		la $a0, 0xffff8000
		add $a1, $s2, $zero
		addi $a2, $s3, 1		#Increment column number by 1
		
		addi $sp, $sp, -8		#Adjust stack before calling function
		sw $t0, 0($sp)
		sw $t1, 4($sp)
		jal _solveSudoku		#Recursive call
		lw $t0, 0($sp)			#Restore stack
		lw $t1, 4($sp)
		addi $sp, $sp, 8
		
		beq $v0, 0, nextNum		#If $v0 value equals 0, go to next number
		beq $v0, 1, return		#Go to return if $v0 value equals 1
		
		nextNum:
			addi $t0, $t0, 1	#Increment $t0 by 1
			j sudoLoop		#Loop back to sudoLoop
		
		backtrack:
			sb $zero, 0($s0)
			la $a0, 0xffff8000
			addi $a1, $s2, 0
			addi $a2, $s3, -1
			addi $v0, $zero, 0	#Return zero
			
			lw $s0, 0($sp)		#Restore stack
			lw $s1, 4($sp)
			lw $s2, 8($sp)
			lw $s3, 12($sp)
			lw $s4, 16($sp)
			lw $ra, 20($sp)
			addi $sp, $sp, 24
			jr $ra			#Go back to previous call
	nextAddress:
		la $a0, 0xffff8000
		addi $a1, $s2, 0
		addi $a2, $s3, 1
		
		addi $sp, $sp, -8		#Adjust stack before calling function
		sw $t0, 0($sp)
		sw $t1, 4($sp)
		jal _solveSudoku
		lw $t0, 0($sp)			#Restore stack
		lw $t1, 4($sp)
		addi $sp, $sp, 8
		
		lw $s0, 0($sp)		#restore stack
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $ra, 20($sp)
		addi $sp, $sp, 24
		jr $ra
	
	return:
		addi $v0, $zero, 1	#Ensures $v0 is 1 (true)
		lw $s0, 0($sp)		#restore stack
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $ra, 20($sp)
		addi $sp, $sp, 24
		jr $ra

# _checkRow
#
# Read in the row and column of puzzle
# Determines if the number is right
#
# Argument:
#   - $a0: Potential number added
#   - $a1: row number
#   - $a2: column number
# Return Value
#   - $v0: Returns if function is 1 for 'true', number can be added or 0 for 'false', number can't be added
_checkRow:
	addi $sp, $sp, -8	#Adjust stack
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	
	la $s0, 0xffff8000
	add $t0, $zero, $a0
	add $t1, $zero, $a1
	add $t2, $zero, $a2
	add $t3, $zero, $zero	#Counter
	
	mul $t1, $t1, 9		#Multiply row number by 9
	add $s0, $s0, $t1	#Adjust the memory address of $s0
	
	rowLoop:
		slti $t4, $t3, 9, 	#If $t3 is not less than 9, go to retOne. If not, continue down
		beq $t4, 0, retOne
		beq $t3, $t2, next	#If counter equals $t2 value, go to skip
		lb $s1, 0($s0)		#Get the number inside the memory addres
		beq $s1, $t0, retZero	#If the number inside address equals potential number, go to retZero
		next:
			addi $t3, $t3, 1	#Increment counter
			addi $s0, $s0, 1	#Increment memory address
			j rowLoop
	
	
	retZero:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		addi $sp, $sp, 8
		addi $v0, $zero, 0
		jr $ra
	
	retOne:		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		addi $sp, $sp, 8
		addi $v0, $zero, 1
		jr $ra

# _checkColumn
#
# Read in the row and column of puzzle
# Determines if the number is right
#
# Argument:
#   - $a0: Potential number added
#   - $a1: row number
#   - $a2: column number
# Return Value
#   - $v0: Returns if function is 1 for 'true', number can be added or 0 for 'false', number can't be added
_checkColumn:

	addi $sp, $sp, -8	#Adjust stack
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	
	la $s0, 0xffff8000
	add $t0, $zero, $a0	#$t0 is number of interest
	add $t1, $zero, $a1	#$t1 is row number
	add $t2, $zero, $a2	#$t2 is column number
	add $t3, $zero, $zero	#Counter

	add $s0, $s0, $t2	#Adjust the memory address of $s0 based on the column number
	
	colLoop:
		slti $t4, $t3, 9, 	#If $t3 is not less than 9, go to retOne. If not, continue down
		beq $t4, 0, retOneC
		beq $t3, $t1, nextC	#If counter equals row number, go to next
		lb $s1, 0($s0)		#Get the number inside the memory addres
		beq $s1, $t0, retZeroC	#If the number inside address equals potential number, go to retZero
		nextC:
			addi $t3, $t3, 1	#Increment counter
			addi $s0, $s0, 9	#Increment memory address by 9
			j colLoop
	
	
	retZeroC:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		addi $sp, $sp, 8
		addi $v0, $zero, 0
		jr $ra
	
	retOneC:		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		addi $sp, $sp, 8
		addi $v0, $zero, 1
		jr $ra

# _checkSubGrid
#
# Read in the row and column of puzzle
# Determines if the number is right
#
# Argument:
#   - $a0: Potential number added
#   - $a1: row number
#   - $a2: column number
# Return Value
#   - $v0: Returns if function is 1 for 'true', number can be added or 0 for 'false', number can't be added
_checkSubGrid:
	addi $sp, $sp, -12	#Adjust stack
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)	
	
	la $s0, 0xffff8000
	add $t0, $zero, $a0	#$t0 is number of interest
	add $t1, $zero, $a1	#$t1 is row number
	add $t2, $zero, $a2	#$t2 is column number
	add $t3, $zero, $zero	#Counter for row loop
	add $t4, $zero, $zero	#Counter for column loop
	
	add $t5, $zero, $t1	#$t5 is the row number
	add $t6, $zero, $t2	#$t6 is the column number
	
	adjRowLoop:
		div $s2, $t5, 3		#Divide row number by 3
		mfhi $s2		#Hi stores remainder, to $s2
		beq $s2, 0, adjColLoop	#If remainder is zero, go to adjColLoop
		addi $t5, $t5, -1	#Decrease row number by 1
		j adjRowLoop
	adjColLoop:
		div $s2, $t6, 3		#Divide column number by 3
		mfhi $s2		#Have $s2 store remainder
		beq $s2, 0, sCont	#If remainder is zero, go to sCont
		addi $t6, $t6, -1
		j adjColLoop	
	
	sCont:
	mul $s2, $t5, 9		#Multiply row number by 9
	add $s0, $s0, $s2	#Add $s2 to $s0
	add $s0, $s0, $t6	#Add $t6 to $s0, goes to correct memory
	
	suboutLoop:
		slti $s2, $t3, 3, 	#If $s2 is not less than 3, go to retOne. If not, continue down
		beq $s2, 0, retOneS
		
		subInnLoop:
			slti $s2, $t4, 3	#If $s2 is not less than 3, $s2 equals 0
			beq $s2, 0, nextRow	#Go to nextRow
			beq $t5, $t1, checkC	#If current row equals row number placed to argument, go to checkC
			j contSub
			checkC:
				beq $t6, $t2, nextCol	#If current column equals column number, go to nextCol
			contSub:
			lb $s1, 0($s0)		#Get the number inside the memory addres
			beq $s1, $t0, retZeroS	#If the number inside address equals potential number, go to retZero
		
			nextCol:
				addi $t6, $t6, 1	#Current column increments
				addi $t4, $t4, 1	#Increment counter
				addi $s0, $s0, 1	#Increment memory address by 1
				j subInnLoop
		
		nextRow:
			addi $s0, $s0, 6	#Increment memory address by 7
			add $t4, $zero, $zero	#Set column counter back to 0
			addi $t6, $t6, -3
			addi $t3, $t3, 1	#Increment row counter by 1
			addi $t5, $t5, 1	#Current row increments
			j suboutLoop	
	
	
	retZeroS:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		addi $sp, $sp, 12
		addi $v0, $zero, 0
		jr $ra
	
	retOneS:		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		addi $sp, $sp, 12
		addi $v0, $zero, 1
		jr $ra
