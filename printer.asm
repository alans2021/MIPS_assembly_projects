.data
	enterFile:	.asciiz "Enter a filename: "
	fileName:	.space 100
	firstTwo: 	.space 2
	.align 2
	nextTwelve: 	.space 12
	dibSize:	.space 4
	colors:		.space 8
	space:	.asciiz " "
	nLine:	.asciiz	"\n" 
	bm:	.asciiz "\nThe first two characters: "
	size: 	.asciiz	"The size of the BMP file (bytes): "
	start: 	.asciiz	"The starting address of image data: "
	width:	.asciiz "Image width (pixels): "
	height:	.asciiz "Image height (pixels): "
	planes:	.asciiz "The number of colors planes: "
	bits:	.asciiz "The number of bits per pixel: "
	comp:	.asciiz "The compression method: "
	biData:	.asciiz "The size of raw bitmap data (bytes): "
	hres:	.asciiz "The horizontal resolution (pixels/meter) "
	vres:	.asciiz "The vertical resolution (pixels/meter) "
	numCol:	.asciiz "The number of colors in the color palette "
	impCol:	.asciiz "The number of important colors used "
	ind0:	.asciiz "The color at index 0 (B G R): "
	ind1:	.asciiz "The color at index 1 (B G R): "
	
.text
	jal _fileInput

	add $a0, $zero, $v0	#Return value from function (stored in $v0) gives address for $a0		
	addi $v0, $zero, 13 # Syscall 13: Open file
	add $a1, $zero, $zero # $a1 = 0
	add $a2, $zero, $zero # $a2 = 0
	syscall # Open file
	add $s0, $zero, $v0 # Copy the file descriptor to $s0
	
	add $a0, $zero, $s0 # $a0 is the file descriptor
	la $a1, firstTwo # $a1 is the address of a buffer (firstTwo)
	addi $a2, $zero, 2 # $a2 is the number of bytes to read
	
	jal _printBM	#Prints BM in the output
	
	add $a0, $zero, $s0 # $a0 is the file descriptor
	la $a1, nextTwelve # $a1 is the address of a buffer (nextTwelve)
	addi $a2, $zero, 12 # $a2 is the number of bytes to read
	
	jal _sizeAndAddress
	
	add $a0, $zero, $s0 # $a0 is the file descriptor
	la $a1, dibSize # $a1 is the address of a buffer dibSize
	addi $a2, $zero, 4 # $a2 is the number of bytes to read
	
	jal _allocMem
	add $s1, $zero, $v0	#$s1 stores address of allocated memory
	
	addi $v0, $zero, 14	#Syscall 14: Read File
	add $a0, $zero, $s0	#$a0 is file descriptor
	la $a1, ($s1)		#a1 is the address of heap, which is received from $s1
	add $a2, $zero, $t0	#a2 is number of bytes to read
	syscall
	
	la $a0, ($s1)		#$a0 has address of all DIB Header info
	jal _printInfo
	add $s2, $zero, $v0	#$s2 stores size of BMP data
	add $s5, $zero, $v1	#$s5 stores bytes per row
	div $s6, $s2, $s5	#$s6 is the image height of BMP data
	srl $s6, $s6, 3		#Divide $s6 by 8 which gives bytes per column
	
	add $a0, $zero, $s0	#$a0 has the file descriptor	
	la $a1, colors		#$a1 is address of buffer
	addi $a2, $zero, 8	#$a2 is 8, max number of bytes to read
	jal _printColors	#Call _printColors function
	add $s4, $zero, $v0	#$s4 stores $v0, which indicates if BMP data should be reversed
	
	addi $v0, $zero, 9	#Syscall 9, allocate memory in heap
	add $a0, $zero, $s2	#Number of bytes to store in heap	
	syscall
	add $s3, $zero, $v0	#Stores address of heap to $s3
	
	addi $v0, $zero, 14	#Syscall 14, read file
	add $a0, $zero, $s0	#$a0 has the file descriptor
	la $a1, ($s3)		#$a1 has the address of heap
	add $a2, $zero, $s2	#$a2 is the number of bytes to read in, which is size of BMP file
	syscall
	
	la $a0, ($s3)
	add $t5, $a0, $zero	#'Store' the $a0 address in #t5
	addi $s1, $zero, 0	#Counter for just within printerLoop

	printerLoop:
		slti $t7, $s2, 1, 	#If BMP data size <= zero, go to allDone
		beq $t7, 1, allDone
		beq $s1, $s5, printWhite	#When all bytes per row have been printed, printWhite
		add $a0, $a0, $s2	#Adjust address of $a0 to start from the end
		sub $a0, $a0, $s5	#Subtract address of $a0 by the number of bytes per row
		add $a0, $a0, $s1	#Add $s1 to address of $a0
		add $a1, $zero, $s4	#$a1 stores if data should be reversed
		add $a2, $zero, $s5	#Place $s5 into $a2, which is bytes per row
		jal _columnEight	#Call columnEight function
		
		addi $s1, $s1, 1	#Increment counter
		add $a0, $zero, $t5	#Reset $a0 address to the beginning of where BMP data starts
		j printerLoop
	
	printWhite:	#Prints out white space to end of row, then goes to next column
		add $s3, $zero, $s5	#$s3 is a counter, starts off to be number of bytes per row
		sll $s3, $s3, 3		#sll by 3, which is multiply by 8
		
		printblank:
			beq $s3, 480, nextRow
			add $t9, $zero, $zero # Clear $t9 to 0
			add $t8, $zero, $zero # Set $t8 to 8-bit data to be printed, which is zero
			addi $t9, $zero, 1 # Set $t9 to 1 to print
			wait:   bne $t9, $zero, wait # Wait until $t9 is back to 0
			addi $s3, $s3, 1	#Increment counter by 1
			j printblank
	
	nextRow:
		add $t6, $zero, $s5	#$t6 equals bytes per row
		sll $t6, $t6, 3		#Multiply $t6 by 8
		sub $s2, $s2, $t6	#Subtract size ($s2) by $t6
		add $s1, $zero, $zero	#Set printerloop counter back to zero
		j printerLoop
	allDone:
		addi $v0, $zero, 16 # Syscall 16: Close file
		add $a0, $zero, $s0 # $a0 is the file descriptor
		syscall # Close file
	
		addi $v0, $zero, 10
		syscall
	
# _fileInput
#
# Read a string from keyboard input using syscall # 5 where '\n' at
# the end will be eliminated. The input string will be stored in
# heap where a small region of memory has been allocated. The address
# of that memory is returned.
#
# Argument:
#   - None
# Return Value
#   - $v0: An address of an input string
_fileInput:
	addi $sp, $sp, -4	#Backup Stack
	sw $s0, 0($sp)
	
	addi $v0, $zero, 4	#Enter a filename command text
	la $a0, enterFile
	syscall
	
	la $a0, fileName	#Read in string input
	addi $a1, $zero, 100
	addi $v0, $zero, 8
	syscall
	
	addi $s0, $a0, 0
	addi $t1, $zero, 0	#Counter for string length
	adjustLoop: 	#Get rid of new line character in string input
		lb $t0, 0($s0)
		beq $t0, 10, adjust	#If $t1 equals 10, (\n in ASCII), change it to null character
		addi $s0, $s0, 1
		addi $t1, $t1, 1	#Increment string length counter by 1
		j adjustLoop
	adjust:
		add $t0, $zero, $zero	#Change $t0 to null character
		sb $t0, 0($s0)		#Put back into $a0
		sub $s0, $s0, $t1	#Subtract address of $a0 by $t1 to get back to original
	
	add $v0, $zero, $s0
	
	lb $s0, 0($sp)
	addi $sp, $sp, 4	#Re-adjust stack
	jr $ra	

# _printBM
# 
# Reads the file after it has been opened
# Print the first two characters of the bitmap file
#
# Argument:
#   - $a0: file descriptor
#   - $a1: address of a buffer
#   - $a2: number of bytes to read	
# Return Value
#   None
_printBM:
	addi $sp, $sp, -4	#Adjust stack
	sw $s1, 0($sp)
	
	addi $v0, $zero, 14 # Syscall 14: Read file
	syscall # Read file
	
	addi $v0, $zero, 4	#Print String, (The first two characters is the output)
	la $a0, bm
	syscall
	
	la $s1, firstTwo # Set $s1 to the address of firstTwo
	addi $v0, $zero, 11 # Syscall 11: Print character
	lb $a0, 0($s1) # $a0 is the first byte of firstTwo
	syscall # Print a character
	
	lb $a0, 1($s1) # $a0 is the second byte of firstTwo
	syscall # Print a character
	
	addi $v0, $zero, 4	#Prints newLine character
	la $a0, nLine
	syscall
	
	lw $s1, 0($sp)	#Restore stack
	addi $sp, $sp, 4
	jr $ra

# _sizeAndAddress
# 
# Reads the file 
# Print the size of the BMP file
# Print the starting address of image data
#
# Argument:
#   - $a0: file descriptor
#   - $a1: address of a buffer
#   - $a2: number of bytes to read	
# Return Value
#   None
_sizeAndAddress:
	addi $sp, $sp, -4	#Adjust stack
	sw $s1, 0($sp)
	
	addi $v0, $zero, 14 # Syscall 14: Read file
	syscall # Read file
	
	addi $v0, $zero, 4	#Prints out the output "size of BMP file"
	la $a0, size
	syscall
	
	la $s1, nextTwelve # Set $s1 to the address of nextSixteen
	addi $v0, $zero, 1 # Syscall 1: Print integer
	lw $a0, 0($s1) # $a0 is the first 4-byte integer 
	syscall # Print an integer, which is size of file
	
	addi $v0, $zero, 4	#Print newLine character
	la $a0, nLine
	syscall
	
	addi $v0, $zero, 4	#Prints out "starting address of image data" as output
	la $a0, start
	syscall
	
	addi $v0, $zero, 1
	lw $a0, 8($s1) # $a0 is the second 4-byte integer
	syscall # Print an integer, the address of image data
	
	addi $v0, $zero, 4	#Print newLine character
	la $a0, nLine
	syscall
	
	lw $s1, 0($sp)	#Restore stack
	addi $sp, $sp, 4
	jr $ra

# _allocMem
# 
# Reads the file 
# Reads size of DIB Header
# Allocates right amount of memory in heap based on size of DIB Header
# Returns address of the heap in $v0
#
# Argument:
#   - $a0: file descriptor
#   - $a1: address of a buffer
#   - $a2: number of bytes to read	
# Return Value
#   - $v0: return address of heap
_allocMem:	
	addi $sp, $sp, -4	#Adjust stack
	sw $s1, 0($sp)

	addi $v0, $zero, 14 # Syscall 14: Read file
	syscall # Read file
	
	la $s1, dibSize		#Information stored in dibSize put in $s1
	lw $t0, 0($s1)		#$t0 is size of DIB Header
	addi $t0, $t0, -4	#Subtract DIB Header size by 4 to have right buffer size
	add $a0, $t0, $zero	#Store that $t0 value in $a0, which will be number of bytes to allocate
	addi $v0, $zero, 9	#Syscall 9, allocate memory in heap
	syscall			#Allocate memory
	
	lw $s1, 0($sp)
	addi $sp, $sp, 4	#Restore stack
	jr $ra

# _printInfo
# 
# Reads the DIB Header of file
# Prints out information found in DIB Header
# Returns size of BMP data
#
# Argument:
#   - $a0: Heap address
# Return Value
#   - $v0: Return size of BMP
_printInfo:
	addi $sp, $sp, -20	#Adjust stack
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	
	lw $s0, 0($a0)		#Image width
	lw $s1, 4($a0)		#Image height
	lh $s2, 8($a0)		#Color Plane
	lh $s3, 10($a0)		#Bit per pixel
	lw $s4, 12($a0)		#Compression Method
	
	lw $t0, 16($a0)		#Size of bitmap data
	lw $t1, 20($a0)		#Horiz Res	
	lw $t2, 24($a0)		#Vert Res
	lw $t3, 28($a0)		#Number of colors
	lw $t4, 32($a0)		#Colors used
	
	la $a0, width		#Print out width info
	addi $v0, $zero, 4
	syscall
	addi $a0, $s0, 0
	addi $v0, $zero, 1
	syscall
	la $a0, nLine
	addi $v0, $zero, 4
	syscall
	
	la $a0, height		#Print out height info
	addi $v0, $zero, 4
	syscall
	addi $a0, $s1, 0
	addi $v0, $zero, 1
	syscall
	la $a0, nLine
	addi $v0, $zero, 4
	syscall
		
	la $a0, planes		#Print out planes info
	addi $v0, $zero, 4
	syscall
	addi $a0, $s2, 0
	addi $v0, $zero, 1
	syscall
	la $a0, nLine
	addi $v0, $zero, 4
	syscall
	
	la $a0, bits		#Print out bits/pixel info
	addi $v0, $zero, 4
	syscall
	addi $a0, $s3, 0
	addi $v0, $zero, 1
	syscall
	la $a0, nLine
	addi $v0, $zero, 4
	syscall
	
	la $a0, comp		#Print compression method info
	addi $v0, $zero, 4
	syscall
	addi $a0, $s4, 0
	addi $v0, $zero, 1
	syscall
	la $a0, nLine
	addi $v0, $zero, 4
	syscall
	
	la $a0, biData		#Print size of raw bitmap data
	addi $v0, $zero, 4
	syscall
	addi $a0, $t0, 0
	addi $v0, $zero, 1
	syscall
	la $a0, nLine
	addi $v0, $zero, 4
	syscall
	
	la $a0, hres		#Print horizontal resolution
	addi $v0, $zero, 4
	syscall
	addi $a0, $t1, 0
	addi $v0, $zero, 1
	syscall
	la $a0, nLine
	addi $v0, $zero, 4
	syscall
	
	la $a0, vres		#Print vertical resolution
	addi $v0, $zero, 4
	syscall
	addi $a0, $t2, 0
	addi $v0, $zero, 1
	syscall
	la $a0, nLine
	addi $v0, $zero, 4
	syscall
	
	la $a0, numCol		#Print number of colors in color palette
	addi $v0, $zero, 4
	syscall
	addi $a0, $t3, 0
	addi $v0, $zero, 1
	syscall
	la $a0, nLine
	addi $v0, $zero, 4
	syscall
	
	la $a0, impCol		#Print number of important colors in color palette
	addi $v0, $zero, 4
	syscall
	addi $a0, $t4, 0
	addi $v0, $zero, 1
	syscall
	la $a0, nLine
	addi $v0, $zero, 4
	syscall
	
	add $v0, $zero, $t0	#$v0 is size of bitmap data
	div $v1, $v0, $s1	#$v1 is number of bytes for each row of pixel
	
	lw $s0, 0($sp)		#Restore stack
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	addi $sp, $sp, 20
	jr $ra
	
# _printColors
# 
# Reads the color information in BMP file
# Prints out colors at each index
#
# Argument:
#   - $a0: File descriptor
#   - $a1: address of buffer
#   - $a2: Number of bytes to read
#	 
# Return Value
#   -$v0: Returns 1 if index 0 indicates black. 0 if otherwise
_printColors:
	addi $sp, $sp, -16	#Adjust stack
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	
	addi $v0, $zero, 14	#Syscall 14: Read file
	syscall
	
	la $s0, colors		#Load address of buffer to $s0
	lbu $s1, 0($s0)		# $s1 - $s3 will store color at index 0
	lbu $s2, 1($s0)
	lbu $s3, 2($s0)
	lbu $t1, 4($s0)		# $t1 - $t3 will store color at index 1
	lbu $t2, 5($s0)
	lbu $t3, 6($s0)
	
	la $a0, ind0		#Prints output statement of "color at index 0"
	addi $v0, $zero, 4
	syscall
	add $a0, $zero, $s1	#Prints first byte of color at index 0
	addi $v0, $zero, 1
	syscall
	la $a0, space		#Prints space
	addi $v0, $zero, 4
	syscall
	add $a0, $zero, $s2	#Prints second byte of color at index 0
	addi $v0, $zero, 1
	syscall
	la $a0, space		#Prints space
	addi $v0, $zero, 4
	syscall
	add $a0, $zero, $s3	#Prints third byte of color at index 0
	addi $v0, $zero, 1
	syscall
	la $a0, nLine		#Prints newLine
	addi $v0, $zero, 4
	syscall 
		
	la $a0, ind1		#Prints output statement of "color at index 1"
	addi $v0, $zero, 4
	syscall
	add $a0, $zero, $t1	#Prints first byte of color at index 1
	addi $v0, $zero, 1
	syscall
	la $a0, space		#Prints space
	addi $v0, $zero, 4
	syscall
	add $a0, $zero, $t2	#Prints second byte of color at index 1
	addi $v0, $zero, 1
	syscall
	la $a0, space		#Prints space
	addi $v0, $zero, 4
	syscall
	add $a0, $zero, $t3	#Prints third byte of color at index 1
	addi $v0, $zero, 1
	syscall
	la $a0, nLine		#Prints newLine
	addi $v0, $zero, 4
	syscall 
	
	beq $s1, $zero, one	#If $s0 equals 0, $v0 is 1
	addi $v0, $zero, 0
	j funcdone
	one:
		addi $v0, $zero, 1
	
	funcdone:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		addi $sp, $sp, 16	#Restore stack
		jr $ra		

# _printColors
# 
# Make the eight bits that will be printed as a column
# Print out on printer
#
# Argument:
#   - $a0: address of bitmap file 
#   - $a1: 1 if bits should be flipped. 0 if they don't
#   - $a2: Stores bytes per row of data
#	 
# Return Value
#   
_columnEight:
	addi $sp, $sp, -4	#Adjust stack
	sw $s0, 0($sp)
	
	addi $t0, $zero, 0	#Counter
	add $t1, $zero, $zero	#Stores column of eight bit data
	add $t2, $zero, 0x80	#$t2 is 10000000 in binary
	add $t3, $zero, $a0	#Store $a0 value into $t3
	add $t4, $zero, $zero	#Counter for how much to shift to the left
	outerLoop:
		beq $t2, $zero, colFuncDone	#If $t2 equals 0, go to done
		loop:
			beq $t0, 8, print	#Go to contouter when $t0 is zero
			lbu $s0, 0($t3)		#Load byte into $s0
			beq $a1, 1, flip
			j continue
			flip:
				nor $s0, $s0, $zero	#Flip the bits
			continue:
				and $s0, $s0, $t2	#And $s0 with $t2
				sllv $s0, $s0, $t4	#Shift to the left by $t4
				srlv $s0, $s0, $t0	#Shift $s0 to the right by the value of $t0
				or $t1, $t1, $s0	#Or $t0 and $s0
				addi $t0, $t0, 1	#Increment
				sub $t3, $t3, $a2	#Adjust address of $t3
				j loop	
		print:
			add $t9, $zero, $zero # Clear $t9 to 0
			add $t8, $zero, $t1 # Set $t8 to 8-bit data to be printed
			addi $t9, $zero, 1 # Set $t9 to 1 to print
			wait1:   bne $t9, $zero, wait1 # Wait until $t9 is back to 0		
		contouter:
			srl $t2, $t2, 1		#Shift $t2 to the right by 1
			add $t0, $zero, $zero	#Set counter back to zero
			add $t1, $zero, $zero	#Set $t1 back to zero
			add $t3, $zero, $a0	#Set $t3 value to be original address
			addi $t4, $t4, 1
			j outerLoop
	colFuncDone:
		lw $s0, 0($sp)		#Restore stack
		addi $sp, $sp, 4
		jr $ra		
		
		
