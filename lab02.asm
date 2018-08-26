.data
	helloMsg:	.asciiz		"Enter a number between 0 and 9: "
	lostMsg:	.asciiz		"You lose. The number was " 
	lowerMsg:	.asciiz 	"Your guess is too low. \n"
	higherMsg:	.asciiz		"Your guess is too high. \n"
	winMsg:		.asciiz		"Congratulations. You won!"
	
.text
	addi $v0, $zero, 42
	add $a0, $zero, $zero
	addi $a1, $zero, 9
	syscall 
	add $t0, $zero, $a0  #Random number stored in $t0
	add $t1, $zero, $zero  #Counter of number of guesses stored in $t1
	j loop

	loop:
		beq $t1, 3, lost
		addi $v0, $zero, 4
		la $a0, helloMsg
		syscall
		addi $v0, $zero, 5
		syscall
		add $t2, $zero, $v0  #User guess stored in $t2
		bne $t2, $t0, notEqual
		beq $t2, $t0, won
		
	notEqual:
		 slt $t3, $t2, $t0
		 beq $t3, 1, less
		 beq $t3, 0, more
	
	less:
		addi $v0, $zero, 4
		la $a0, lowerMsg
		syscall
		addi $t1, $t1, 1
		j loop 
	
	more:
		addi $v0, $zero, 4
		la $a0, higherMsg
		syscall
		addi $t1, $t1, 1
		j loop 
	
	lost:
		addi $v0, $zero, 4
		la $a0, lostMsg
		syscall
		addi $v0, $zero, 1
		add $a0, $zero, $t0
		syscall
		addi $v0, $zero, 10
		syscall
	
	won:
		addi $v0, $zero, 4
		la $a0, winMsg
		syscall
		addi $v0, $zero, 10
		syscall	 
		
