#$s0 represents first input in calculator
#$s2 represents second input in calculator
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