.text
	loop: beq $t9, $zero, loop
	add $s0, $zero, $a0	#Get first operand from calculator text field, store in $s0
	add $s2, $zero, $a1	#Get second operand from calculator text field, store in $s1
	add $s1, $s0, $s2	#Addition
	sub $s3, $s0, $s2	#Subtraction
	add $v0, $zero, $s3	#Difference stored in $v0
	sll $v0, $v0, 16	#Difference shifted left by 16, so it occupies upper 16 bits
	andi $s1, $s1, 0xffff
	or $v0, $v0, $s1	#'Add' aka or the sum value, placed in lower 16 bits
	add $t3, $zero, $zero	# $t3 indicates if product will be positive or negative 
	slti $t2, $s0, 0	#If first number is negative, go to firstNeg; If not, go to checkSec
	beq $t2, 1, firstNeg
	j checkSec
	
	firstNeg:
		slti $t2, $s2, 0	#If second number is negative, go to change
		beq $t2, 1, change
		j changeFirst		#IF not negative, go to changeFirst
	
	checkSec:
		slti $t2, $s2, 0
		beq $t2, 1, changeSecond	#If second number is negativ, change second number
		j MultOp
	
	changeFirst:
		nor $s0, $s0, $zero
		addi $s0, $s0, 1
		addi $t3, $zero, 1	#Indicates product needs to be negative
		j MultOp
		
	changeSecond:
		nor $s2, $s2, $zero
		addi $s2, $s2, 1
		addi $t3, $zero, 1	#Indicates product needs to be negative	
		j MultOp
		
	change:		#Changes both inputs to positive since two negatives multiplied is positive
		nor $s0, $s0, $zero
		addi $s0, $s0, 1
		nor $s2, $s2, $zero
		addi $s2, $s2, 1
	
	MultOp:
		add $t1, $zero, 0	#$t1 represents how much to shift
		andi $t4, $zero, 0	#$t4 represents final answer	
	Multi:
		addi $t0, $zero, 1	#Mask integer
		srlv $t2, $s2, $t1	#Shift $s2 by $t1 bits
		and $s4, $t0, $t2	#And $t0 and $t2, put in $s4
		sll $s4, $s4, 31	#Shift $s4 by 31 bits
		sra $s4, $s4, 31	#Do sra; if $s4 is 1, all ones; if $s4 is 0, all zeroes
		and $s5, $s4, $s0	#And $s4 and first number entered; represents product of one bit and first number entered
		sllv $s5, $s5, $t1	#Shift to the left same number of shifts to the right
		add $t4, $t4, $s5	#Add to $t4 the number in $s5
		addi $t1, $t1, 1	#Increment shift amount by 1
		slti $s1, $t1, 32	#If $t1 (which represents shift amount) is less than 32, $s1 equals 1
		beq $s1, 1, Multi	#Loop back to Multi if #s1 equals 1
		
	beq $t3, 1, Negative		#If $t3 equals 1, means product needs to be negative
	j showProduct			#IF $t3 equals 0, product is positive
	
	Negative:	#Change product to negative
		nor $t4, $t4, $zero
		addi $t4, $t4, 1	
	
	showProduct:
		sra $t4, $t4, 8		#Shift right arithmetic of product by places to get from Q16.16 to Q16.8
		andi $t4, $t4, 0x0000ffff	#Make sure only the lower 4 bytes will reflect a neg. #
		add $v1, $zero, $t4
		
	Divide:
		add $s4, $s0, $zero		#Put $s0 into $s4 register
		
		sll $s1, $s2, 16		#Shift divisor to the left by 16 places
		add $s3, $zero, $zero		#Represents temporary quotient
		addi $t0, $zero, 16		#Counter, represents how much to shift the quotient of each iteration, either 0 or 1
		DLoop:
			slt $t1, $s4, $s1	#See if dividend is less than divisor
			beq $t1, 0, writeOne	#If it is not (aka greater or equal to), go to writeOne
			addi $t2, $zero, 0	#If not less, set quotient to be zero
			j continue		#Jump to continue, where quotient will be incorporated into final answer and divisors shifted and counts decrmeented
			
			writeOne:
				addi $t2, $zero, 1	#Set $t2 to 1
				sllv $t2, $t2, $t0	#Shift $t2 by the correct number of bits indicated by $t0
				or $s3, $s3, $t2	#Add the quotient per iteration to the temporary quotient in $s3
				sub $s4, $s4, $s1	#Subtract the dividend by the divisor
			
			continue:
				addi $t0, $t0, -1 	#Decrement counter by 1
				srl $s1, $s1, 1		#Shift divisor to the right by one bit
			
			beq $t0, 0 remStep	#Loop back to DLoop if $t0 = -1; If not, go to remStep
			j DLoop
		
		remStep:
			beq $s4, $zero, showQuotient	#If remainder, which is stored in $s4, is zero, go to showQuotient
			sll $s4, $s4, 8		#Shift remainder by 8 bits, put into $s5
			sll $s1, $s1, 8		#Shift divisor to the left by 8 bits
			addi $t0, $zero, 8	#Counter, represents how much to shift the quotient of each iteration, either 0 or 1
			add $s5, $zero, $zero	#Represents temporary remainder
			
			RLoop:
			slt $t1, $s4, $s1	#See if dividend is less than divisor
			beq $t1, 0, writeRem	#If it is not (aka greater or equal to), go to writeRem
			addi $t2, $zero, 0	#If not less, set quotient to be zero
			j Rcontinue		#Jump to continue, where quotient will be incorporated into final answer and divisors shifted and counts decrmeented
			
			writeRem:
				addi $t2, $zero, 1	#Set $t2 to 1
				sllv $t2, $t2, $t0	#Shift $t2 by the correct number of bits indicated by $t0
				or $s5, $s5, $t2	#Add the quotient per iteration to the temporary quotient in $s3
				sub $s4, $s4, $s1	#Subtract the dividend by the divisor
			
			Rcontinue:
				addi $t0, $t0, -1 	#Decrement counter by 1
				srl $s1, $s1, 1		#Shift divisor to the right by one bit
			beq $t0, -1 showQuotient	#Loop back to DLoop if $t0 = -1
			j RLoop
		
		showQuotient:
			sll $s3, $s3, 8		#Shift left quotient by 8 bits to get from Q8.0 to Q8.8
			or $s3, $s3, $s5	#Or the quotient and the remainder
			beq $t3, 1, Neg		#Adjust quotient to negative if $t3 is 1
			j putRegister
			Neg:
				nor $s3, $s3, $zero
				addi $s3, $s3, 1
			putRegister:
				sll $s3, $s3, 16	#Shift left by 16 bits to put into upper 16 bits of $v1 register
				or $v1, $v1, $s3	#Put quotient into $v1
	
	sqRoot:
		add $s1, $zero, $zero	#Represents current result
		add $s2, $zero, $zero	#Represents current remainder
		add $t0, $zero, $zero	#Represents counter
		addi $t1, $zero, 14	#Counter for determining the left-most two bits
		
		sqLoop:
			srlv $t2, $s0, $t1	#Shift input to the right by shift-counter
			andi $t2, $t2, 3	#And result with 3, which is 11 in binary
			sll $s2, $s2, 2		#Shift to the left the currRemainder by two bits
			add $s2, $s2, $t2	#Add the left-most unused group
			sll $t3, $s1, 2		#$t3 represents temp after multiplying current result by 4
			addi $t3, $t3, 1	#Add one to temp
			slt $t4, $s2, $t3	#Compare to see if current remainder($s2) is less than temp + x
			beq $t4, 1, adjust	#Go to adjust if curr Remainder is less than temp + x
			addi $t4, $zero, 1	#If not less than temp + x, set x = $t4 = 1
			j sqContinue
			
			adjust:
				addi $t3, $zero, 0	#temp equals zero
				add $t4, $zero, $zero	#$t4 represents x, which equals 0
			sqContinue:
				sub $s2, $s2, $t3	#subtract curr Remainder by temp
				sll $s1, $s1, 1		#Multiply current result by 2
				add $s1, $s1, $t4	#Add x to current result
				addi $t0, $t0, 1	#Increment counter by 1
				beq $t0, 12, showRoot	#Go to showRoot when counter equals 12
				bnez $t1, decShift	#If shift counter is not zero, go to decShift 	
				addi $s0, $zero 0	#Set input to zero since all bits have been traversed
				j sqLoop		#Jump to sqLoop
			decShift:
				addi $t1, $t1, -2	#Decrement shift counter by 2
				j sqLoop	
		showRoot:
			add $a2, $s1, $zero	#Put current result into $a2
		
	add $t9, $zero, $zero
	j loop
