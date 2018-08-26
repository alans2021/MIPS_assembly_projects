.data
	numString:	.asciiz	"How many strings do you have?: "
	enterString:	.asciiz	"Please enter a string: "
	theString1:	.asciiz	"The string at index "
	theString2:	.asciiz	" is \""
	theString3:	.asciiz "\"\n"
	result1:	.asciiz "The index of the string \""
	result2:	.asciiz "\" is "
	result3:	.asciiz	".\n"
	notFound1:	.asciiz	"Could not find the string \""
	notFound2:	.asciiz "\".\n"
	buffer:	.space	100
.text
	# Ask for the number of strings
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, numString		# Set the string to print to numString
	syscall				# Print "How many..."
	addi $v0, $zero, 5		# Syscall 5: Read integer
	syscall				# Read integer
	add  $s0, $zero, $v0		# $s0 is the number of strings
	# Allocate memory for an array of strings
	addi $v0, $zero, 9		# Syscall 9: Allocate memory
	sll  $a0, $s0, 2		# number of bytes = number of strings * 4
	syscall				# Allocate memeory
	add  $s1, $zero, $v0		# $s1 is the address of the array of strings
	# Loop n times reading strings
	add  $s2, $zero, $zero		# $s2 counter (0)
	add  $s3, $zero, $s1		# $s3 is the temporary address of the array of strings
readStringLoop:
	beq  $s2, $s0, readStringDone	# Check whether $s2 == number of strings
	add  $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, enterString		# Set the string to print to enterString
	syscall				# Print "Please enter..."
	jal  _readString		# Call _readString function
	sw   $v0, 0($s3)		# Store the address of a string into the array of strings
	addi $s3, $s3, 4		# Increase the address of the array of strings by 4 (next element)
	addi $s2, $s2, 1		# Increase the counter by 1
	j    readStringLoop		# Go back to readStringLoop
readStringDone:
	# Print all strings
	add  $s2, $zero, $zero		# $s2 - counter (0)
	add  $s3, $zero, $s1		# $s3 is the temporary address of the array of strings
printStringLoop:
	beq  $s2, $s0, printStringDone	# Check whether $s2 == number of strings
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, theString1		# Set the string to print to theString1
	syscall				# Print "The string..."
	addi $v0, $zero, 1		# Syscall 1: Print integer
	add  $a0, $zero, $s2		# Set the integer to print to counter (index)
	syscall				# Print the current index
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, theString2		# Set the address of the string to print to theString2
	syscall				# Print " is ""
	lw   $a0, 0($s3)		# Set the address by loading the address from the array of string
	syscall				# Print the string
	la   $a0, theString3		# Set the address of the string to print to theString3
	syscall				# Print ""\n"
	addi $s3, $s3, 4		# Increase the address of the array of string by 4 (next element)
	addi $s2, $s2, 1		# Increase the counter by 1
	j    printStringLoop		# Go back to printStringLoop
printStringDone:
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, enterString		# Set the address of the string to print to enterString
	syscall				# Print "Please enter..."
	jal  _readString			# Call the _readString function
	add  $s4, $zero, $v0		# $s4 is the address of a new string
	# Search for the index of a given string
	add  $s2 $zero, $zero		# $s2 - counter (0)
	add  $s3, $zero, $s1		# $s3 is the temporary address of the array of strings
	addi $s5, $zero, -1		# Set the initial result to -1
searchStringLoop:
	beq  $s2, $s0, searchStringDone	# Check whether $s2 == number of strings
	lw   $a0, 0($s3)		# $a0 is a string in the array of strings
	add  $a1, $zero, $s4		# $s1 is a string the a user just entered
	jal  _strCompare		# Call the _strCompare function
	beq  $v0, $zero, found		# Check whether the result is 0 (found)
	addi $s3, $s3, 4		# Increase the address by 4 (next element)
	addi $s2, $s2, 1		# Increase the counter by 1
	j    searchStringLoop		# Go back to searchStringLoop
found:
	add  $s5, $zero, $s2		# Set the result to counter
	# Print result
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, result1		# Set the address of the string to print to result1
	syscall				# Print "The index ..."
	add  $a0, $zero, $s4		# Set the address of the string to print to the string that a user jsut entered
	syscall				# Print the string that a user just entered
	la   $a0, result2		# Set the address of the string to print to result2
	syscall				# Print " is "
	addi $v0, $zero, 1		# Syscall 1: Print integer
	add  $a0, $zero, $s5		# Set the integer to print
	syscall				# Print index
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, result3		# Set the address of the string to print to result3
	syscall				# Print ".\n"
	j    terminate
searchStringDone:
	# Not found
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, notFound1		# Set the address of the string to print to notFound1
	syscall				# Print "Could not..."
	add  $a0, $zero, $s4		# Set the address of the string to print to a new string
	syscall				# Print the new string
	la   $a0, notFound2		# Set the address of the string to print to notFound2
	syscall
terminate:
	addi $v0, $zero, 10		# Syscall 10: Terminate Program
	syscall				# Terminate Program

# _readString
#
# Read a string from keyboard input using syscall # 5 where '\n' at
# the end will be eliminated. The input string will be stored in
# heap where a small region of memory has been allocated. The address
# of that memory is returned.
#
# Argument:
#   - None
# Return Value
#   - $v0: An address (in heap) of an input string
_readString:
	addi $sp, $sp, -20	#Stack backup
	sw $s3, 16($sp)
	sw $ra, 12($sp)
	sw $s0, 8($sp)
	sw $s1, 4($sp)
	sw $s2, 0($sp)
	
	addi $v0, $zero, 8 		 # Syscall 8: Read string
	la $a0, buffer			 # Set the buffer
	addi $a1, $zero, 100		 # Set the maximum to 100 (size of the buffer)
	syscall
	
	la $s0, buffer
	addi $s1, $zero, 10		# Value of line feed character
	rloop:
		lb $s2, ($s0)
		beq $s1, $s2 change	#If value equals that of line character, change to zero
		addi $s0, $s0, 1
			j rloop
	change:
		add $s2, $zero, $zero
		sb $s2, ($s0)
	
	la $a0, buffer
	jal _strLength
	add $s0, $zero, $v0
	addi $s0, $s0, 1
	
	addi $v0, $zero, 9
	add $a0, $zero, $s0
	syscall
	 
	add $s3, $zero, $v0
	la $a1, buffer
	add $a0, $zero, $v0
	jal _strCopy
	add $v0, $zero, $s3
	
	lw $s3, 16($sp)
	lw $ra, 12($sp)		#Restore stuff from stack backup
	lw $s0, 8($sp)
	lw $s1, 4($sp)
	lw $s2, 0($sp)
	addi $sp, $sp, 20
	jr   $ra
	
# _strCompare
#
# Compare two null-terminated strings. If both strings are idendical,
# 0 will be returned. Otherwise, -1 will be returned.
#
# Arguments:
#   - $a0: an address of the first null-terminated string
#   - $a1: an address of the second null-terminated string
# Return Value
#   - $v0: 0 if both string are identical. Otherwise, -1
_strCompare:
	loop: 
		lb $s1, 0($a0)		#Load character in $s1
		lb $s2, 0($a1)		#Load character in $s2
		bne $s1, $s2, notEqual	#If two registers not equal, go to notEqual
		beq $s1, 0, Equal	#If one of the registers equals 0, which is null, that means $t2 would also equal null, so two registers are equal
		addi $a0, $a0, 1	#Increment argument by 1
		addi $a1, $a1, 1	#Increment argument by 1
		j loop
	Equal:
		addi $v0, $zero, 0	#Store 0 to $v0, then go to done
		j done
	notEqual:
		addi $v0, $zero, -1	#Store -1 to $v0, then go to done
		j done
	done:
		jr   $ra

# _strCopy
#
# Copy from a source string to a destination.
#
# Arguments:
#   - $a0: An address of a destination
#   - $a1: An address of a source
# Return Value:
#   None
_strCopy:
	cloop:
		lb $t1, ($a1)	#Load byte (character) from $a1 to $s1
		sb $t1, ($a0) 	#Store byte from $t1 into $a0
		beq $t1, 0, copdone	#If $t1 is null aka 0, then go to copdone
	  	addi $a1, $a1, 1	#Increment address of $a1
	  	addi $a0, $a0, 1	#Increment address of $a0
		j cloop
	copdone:
		jr   $ra

# _strLength
#
# Measure the length of a null-terminated input string (number of characters).
#
# Argument:
#   - $a0: An address of a null-terminated string
# Return Value:
#   - $v0: An integer represents the length of the given string
_strLength:
	addi $t0, $zero, 0	#Represents a count for length of string
	lenloop: 
		lb $t1, 0($a0)		#Load indicated byte of argument
		beq $t1, $zero, lendone	#If byte equals zero, null charater, go to done
		addi $t0, $t0, 1	#Increment count by 1
		addi $a0, $a0, 1	#Increment string address by 1
	 	j lenloop		
	lendone:
		add $v0, $zero, $t0	#Store length into $v0
		jr   $ra
