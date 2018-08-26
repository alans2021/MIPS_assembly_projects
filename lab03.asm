.data
	Enternum: 	.asciiz	"Please enter a positive integer "
	Negative: 	.asciiz	"Negative integer is not allowed \n"
	Enteragain: 	.asciiz	"Please enter another positive integer "
	Multiply: 	.asciiz	" * "
	Equals: 	.asciiz	" = "
	Exponent: 	.asciiz	" ^ "
	NewLine:	.asciiz "\n"
	
.text
	not $t1, $t1
	enterFirst:
		addi $v0, $zero, 4 	#Do syscall 4
		la $a0, Enternum	#Load Enternum into address
		syscall			#Do command
		addi $v0, $zero, 5 	#Read integer
		syscall			#Syscall
		add $s0, $zero, $v0	#Store integer into $s0
	
	slt $s1, $s0, $zero 	#If entered integer is less than zero, set $s1 to 1
	bne $s1, $zero, repeat 	#Branch to repeat segment if $s1 equals 1
	beq $s1, $zero, next	#Branch to 'next' segment if $s1 equals 0 
	
	repeat:
		addi $v0, $zero, 4	#Print String 
		la $a0, Negative	#Load Negative into address
		syscall
		j enterFirst		#Jump to enterFirst segment
	
	next:
		addi $v0, $zero, 4	#Print string command
		la $a0, Enteragain	#Load Enteragain into address
		syscall			#Syscall
		addi $v0, $zero, 5	#Read integer command
		syscall			#Syscall
		add $s2, $zero, $v0	#Store integer into $s2
	
	slt $s3, $s2, $zero	#If entered integer is less than zero, set $s3 to 1
	bne $s3, $zero, repeat2 #Branch to repeat2 segment if $s3 equals 1
	beq $s3, $zero, math	#Branch to math segment if $s3 equals 0
	
	repeat2: 
		addi $v0, $zero, 4	#Print String 
		la $a0, Negative	#Load Negative into address
		syscall
		j next			#Jump to enterFirst segment
	
	math:
		addi $v0, $zero, 1	#Print Integer
		add $a0, $zero, $s0	#Load $s0 to be printed
		syscall
		addi $v0, $zero, 4	#Print String
		la $a0, Multiply	#Load Multiply into address
		syscall
		addi $v0, $zero, 1	#Print Integer
		add $a0, $zero, $s2	#Load $s2 to be printed
		syscall
		addi $v0, $zero, 4	#Print String
		la $a0, Equals		#Load Equals into address
		syscall
		
	add $t1, $zero, 0	#$t1 represents how much to shift
	add $t4, $zero, 0	#$t4 represents final answer	
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
	
	addi $v0, $zero, 1 	#Print Integer
	add $a0, $t4, $zero	#Load product, which will be represented by $t4, to be printed
	syscall
					
	addi $v0, $zero, 4	#Print String
	la $a0, NewLine		#Load NewLine into address
	syscall
	
	addi $v0, $zero, 1	#Print Integer
	add $a0, $zero, $s0	#Load $s0 to be printed
	syscall
	addi $v0, $zero, 4	#Print String
	la $a0, Exponent	#Load Multiply into address
	syscall
	addi $v0, $zero, 1	#Print Integer
	add $a0, $zero, $s2	#Load $s2 to be printed
	syscall
	addi $v0, $zero, 4	#Print String
	la $a0, Equals		#Load Equals into address
	syscall
	
	
	addi $t0, $zero, 0	#Represents iteration of outer loop, start at 0,
	addi $s1, $zero, 0 	#Represents final product
	add $s3, $zero, $s0	#$s3 represents same number as $s0, to be multiplied

	Expo:
		add $s4, $zero, $zero	#s4 represents the intermediate sum, goes to zero 
		addi $t0, $t0, 1	#Increment $t0 by 1
		slt $t1, $t0, $s2	#If $t0 is less than 2nd number entered ($s2), $t1 equals 1 (Represents number of times to do multiplication algorithm)
		beq $t1, 0, showExpo	#Go to showExpo, which shows final answer and exits
	
	add $t2, $zero, 0	#$t2 represents how much to shift
	multiExpo:
		addi $t3, $zero, 1	#Mask integer
		srlv $t5, $s3, $t2	#Shift $s3 by $t2 bits, represent in $t5
		and $t5, $t5, $t3	#And $t5 and $t3, put in $t5
		sll $t5, $t5, 31	#Shift $t5 by 31 bits
		sra $t5, $t5, 31	#Do sra; if $t5 is 1, all ones; if $t5 is 0, all zeroes
		and $t5, $t5, $s0	#And $t5 and intermediate result; represents product of one bit and first number entered
		sllv $t5, $t5, $t2	#Shift to the left same number of shifts to the right
		add $s4, $s4, $t5	#Add to $s1 the number in $t5
		addi $t2, $t2, 1	#Increment shift amount by 1
		slti $t8, $t2, 32	#If $t1 (which represents shift amount) is less than 32, $t8 equals 1
		beq $t8, 1, multiExpo	#Loop back to Multi if #t8 equals 1
	add $s0, $s4, $zero	#Replace $s0 with intermediate sum
	j Expo
	
	showExpo:
		beq $s2, 0, one
		addi $v0, $zero, 1
		add $a0, $s0, $zero
		syscall	
		addi $v0, $zero, 10
		syscall
	one:
		addi $s0, $zero, 1
		addi $v0, $zero, 1
		add $a0, $s0, $zero
		syscall
		addi $v0, $zero, 10
		syscall
	
	
	
	
	
	
	
	
