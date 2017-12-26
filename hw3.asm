##############################################################
# Homework #3
# name: Shen-Chieh Yen
# sbuid: 110636500
##############################################################
.text

##############################
# PART 1 FUNCTIONS
##############################

smiley:
        #Define your code here
        li $t0, 0
        li $t1, 100
        li $t2, 15
        li $t3, 'b'
        li $t4, 0

        li $t0, 0xFFFF0000

forBlack:                               # Makes the whole array color black
        beqz $t1, endBlack              # Breaks the loop if it colors all 100 boxes
        sb $t2, 1($t0)
        sb $0, 0($t0)
        addi $t0, $t0, 2                # Moves to the next color memory address
        addi $t1, $t1, -1

        j forBlack

endBlack:
                                        # Making the eyes for the smiley face
        li $t0, 0xffff002E
        sb $t3, 0($t0)
        li $t4, 0xB7
        sb $t4, 1($t0)

        li $t0, 0xffff0034
        sb $t3, 0($t0)
        li $t4, 0xB7
        sb $t4, 1($t0)

        li $t0, 0xffff0042
        sb $t3, 0($t0)
        li $t4, 0xB7
        sb $t4, 1($t0)

        li $t0, 0xffff0048
        sb $t3, 0($t0)
        li $t4, 0xB7
        sb $t4, 1($t0)

        li $t3, 'e'                     # Making the smile

        li $t0, 0xffff007c
        sb $t3, 0($t0)
        li $t4, 0x1F
        sb $t4, 1($t0)

        li $t0, 0xffff0086
        sb $t3, 0($t0)
        li $t4, 0x1F
        sb $t4, 1($t0)

        li $t0, 0xffff00A8
        sb $t3, 0($t0)
        li $t4, 0x1F
        sb $t4, 1($t0)

        li $t0, 0xffff00AA
        sb $t3, 0($t0)
        li $t4, 0x1F
        sb $t4, 1($t0)

        li $t0, 0xffff0098
        sb $t3, 0($t0)
        li $t4, 0x1F
        sb $t4, 1($t0)

        li $t0, 0xffff0092
        sb $t3, 0($t0)
        li $t4, 0x1F
        sb $t4, 1($t0)

        jr $ra

##############################
# PART 2 FUNCTIONS
##############################

open_file:
    #Define your code here
    
	li $v0, 13
    	la $a1, 0
    	la $a2, 0
    	syscall
    	
    	addi $sp, $sp, -4
    	sw $v0, 0($sp)
    	addi $sp, $sp, 4
    
    	jr $ra

close_file:
    #Define your code here
    	
    	li $v0, 16
    	addi $sp, $sp, -4
    	lw $a0, 0($sp)
    	addi $sp, $sp, 4
    	syscall
    	
    	jr $ra

load_map:
    	#Define your code here
    	
    	move $t0, $a1			# $a1 contains the address CellArray
    	li $v0, 14
    	la $a1, buffer
    	li $a2, 1300000
    	syscall 
	addi $t9,$v0,0
    	
    	# Clearing the Cell Array to be zero
    	move $a1, $t0
    	li $t1, 100
clearCellArray:
	beqz $t1, endClearCellArray	# Will end the loop if counter hits zero
    	sb $0, 0($t0)
    	addi $t0, $t0, 1		
	addi $t1, $t1, -1
	j clearCellArray
endClearCellArray:

	# Need to check all the coordinate set is valid plus making the array
    	la $t0, buffer
    	li $t1, 0			# Stores the current byte being processed
    	li $t2, 0			# Counter for keeping track of how many numbers
    	la $t3, arrayCoordinates	# Array that stores all the numbers
    	li $t4, 0			# Used for checking if the next number
    	li $t5, 0
    	
forArrayMap:				# Loop for creating the coordinates Array and also check for invalid characters
	lb $t1, ($t0)
	
	blez $t9, endArrayMap	# Cases to look up for -- INVALID CHARACTERS
	beq $t1, ' ', validChar
	beq $t1, '\n', validChar
	beq $t1, '\r', validChar
	beq $t1, '\t', validChar	# Passing these test are none valid but may contain number
	blt $t1, '0', errorMap		# Anything less than isnt a number
	bgt $t1, '9', errorMap		# Anything greater than isnt a number

	beq $t1, '0', equalZero		# Check for equal zero case

	sb $t1, 0($t3)			# $t1 contains the number found		
			
	addi $t3, $t3, 1		# Memory address of current location array + 1
	
	addi $t0, $t0, 1
	lb $t5, 0($t0)
	bge $t5, '0', checkOne
	j clearCheck
checkOne:
	ble $t5, '9', errorMap

clearCheck:
	addi $t2, $t2, 1		# Adds to the counter of numbers found
	addi $t9, $t9,-1		# Counter for character being read
	j forArrayMap
validChar:
	addi $t0, $t0, 1		# Memory address of current location + 1
	addi $t9,$t9,-1			# Counter for character being read
	j forArrayMap
	
equalZero:
	addi $t0, $t0, 1
	addi $t9, $t9, -1
	lb $t5, 0($t0)
	beq $t9, 0x0, storeZero
	beq $t5, ' ', storeZero
	beq $t5, '\n', storeZero
	beq $t5, '\r', storeZero
	beq $t5, '\t', storeZero
	beq $t5, '0', equalZero
	
	bgt $t5, '0', biggerThanZero
	j errorMap
biggerThanZero:
	bgt $t5, '9', errorMap
	j forArrayMap
storeZero:
	sb $t1, 0($t3)
	addi $t3, $t3, 1
	addi $t9, $t9, -1
	
	addi $t2, $t2, 1
	addi $t0, $t0, 1
	j forArrayMap

endArrayMap:

	sb $0, 0($t3)			# Stores a null terminator at the end of the array
	move $t8, $t2			# Needs to preserve the amount of numbers in the file
	
	# Checks if number is odd and if its empty, two numbers convserative
	bgt $t2, 198, errorMap
	li $t1, 2
	blt $t2, 2, errorMap		# Less than 2 numbers which can't make 1 bomb
	div $t2, $t1			# Divide by 2 and see if the reminder is more than 0
	mfhi $t2
	bnez $t2, errorMap		# if $t2 doesnt not equal zero, it means its not even

	la $t0, arrayCoordinates

	# Putting the coordinates on to the Minesweeper game
    	la $t0, arrayCoordinates	# Will store the memory address of buffer
    	li $t1, 0			# Store the first integer of the array
    	li $t2, 0			# Store the second integer of the array
    	li $t3, 32			# char b for storing bomb
    	move $t5, $a1
    	li $t6, 10
    	li $t7, 1
    	li $t9, 2
	div $t8, $t9			# Need to divide by 2 because 2 numbers = 1 bomb
	mflo $t8			# Now $t8 have the quotient, now contains the number of bombs placed
	
forMap:
	beqz $t8, validMap		# Ends the loop when all bombs are placed on the minesweeper
	lb $t1, 0($t0)			# Gets the first coordinate from array
	addi $t0, $t0, 1		# Add one to the next position
	lb $t2, 0($t0)			# Gets the second coordinate from array
	
	addi $t1, $t1, -48		# Convert from ascii char to integer
	addi $t2, $t2, -48
	
	# equation: (i * 10) * 2 + (j * 2)
	mul $t1, $t1, $t6		# Multiply by 20 with i
    	mul $t2, $t2, $t7		# Multiply by 2 with j
    	add $t1, $t1, $t2		# Add them together
    	add $t1, $t1, $t5		# Add to the address Cell Array

    	sb $t3, 0($t1)
    	
    	addi $t0, $t0, 1		# Add 1 to pointer of the arrayCoordinates
	addi $t8, $t8, -1		# Subtract one to the counter which is the number of bombs
	j forMap
	
errorMap:				# Label for error
	li $v0, -1		
	j endMap
validMap:
	li $v0, 1
endMap:
	move $a0, $v0
	li $v0, 1
	#syscall	
	
	# Update the CellArray by marking up which spot is near bomb
	move $t0, $a1
	li $t1, 0			# Current byte Im looking at
	li $t2, 0			# Byte to compare with
	
	#Zer0
	lb $t1, 0($t0)
	
	lb $t2, 1($t0)
	blt $t2, 32, noBombs00
	addi $t1, $t1, 1
noBombs00:
	
	lb $t2, 10($t0)
	blt $t2, 32, noBombs01
	addi $t1, $t1, 1
noBombs01:
	
	lb $t2, 11($t0)
	blt $t2, 32, noBombs02
	addi $t1, $t1, 1
noBombs02:
	sb $t1, 0($t0)
	
	# Nine
	lb $t1, 9($t0)
	
	lb $t2, 8($t0)
	blt $t2, 32, noBombs90
	addi $t1, $t1, 1
noBombs90:

	lb $t2, 18($t0)
	blt $t2, 32, noBombs91
	addi $t1, $t1, 1
noBombs91:

	lb $t2, 19($t0)
	blt $t2, 32, noBombs92
	addi $t1, $t1, 1
noBombs92:
	sb $t1, 9($t0)
	
	# Ninety
	lb $t1, 90($t0)
	
	lb $t2, 80($t0)
	blt $t2, 32, noBombs900
	addi $t1, $t1, 1
noBombs900:

	lb $t2, 81($t0)
	blt $t2, 32, noBombs901
	addi $t1, $t1, 1
noBombs901:

	lb $t2, 91($t0)
	blt $t2, 32, noBombs902
	addi $t1, $t1, 1
noBombs902:
	sb $t1, 90($t0)
	
	# Ninety-Ninety
	lb $t1, 99($t0)
	
	lb $t2, 88($t0)
	blt $t2, 32, noBombs990
	addi $t1, $t1, 1
noBombs990:

	lb $t2, 89($t0)
	blt $t2, 32, noBombs991
	addi $t1, $t1, 1
noBombs991:

	lb $t2, 98($t0)
	blt $t2, 32, noBombs992
	addi $t1, $t1, 1
noBombs992:
	sb $t1, 99($t0)
	
###### Top Row ######
	move $t0, $a1
	addi $t0, $t0, 1		# Upper bound starting point 1
	li $t1, 0			# current byte to look at
	li $t2, 0			# Current pointer around starting point
	li $t3, 8			# Search 8 times across
	
forTopRow:
	lb $t1, 0($t0)
	
	addi $t0, $t0, -1
	lb $t2, 0($t0)
	blt $t2, 32, noBombsTopRow1
	addi $t1, $t1, 1
noBombsTopRow1:

	addi $t0, $t0, 10
	lb $t2, 0($t0)
	blt $t2, 32, noBombsTopRow2
	addi $t1, $t1, 1
noBombsTopRow2:

	addi $t0, $t0, 1
	lb $t2, 0($t0)
	blt $t2, 32, noBombsTopRow3
	addi $t1, $t1, 1
noBombsTopRow3:

	addi $t0, $t0, 1
	lb $t2, 0($t0)
	blt $t2, 32, noBombsTopRow4
	addi $t1, $t1, 1
noBombsTopRow4:

	addi $t0, $t0, -10
	lb $t2, 0($t0)
	blt $t2, 32, noBombsTopRow5
	addi $t1, $t1, 1
noBombsTopRow5:
	
	addi $t0, $t0, -1
	sb $t1, 0($t0)
	addi $t0, $t0, 1
	addi $t3, $t3, -1
	beqz $t3, endTopRow
	
	j forTopRow
endTopRow:
	
###### Bottom Row #######
	move $t0, $a1
	addi $t0, $t0, 91		# lower bound starting point 1
	li $t1, 0			# current byte to look at
	li $t2, 0			# Current pointer around starting point
	li $t3, 8			# Search 8 times across
	
forBottomRow:
	lb $t1, 0($t0)
	
	addi $t0, $t0, -1
	lb $t2, 0($t0)
	blt $t2, 32, noBombsBottomRow1
	addi $t1, $t1, 1
noBombsBottomRow1:

	addi $t0, $t0, -10
	lb $t2, 0($t0)
	blt $t2, 32, noBombsBottomRow2
	addi $t1, $t1, 1
noBombsBottomRow2:

	addi $t0, $t0, 1
	lb $t2, 0($t0)
	blt $t2, 32, noBombsBottomRow3
	addi $t1, $t1, 1
noBombsBottomRow3:

	addi $t0, $t0, 1
	lb $t2, 0($t0)
	blt $t2, 32, noBombsBottomRow4
	addi $t1, $t1, 1
noBombsBottomRow4:

	addi $t0, $t0, 10
	lb $t2, 0($t0)
	blt $t2, 32, noBombsBottomRow5
	addi $t1, $t1, 1
noBombsBottomRow5:
	
	addi $t0, $t0, -1
	sb $t1, 0($t0)
	addi $t0, $t0, 1
	addi $t3, $t3, -1
	beqz $t3, endBottomRow
	
	j forBottomRow
endBottomRow:

###### Left ######
	move $t0, $a1
	addi $t0, $t0, 10		# lower bound starting point 1
	li $t1, 0			# current byte to look at
	li $t2, 0			# Current pointer around starting point
	li $t3, 8			# Search 8 times across
	
forLeft:
	lb $t1, 0($t0)
	
	addi $t0, $t0, -10
	lb $t2, 0($t0)
	blt $t2, 32, noBombsLeft1
	addi $t1, $t1, 1
noBombsLeft1:

	addi $t0, $t0, 1
	lb $t2, 0($t0)
	blt $t2, 32, noBombsLeft2
	addi $t1, $t1, 1
noBombsLeft2:

	addi $t0, $t0, 10
	lb $t2, 0($t0)
	blt $t2, 32, noBombsLeft3
	addi $t1, $t1, 1
noBombsLeft3:

	addi $t0, $t0, 10
	lb $t2, 0($t0)
	blt $t2, 32, noBombsLeft4
	addi $t1, $t1, 1
noBombsLeft4:

	addi $t0, $t0, -1
	lb $t2, 0($t0)
	blt $t2, 32, noBombsLeft5
	addi $t1, $t1, 1
noBombsLeft5:
	
	addi $t0, $t0, -10
	sb $t1, 0($t0)
	addi $t0, $t0, 10
	addi $t3, $t3, -1
	beqz $t3, endLeft
	
	j forLeft
endLeft:

###### Right ######
	move $t0, $a1
	addi $t0, $t0, 19		# lower bound starting point 1
	li $t1, 0			# current byte to look at
	li $t2, 0			# Current pointer around starting point
	li $t3, 8			# Search 8 times across
	
forRight:
	lb $t1, 0($t0)
	
	addi $t0, $t0, -10
	lb $t2, 0($t0)
	blt $t2, 32, noBombsRight1
	addi $t1, $t1, 1
noBombsRight1:

	addi $t0, $t0, -1
	lb $t2, 0($t0)
	blt $t2, 32, noBombsRight2
	addi $t1, $t1, 1
noBombsRight2:

	addi $t0, $t0, 10
	lb $t2, 0($t0)
	blt $t2, 32, noBombsRight3
	addi $t1, $t1, 1
noBombsRight3:

	addi $t0, $t0, 10
	lb $t2, 0($t0)
	blt $t2, 32, noBombsRight4
	addi $t1, $t1, 1
noBombsRight4:

	addi $t0, $t0, 1
	lb $t2, 0($t0)
	blt $t2, 32, noBombsRight5
	addi $t1, $t1, 1
noBombsRight5:
	
	addi $t0, $t0, -10
	sb $t1, 0($t0)
	addi $t0, $t0, 10
	addi $t3, $t3, -1
	beqz $t3, endRight
	
	j forRight
endRight:

###### Center ######
	move $t0, $a1
	addi $t0, $t0, 1		# Upper bound starting point 1
	li $t1, 0			# current byte to look at
	li $t2, 0			# Current pointer around starting point
	li $t3, 8			# Search 8 times across
	li $t4, 8			# Search for 8 times downwards
	
mainForCenter:
	addi $t0, $t0, 10
	
forCenter:
	lb $t1, 0($t0)
	
	addi $t0, $t0, -11
	lb $t2, 0($t0)
	blt $t2, 32, noBombsCenter1
	addi $t1, $t1, 1
noBombsCenter1:

	addi $t0, $t0, 1
	lb $t2, 0($t0)
	blt $t2, 32, noBombsCenter2
	addi $t1, $t1, 1
noBombsCenter2:

	addi $t0, $t0, 1
	lb $t2, 0($t0)
	blt $t2, 32, noBombsCenter3
	addi $t1, $t1, 1
noBombsCenter3:

	addi $t0, $t0, 10
	lb $t2, 0($t0)
	blt $t2, 32, noBombsCenter4
	addi $t1, $t1, 1
noBombsCenter4:

	addi $t0, $t0, 10
	lb $t2, 0($t0)
	blt $t2, 32, noBombsCenter5
	addi $t1, $t1, 1
noBombsCenter5:
	
	addi $t0, $t0, -1
	lb $t2, 0($t0)
	blt $t2, 32, noBombsCenter6
	addi $t1, $t1, 1
noBombsCenter6:

	addi $t0, $t0, -1
	lb $t2, 0($t0)
	blt $t2, 32, noBombsCenter7
	addi $t1, $t1, 1
noBombsCenter7:

	addi $t0, $t0, -10
	lb $t2, 0($t0)
	blt $t2, 32, noBombsCenter8
	addi $t1, $t1, 1
noBombsCenter8:

	addi $t0, $t0, 1
	sb $t1, 0($t0)
	addi $t0, $t0, 1
	addi $t3, $t3, -1
	beqz $t3, endCenter
	
	j forCenter
endCenter:
	addi $t4, $t4, -1
	li $t3, 8
	addi $t0, $t0, -8
	beqz $t4, endCheck
	j mainForCenter
	
endCheck:
	
	# Initialize row and col to position (0, 0)
	la $t0, cursor_row
	sw $0, ($t0)
	la $t1, cursor_col
	sw $0, ($t1) 	
	
    	jr $ra

##############################
# PART 3 FUNCTIONS
##############################

init_display:
    	#Define your code here
    	li $t0, 0xFFFF0000
   	li $t1, 100
    	li $t2, 119
    	li $t3, 0
forInit:
        sb $t2, 1($t0)
        sb $0, 0($t0)
        addi $t0, $t0, 2
        addi $t1, $t1, -1
        beqz $t1, endForInit
        j forInit
endForInit:
	li $t0, 0xFFFF0000
	lb $t1, 1($t0)
	andi $t1, $t1, 0x0F
	addi $t1, $t1, 0xB0
	sb $t1, 1($t0)
	
	# Initialize row and col to position (0, 0)
	la $t0, cursor_row
	sw $0, ($t0)
	la $t1, cursor_col
	sw $0, ($t1) 
    
    	jr $ra

set_cell:
    	#Define your code here
   	move $t0, $a0			# The row index
   	move $t1, $a1			# The column index
   	move $t2, $a2			# The character to be displayed
    	move $t3, $a3			# The foreground color
    	
    	lw $t4, 4($sp)			# The background color
    	
    	li $t5, 20
    	li $t6, 2
    	
    	bltz $t0, errorSetCell		# Checking the row is between 0 and 15
    	bgt $t0, 9, errorSetCell
    	bltz $t1, errorSetCell
    	bgt $t1, 9, errorSetCell
    	
    	bltz $t3, errorSetCell
    	bgt $t3, 15, errorSetCell
    	bltz $t4, errorSetCell
    	bgt $t4, 15, errorSetCell
    	
    	mul $t0, $t0, $t5		# (i * 10) * (j * 2)
    	mul $t1, $t1, $t6
    	add $t0, $t0, $t1
    	
    	addi $t0, $t0, 0xFFFF0000	# Location at the start of VT100
    	sb $t2, 0($t0)			# Stores the character
    	sll $t4, $t4, 4
    	add $t3, $t3, $t4
    	sb $t3, 1($t0)			# Stores the background and foreground
    	
    	li $v0, 0
    	
    	j endSetCell
errorSetCell:
	li $v0, -1
	
endSetCell:
    	jr $ra

reveal_map:
    	#Define your code here
    	beq $a0, 1, won
    	beq $a0, 0, ongoing
    	beq $a0, -1, lost
	
lost:
	move $t0, $a1			# Contains the address of Cell Array
	li $t1, 0			# index row
	li $t2, 0			# index column
	li $t3, 0			# Temp variable to be used
	li $t4, 0			# Current byte im looking on Cell Array
	li $t5, 0
	
forLostMap:
	move $a0, $t1			# Have the current row index 
	move $a1, $t2			# Have the current column index
	
	lb $t4, 0($t0)			# Load byte the current spot on the Cell Array
	
	move $a0, $t1
	
	blt $t4, 9, aNumber
	andi $t5, $t4, 0x10
	bnez $t5, aFlag
	andi $t5, $t4, 0x20
	bnez $t5, aBomb
	
aNumber:
	andi $t3 ,$t4, 0x40
	beqz $t3, skipStep
	addi $t4, $t4, -64
skipStep:
	addi $t4, $t4, 48
	li $t3, 13
	bne $t4, 48, zeroNumberNot
	li $t4, 0
	li $t3, 7
zeroNumberNot:
	move $a2, $t4
	move $a3, $t3
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $0, 4($sp)
	sw $t0, 8($sp)
	sw $t1, 12($sp)
	sw $t2, 16($sp)
	
	jal set_cell
	
	lw $ra, 0($sp)
	lw $t0, 8($sp)
	lw $t1, 12($sp)
	lw $t2, 16($sp)
	addi $sp, $sp, 20

	addi $t0, $t0, 1
	addi $t2, $t2, 1
	beq $t2, 10, nextRow
	
	j forLostMap
	
aFlag:
	li $a2, 'f'
	li $a3, 12
	andi $t5, $t4, 0x30
	beq $t5, 0x30, guessRight 
	li $t5, 9
	j goOn
guessRight:
	li $t5, 10
goOn:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $t5, 4($sp)
	sw $t0, 8($sp)
	sw $t1, 12($sp)
	sw $t2, 16($sp)
	
	jal set_cell
	
	lw $ra, 0($sp)
	lw $t0, 8($sp)
	lw $t1, 12($sp)
	lw $t2, 16($sp)
	addi $sp, $sp, 20
	addi $t0, $t0, 1
	addi $t2, $t2, 1
	beq $t2, 10, nextRow
	j forLostMap
aBomb:
	li $a2, 'b'
	li $a3, 7
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $0, 4($sp)
	sw $t0, 8($sp)
	sw $t1, 12($sp)
	sw $t2, 16($sp)
	
	jal set_cell
	
	lw $ra, 0($sp)
	lw $t0, 8($sp)
	lw $t1, 12($sp)
	lw $t2, 16($sp)
	addi $sp, $sp, 20

	addi $t0, $t0, 1
	addi $t2, $t2, 1
	beq $t2, 10, nextRow
	
	j forLostMap
nextRow:
	addi $t1, $t1, 1
	li $t2, 0
	beq $t1, 10, makeExplosion
	j forLostMap
	
makeExplosion:
	la $t0, cursor_row
	lb $t1, 0($t0)
	move $a0, $t1
	la $t0, cursor_col
	lb $t1, 0($t0)
	move $a1, $t1
	li $a2, 'e'
    	li $a3, 7
    	li $t1, 9

	addi $sp, $sp, -8
    	sw $t1, 4($sp)
    	sw $ra, 0($sp)
    	
    	jal set_cell
    	
    	lw $ra, 0($sp)
    	addi $sp, $sp, 8

	j endRevealMap
ongoing:
	j endRevealMap
won:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal smiley 
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
endRevealMap:

    	jr $ra


##############################
# PART 4 FUNCTIONS
##############################

perform_action:
    	#Define your code here
   	move $t0, $a0			# Contains the address for Cell Array
    	move $t1, $a1			# Contains the action by the user
    	li $t2, 0			# Stores the row
    	li $t3, 0			# Stores the column
    	li $t4, 0			# Address of index
    	li $t5, 0			# Current byte to be saved
    	li $t6, 0			# Value of row
    	li $t7, 0			# Value of column
    	li $t8, 20
    	li $t9, 2
      
      	j clearYellow
backClearYellow:

	move $t0, $a0			# Contains the address for Cell Array
    	move $t1, $a1			# Contains the action by the user
    	li $t2, 0			# Stores the row
    	li $t3, 0			# Stores the column
    	li $t4, 0			# Address of index
    	li $t5, 0			# Current byte to be saved
    	li $t6, 0			# Value of row
    	li $t7, 0			# Value of column
    	li $t8, 20
    	li $t9, 2
        
    	beq $t1, 'w', goToW
    	beq $t1, 'W', goToW
    	beq $t1, 'a', goToA
    	beq $t1, 'A', goToA
    	beq $t1, 's', goToS
    	beq $t1, 'S', goToS
    	beq $t1, 'd', goToD
    	beq $t1, 'D', goToD
    	beq $t1, 'R', goToR
    	beq $t1, 'r', goToR
    	beq $t1, 'F', goToF
    	beq $t1, 'f', goToF
    	j invalidMove
goToW:
	la $t3, cursor_row
	lb $t4, 0($t3)
	addi $t4, $t4, -1	
	sb $t4, 0($t3)
	j moveCursorWA
goToA:
	la $t3, cursor_col
	lb $t4, 0($t3)
	addi $t4, $t4, -1
	sb $t4, 0($t3)
	j moveCursorWA

goToS:
	la $t3, cursor_row
	lb $t4, 0($t3)
	addi $t4, $t4, 1
	sb $t4, 0($t3)
	j moveCursorSD
goToD:
	la $t3, cursor_col
	lb $t4, 0($t3)
	addi $t4, $t4, 1
	sb $t4, 0($t3)
	j moveCursorSD
	
clearYellow:
	la $t2, cursor_row
	lb $t6, 0($t2)			# Have the current value of row index
	
	la $t3, cursor_col
	lb $t7, 0($t3)			# Have the current value of column index
	
	li $t2, 10
	mul $t2, $t2, $t6
	add $t2, $t2, $t7
	add $t2, $t2, $t0
	
	mul $t6, $t6, $t8
	mul $t7, $t7, $t9
	add $t6, $t6, $t7
	
	addi $t6, $t6, 0xFFFF0000
	
	lb $t5, 0($t2)
	
	andi $t3, $t5, 0x10
	bgtz $t3, colorFlag
	
	bge $t5, 64, colorBack

	li $t3, 119
	sb $t3, 1($t6)
	
	j backClearYellow
	
colorFlag:
	la $t2, cursor_row
	lb $t6, 0($t2)
	la $t3, cursor_col
	lb $t7, 0($t3)

   	li $t1, 7
   	
        addi $sp, $sp, -16
        sw $t1, 4($sp)
        sw $ra, 0($sp)
        sw $a0, 8($sp)
        sw $a1, 12($sp)
        
        move $a0, $t6	
        move $a1, $t7
        li $a2, 'f'
    	li $a3, 12
        
        jal set_cell
        
        lw $ra, 0($sp)
        lw $a0, 8($sp)
        lw $a1, 12($sp)
        addi $sp, $sp, 16

	j backClearYellow
colorBack:
	addi $t5, $t5, -64
	blt $t5, 9, aNumberC
    	#blt $t5, 32, aFlagC
   	blt $t5, 64, aBombC
   	bgt $t5, 64, invalidMove
   	j backClearYellow
aNumberC:
	addi $t5, $t5, 64	
	sb $t5, 0($t2)
	li $a3, 7
	
	andi $t5, $t5, 0x0000000F
	beqz $t5, skipAdding
	addi $t5, $t5, 48
	li $a3, 13
skipAdding:
	
	la $t2, cursor_row
	lb $t6, 0($t2)			
	la $t3, cursor_col
	lb $t7, 0($t3)
   	
        addi $sp, $sp, -16
        sw $0, 4($sp)
        sw $ra, 0($sp)
        sw $a0, 8($sp)
        sw $a1, 12($sp)
        
        move $a0, $t6
	move $a1, $t7
	move $a2, $t5
        
        jal set_cell
        
        lw $ra, 0($sp)
        lw $a0, 8($sp)
        lw $a1, 12($sp)
        addi $sp, $sp, 16

	j backClearYellow	
aBombC:	
	addi $t5, $t5, 64
	sb $t5, 0($t2)
	
	j backClearYellow

moveCursorWA:
	bge $t4, 0, WACheck
	addi $t4, $t4, 1
	sb $t4, 0($t3)
	li $v0, -1
	j WADone
WACheck:
	blt $t4, 10, WAPast
	addi $t4, $t4, 1
	sb $t4, 0($t3)
	li $v0, -1
	j WADone	
WAPast:
	li $v0, 0
WADone:
	la $t2, cursor_row
	lb $t6, 0($t2)			# Have the current value of row index
	
	la $t3, cursor_col
	lb $t7, 0($t3)			# Have the current value of column index
	
	mul $t6, $t6, $t8
	mul $t7, $t7, $t9
	add $t6, $t6, $t7
	
	addi $t6, $t6, 0xFFFF0000
	
	#li $t3, 0xB0
	lb $t3, 1($t6)
	andi $t3, $t3, 0x0F
	addi $t3, $t3, 0xB0
	sb $t3, 1($t6)
	
	j endPerformAction
	
moveCursorSD:
	bge $t4, 0, SDCheck
	addi $t4, $t4, -1
	sb $t4, 0($t3)
	li $v0, -1
	j SDDone
SDCheck:
	blt $t4, 10, SDPast
	addi $t4, $t4, -1
	sb $t4, 0($t3)
	li $v0, -1
	j SDDone	
SDPast:
	li $v0, 0
SDDone:

	la $t2, cursor_row
	lb $t6, 0($t2)			# Have the current value of row index
	
	la $t3, cursor_col
	lb $t7, 0($t3)			# Have the current value of column index
	
	mul $t6, $t6, $t8
	mul $t7, $t7, $t9
	add $t6, $t6, $t7
	
	addi $t6, $t6, 0xFFFF0000
	
	#li $t3, 0xB0
	lb $t3, 1($t6)
	andi $t3, $t3, 0x0F
	addi $t3, $t3, 0xB0
	sb $t3, 1($t6)
	
	j endPerformAction
goToR:
	la $t2, cursor_row
	lb $t3, 0($t2)
	move $a0, $t3
	li $t1, 10
	mul $t3, $t3, $t1
	add $t1, $t0, $t3
	
	la $t2, cursor_col
	lb $t3, 0($t2)
	move $a1, $t3
	add $t1, $t1, $t3
	
	lb $t4, 0($t1)
	
	blt $t4, 9, aNumberR
    	blt $t4, 32, aFlagR
   	blt $t4, 64, aBombR
   	bgt $t4, 64, invalidMove
   	j endPerformAction
	
aNumberR:
	beqz $t4, callSearchCell 
	andi $t2, $t4, 0x0000000F
	addi $t2, $t2, 48
    	li $t3, 13
    	move $a2, $t2
    	move $a3, $t3
    	addi $t4, $t4, 64
    	sb $t4, 0($t1)
    	
    	addi $sp, $sp, -8
    	sw $0, 4($sp)
    	sw $ra, 0($sp)
    	
    	jal set_cell
    	
    	lw $ra, 0($sp)
    	addi $sp, $sp, 8

	j validMove
callSearchCell:
	move $a0, $t0
	
	la $t1, cursor_row
	lb $t2, 0($t1)
	move $a1, $t2
	
	la $t1, cursor_col
	lb $t2, 0($t1)
	move $a2, $t2
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal search_cells
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	li $t3, 0
	li $t4, 0
	la $t1, cursor_row
	lb $t2, 0($t1)
	
	li $t1, 20
	mul $t1, $t1, $t2		# $t1	
	li $t2, 2
	la $t3, cursor_col
	lb $t4, 0($t3)			# t4
	mul $t4, $t4, $t2
	add $t1, $t1, $t4
	addi $t1, $t1, 0xFFFF0000
	
	lb $t2, 1($t1)
	andi $t2, $t2, 0x0F
	addi $t2, $t2, 0xB0
	sb $t2, 1($t1)
	
	j validMove

aBombR:
	addi $t4, $t4, 64
	sb $t4, 0($t1)
	
	li $a2, 'b'
    	li $a3, 7
	addi $sp, $sp, -8
    	sw $0, 4($sp)
    	sw $ra, 0($sp)
    	
    	jal set_cell
    	
    	lw $ra, 0($sp)
    	addi $sp, $sp, 8

	j validMove
	
aFlagR:
	addi $t4, $t4, -16
	sb $t4, 0($t1)
	j goToR

goToF:
	la $t2, cursor_row
	lb $t3, 0($t2)
	move $a0, $t3
	li $t1, 10
	mul $t3, $t3, $t1
	add $t1, $t0, $t3
	
	la $t2, cursor_col
	lb $t3, 0($t2)
	move $a1, $t3
	add $t1, $t1, $t3
	
	lb $t4, 0($t1)
	andi $t2, $t4, 0x00000010 
	bnez $t2, toggleFlag
	andi $t2, $t4, 0x00000040
	bnez $t2, invalidMove
	addi $t4, $t4, 16
	sb $t4, 0($t1)
	
	li $a2, 'f'
    	li $a3, 12
    	li $t1, 7
    	j flagIt
toggleFlag:
	addi $t4, $t4, -16
	sb $t4, 0($t1)
	li $a2, 0
	li $a3, 0
	li $t1, 7
flagIt:
	addi $sp, $sp, -8
    	sw $t1, 4($sp)
    	sw $ra, 0($sp)
    	
    	jal set_cell
    	
    	lw $ra, 0($sp)
    	addi $sp, $sp, 8
	
	j validMove

invalidMove:
	li $v0, -1
	j endPerformAction

validMove:
	li $v0, 0
endPerformAction:
	move $t9, $v0
	move $a0, $t9
	li $v0, 1
	#syscall
	move $v0, $t9
    	jr $ra

game_status:
   	#Define your code here
    	move $t0, $a0			# Contains the address of the Cell Array
    	li $t1, 0			# Current byte to be looked at
	li $t2, 0			# Counter for going through Cell Array
	li $t3, 0			# Temp variable
	li $t4, 0			# counter for bombs
	li $t5, 0			# counter for bombs flagged
	
forCellArray:
	beq $t2, 100, checkStatus
	lb $t1, 0($t0)
	
	andi $t3, $t1, 0x60
	
	beq $t3, 0x60, youLose
	
	andi $t3, $t1, 0x30
	beq $t3, 0x30, addBombFlag
	j moveOn
addBombFlag:
	addi $t5, $t5, 1
moveOn:
	andi $t3, $t1, 0x20
	beq $t3, 0x20, addBomb
	j moveOn2
addBomb:
	addi $t4, $t4, 1
moveOn2:
	
	addi $t2, $t2, 1
	addi $t0, $t0, 1
	
	j forCellArray
youLose:
	li $v0, -1
	j done
checkStatus:
	beq $t4, $t5, youWin
	li $v0, 0
	j done
youWin:
	li $v0, 1
done:
    	jr $ra

##############################
# PART 5 FUNCTIONS
##############################

search_cells:
   	#Define your code here
   	move $t0, $a0			# Have the Cell Array memory address			
   	move $t1, $a1			# Value of row
   	move $t2, $a2			# Value of col
   	li $t3, 0
   	li $t4, 0
   	li $t5, 0
   	li $t6, 0
   	li $t7, 0
   	li $t8, 0
   	li $t9, 0
   	
    	move $fp, $sp			# fp = sp
    	addi $sp, $sp, -8
   	sw $a1, 0($sp)			# Have ROW VALUE
    	sw $a2, 4($sp)			# Have COLUMN VALUE
while:
	beq $sp, $fp, endWhile		# while (sp != fp) {
	lw $t1, 0($sp)			# sp.pop(row);
	lw $t2, 4($sp)			# sp.pop(col);
	addi $sp, $sp, 8
	
	# cell[row][col]
	move $a0, $t0
	move $a1, $t1
	move $a2, $t2
	
	addi $sp, $sp, -12
	sw $t1, 0($sp)
	sw $t2, 4($sp)
	sw $ra, 8($sp)
	
	jal getCellArray
	
	lw $t1, 0($sp)
	lw $t2, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	
	move $t3, $v0			# Have the byte for cell[row][col]
	move $t9, $v0	
	andi $t4, $t3, 0x10
	bnez $t4, goAhead		# if(!cell[row][col].isFlag()) - if $t4 is not 0, it has flag. Otherwise, reveal
	andi $t4, $t3, 0xF
	
	move $a0, $t1			# cell[row][col].reveal()
	move $a1, $t2
	move $a2, $t4
	beqz $a2, dontAdd
	addi $a2, $a2, 48
dontAdd:
	li $a3, 13
	
	addi $sp, $sp, -20
	sw $t1, 0($sp)
	sw $0, 4($sp)
	sw $ra, 8($sp)
	sw $t2, 12($sp)
	sw $t0, 16($sp)
	
	jal set_cell
	
	lw $t1, 0($sp)
	lw $ra, 8($sp)
	lw $t2, 12($sp)
	lw $t0, 16($sp)
	addi $sp, $sp, 20
	
	move $t3, $t0
	
	li $t4, 10
	mul $t4, $t4, $t1
	add $t4, $t4, $t2
	add $t4, $t4, $t3
	lb $t3, 0($t4)
	
	bge $t3, 64, skipAdd
	addi $t3, $t3, 64
skipAdd:
	sb $t3, 0($t4)
	
goAhead:
	andi $t9, $t9, 0xF
	bnez $t9, while			# if(cell[row][col].getNumber() == 0)
	li $3, 0
	
	# if (row + 1 < 10 && cell[row + 1][col].isHidden() && !cell[row + 1][col].isFlag()) {
	addi $t3, $t1, 1		# row + 1
	blt $t3, 10, check1
	j move1		
check1:
	move $a0, $t0
	move $a1, $t3
	move $a2, $t2
	
	addi $sp, $sp, -12
	sw $t1, 0($sp)
	sw $t2, 4($sp)
	sw $ra, 8($sp)
	
	jal getCellArray		# cell[row + 1][col]
	
	lw $t1, 0($sp)
	lw $t2, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	
	move $t3, $v0
	andi $t4, $t3, 0x40		# cell[row + 1][col].isHidden()
	bnez $t4, move1
	andi $t4, $t3, 0x10		# !cell[row + 1][col].isFlag()
    	bnez $t4, move1
    	
    	addi $t4, $t1, 1		# add back row + 1
    	addi $sp, $sp, -8
    	sw $t4, 0($sp)
    	sw $t2, 4($sp)
move1:
	# if (col + 1 < 10 && cell[row][col + 1].isHidden() && !cell[row][col + 1].isFlag()) {
	addi $t3, $t2, 1		# col + 1		
	blt $t3, 10, check2
	j move2
check2:
	move $a0, $t0
	move $a1, $t1
	move $a2, $t3
	
	addi $sp, $sp, -12
	sw $t1, 0($sp)
	sw $t2, 4($sp)
	sw $ra, 8($sp)
	
	jal getCellArray		# cell[row][col + 1]
	
	lw $t1, 0($sp)
	lw $t2, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	
	move $t3, $v0
	andi $t4, $t3, 0x40		# cell[row ][col + 1].isHidden()
	bnez $t4, move2
	andi $t4, $t3, 0x10		# !cell[row][col + 1].isFlag()
    	bnez $t4, move2
    	
    	addi $t4, $t2, 1		# add back col + 1
    	addi $sp, $sp, -8
    	sw $t1, 0($sp)
    	sw $t4, 4($sp)
move2:
	# if (row - 1 >= 0 && cell[row - 1][col].isHidden() && !cell[row - 1][col].isFlag()) {
	addi $t3, $t1, -1		# row - 1
	bge $t3, 0, check3
	j move3	
check3:
	move $a0, $t0
	move $a1, $t3
	move $a2, $t2
	
	addi $sp, $sp, -12
	sw $t1, 0($sp)
	sw $t2, 4($sp)
	sw $ra, 8($sp)
	
	jal getCellArray		# cell[row - 1][col]
	
	lw $t1, 0($sp)
	lw $t2, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	
	move $t3, $v0
	andi $t4, $t3, 0x40		# cell[row - 1][col].isHidden()
	bnez $t4, move3
	andi $t4, $t3, 0x10		# !cell[row - 1][col].isFlag()
    	bnez $t4, move3
    	
    	addi $t4, $t1, -1		# subtract row - 1
    	addi $sp, $sp, -8
    	sw $t4, 0($sp)
    	sw $t2, 4($sp)
move3:

	# if (col - 1 >= 0 && cell[row][col - 1].isHidden() && !cell[row][col - 1].isFlag()) {
	addi $t3, $t2, -1		# col - 1		
	bge $t3, 0, check4
	j move4
check4:
	move $a0, $t0
	move $a1, $t1
	move $a2, $t3
	
	addi $sp, $sp, -12
	sw $t1, 0($sp)
	sw $t2, 4($sp)
	sw $ra, 8($sp)
	
	jal getCellArray		# cell[row][col - 1]
	
	lw $t1, 0($sp)
	lw $t2, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	
	move $t3, $v0
	andi $t4, $t3, 0x40		# cell[row ][col - 1].isHidden()
	bnez $t4, move4
	andi $t4, $t3, 0x10		# !cell[row][col - 1].isFlag()
    	bnez $t4, move4
    	
    	addi $t4, $t2, -1		# subtract col - 1
    	addi $sp, $sp, -8
    	sw $t1, 0($sp)
    	sw $t4, 4($sp)
move4:
	# if (row - 1 >= 0 && col - 1 >= 0 && cell[row - 1][col - 1].isHidden() && !cell[row - 1][col - 1].isFlag()) {
	addi $t3, $t1, -1		# row - 1
	addi $t4, $t2, -1		# col - 1
	bge $t3, 0, check51
	j move5
check51:
	bge $t4, 0, check5
	j move5
check5:
	move $a0, $t0
	move $a1, $t3
	move $a2, $t4
	
	addi $sp, $sp, -20
	sw $t1, 0($sp)
	sw $t2, 4($sp)
	sw $ra, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	
	jal getCellArray		# cell[row - 1][col - 1]
	
	lw $t1, 0($sp)
	lw $t2, 4($sp)
	lw $ra, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	addi $sp, $sp, 20
	
	move $t5, $v0
	andi $t6, $t5, 0x40		# cell[row - 1][col - 1].isHidden()
	bnez $t6, move5
	andi $t6, $t5, 0x10		# !cell[row - 1][col - 1].isFlag()
    	bnez $t6, move5
    	
    	addi $sp, $sp, -8
    	sw $t3, 0($sp)
    	sw $t4, 4($sp)
move5:
	# if (row - 1 >= 0 && col + 1 < 10 && cell[row - 1][col + 1].isHidden() && !cell[row - 1][col + 1].isFlag()) {
	addi $t3, $t1, -1		# row - 1
	addi $t4, $t2, 1		# col + 1
	bge $t3, 0, check61
	j move6
check61:
	blt $t4, 10, check6
	j move6
check6:
	move $a0, $t0
	move $a1, $t3
	move $a2, $t4
	
	addi $sp, $sp, -20
	sw $t1, 0($sp)
	sw $t2, 4($sp)
	sw $ra, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	
	jal getCellArray		# cell[row - 1][col + 1]
	
	lw $t1, 0($sp)
	lw $t2, 4($sp)
	lw $ra, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	addi $sp, $sp, 20
	
	move $t5, $v0
	andi $t6, $t5, 0x40		# cell[row - 1][col + 1].isHidden()
	bnez $t6, move6
	andi $t6, $t5, 0x10		# !cell[row - 1][col + 1].isFlag()
    	bnez $t6, move6
    	
    	addi $sp, $sp, -8
    	sw $t3, 0($sp)
    	sw $t4, 4($sp)
move6:
	# if (row + 1 < 10 && col - 1 >= 0 && cell[row + 1][col - 1].isHidden() && !cell[row + 1][col - 1].isFlag()) {
	addi $t3, $t1, 1		# row + 1
	addi $t4, $t2, -1		# col - 1
	blt $t3, 10, check71
	j move7
check71:
	bge $t4, 0, check7
	j move7
check7:
	move $a0, $t0
	move $a1, $t3
	move $a2, $t4
	
	addi $sp, $sp, -20
	sw $t1, 0($sp)
	sw $t2, 4($sp)
	sw $ra, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	
	jal getCellArray		# cell[row + 1][col - 1]
	
	lw $t1, 0($sp)
	lw $t2, 4($sp)
	lw $ra, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	addi $sp, $sp, 20
	
	move $t5, $v0
	andi $t6, $t5, 0x40		# cell[row + 1][col - 1].isHidden()
	bnez $t6, move7
	andi $t6, $t5, 0x10		# !cell[row + 1][col - 1].isFlag()
    	bnez $t6, move7
    	
    	addi $sp, $sp, -8
    	sw $t3, 0($sp)
    	sw $t4, 4($sp)
move7:
	# if (row + 1 < 10 && col + 1 < 10 && cell[row + 1][col + 1].isHidden() && !cell[row + 1][col + 1].isFlag()) {
	addi $t3, $t1, 1		# row + 1
	addi $t4, $t2, 1		# col + 1
	blt $t3, 10, check81
	j move8
check81:
	blt $t4, 10, check8
	j move8
check8:
	move $a0, $t0
	move $a1, $t3
	move $a2, $t4
	
	addi $sp, $sp, -20
	sw $t1, 0($sp)
	sw $t2, 4($sp)
	sw $ra, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	
	jal getCellArray		# cell[row + 1][col + 1]
	
	lw $t1, 0($sp)
	lw $t2, 4($sp)
	lw $ra, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	addi $sp, $sp, 20
	
	move $t5, $v0
	andi $t6, $t5, 0x40		# cell[row + 1][col + 1].isHidden()
	bnez $t6, move8
	andi $t6, $t5, 0x10		# !cell[row + 1][col + 1].isFlag()
    	bnez $t6, move8
    	
    	addi $sp, $sp, -8
    	sw $t3, 0($sp)
    	sw $t4, 4($sp)
move8:
	j while
endWhile:
    	jr $ra
    
getCellArray:
	move $t7, $a0			# Cell Array Address
	move $t8, $a1			# Store the row
	move $t9, $a2			# Store the col
	li $t5, 10
	li $t6, 0			# Temp variable
	
	mul $t6, $t8, $t5
	add $t6, $t6, $t9
	
	add $t6, $t6, $t7
	
	lb $v0, 0($t6)
	
	jr $ra
   
#################################################################
# Student defined data section
#################################################################
.data
.align 2  # Align next items to word boundary
buffer: .space 1300000
cursor_row: .word -1
cursor_col: .word -1
arrayCoordinates: .space 100
arrayCheck: .space 198

#place any additional data declarations here
