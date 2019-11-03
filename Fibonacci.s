    .data
	.align 2
inputMsg: .asciiz "Provide an integer for the Fibonacci computation:\n"
outputMsg: .asciiz "The Fibonacci numbers are:\n"
incorrectInputMsg: .asciiz "Incorrect input. Please enter a valid number:\n"
overflowMsg: .asciiz "\nOverflow occured, terminating program."
colonSpace: .asciiz ": "
newLine: .asciiz "\n"
buffer: .space 20
    .text
### ### ### ### ### ###
### MainCode Module ###
### ### ### ### ### ###
main:
    # Display prompt for user input
    la $a0, inputMsg
    li $v0, 4
    syscall
    
START_INPUT:
    # Receive user input as string and store in $v0
    li $v0, 8
    la $a0, buffer  # Load byte space into address
    li $a1, 20      # Allot the byte space for string
    syscall
    
    move $s5, $a0 # Move result from a0 to s5
    
    li $s0, 0 # Final, total number
    li $t0, 0 # Initialize the character position counter to 0
    
INPUT_LOOP:
    add $s5, $s5, $t0 # Advance result to next byte
    lb $t2, ($s5) # Load current byte
    beqz $t2, EXIT_INPUT_LOOP # Check if byte = 0, in which case end reached
    
    li $t3, 48 # Load 48 for comparison
    bge $t2, $t3, ABOVE_48 # Check if value is above or equal to 48 (ascii for 0)
    j INCORRECT_INPUT
    
ABOVE_48:
    li $t4, 57 # Load 57 for comparison
    ble $t2, $t4, BELOW_57 # Check if value is equal to or below 57 (ascii for 9)
    j INCORRECT_INPUT
    
BELOW_57:
    # Take 48 away from byte to get actual integer value
    subi $t2, $t2, 48
    
    # If first integer, add to total
    beqz $t0, FIRST_INTEGER 
    
    # If not first integer, multiply total by 10, then add to total
    li $t3, 10 # Load 10 for comparison
    mul $s0, $s0, $t3 # Multiply total by 10
    add $s0, $s0, $t2 # Add integer to total
    addi $t0, $t0, 1# Increment counter
    j INPUT_LOOP # Loop again
    
FIRST_INTEGER:
    add $s0, $s0, $t2 # Add integer to total
    addi $t0, $t0, 1# Increment counter
    j INPUT_LOOP # Loop again
    
EXIT_INPUT_LOOP:
    beqz $t0, INCORRECT_INPUT # Check if counter t0 is 0, if so incorrect input
    j CORRECT_INPUT # Character is 0 so end if input, but number was valid
    
INCORRECT_INPUT:
    # If input is incorrect, print an error message and ask for input again
    la $a0, incorrectInputMsg
    li $v0, 4
    syscall
    
    j START_INPUT
    
CORRECT_INPUT:
    # Allocate space in heap
    li $t9,4 # constant 4
    li $v0,9 # syscall code 9: allocate heap space
    addi $t7, $s0, 1 # Heap = n+1
    mul $a0,$t7,$t9 # calculate the amount of heap space (input+1 * 4)
    syscall
    move $s1,$v0 # $s1: address of heap for array
    
    # Display result message
    la $a0, outputMsg
    li $v0, 4
    syscall
    
    # Loop through all integers until input value reached
    li $t0, 0 # $t0: i
    
MAIN_LOOP:
    bgt $t0, $s0, END_PROGRAM # If i <= n, i has reached limit so end program
    
    move $a1, $t0 # Move input to function argument
    jal FIB # Call fib
    
    # Copy return value from fib
    move $t3, $v0
    
    # Print i
    move $a0, $t0
    li $v0, 1
    syscall
    
    # Print ": "
    la $a0, colonSpace
    li $v0, 4
    syscall
    
    # Print returned integer
    move $a0, $t3
    li $v0, 1
    syscall
    
    # Check if overflow occured, if it did then terminate program
    bltz $t3, OVERFLOW
    
    # Print new line
    la $a0, newLine
    li $v0, 4
    syscall
    
    # i++ and loop
    addi $t0, $t0, 1
    j MAIN_LOOP
    
OVERFLOW:
    # Print notifying message
    la $a0, overflowMsg
    li $v0, 4
    syscall
    
    # Exit program
    j END_PROGRAM
    
FIB:
    # If $a1 <= 0, return 0
    blez $a1, INPUT_0
    
    # If $a1 == 1, return 1
    li $t1, 1 # Load 1 for comparison
    beq $a1, $t1, INPUT_1 # Check if $a1 == 1
    
    # If $a0 > 0 and stored in memory, return it so no calculations needed
    li $t3, 4 # Load 4 for heap
    mul $t4, $a1, $t3 # Get address for heap
    add $s1, $s1, $t4 # Advance heap
    lw $t5, ($s1) # Load word from heap
    sub $s1, $s1, $t4 # Go back to initial heap address
    bne $t5, $zero, VALUE_STORED # If heap !=0, value stored so return
    
    # Call fib for $a1-1
    addi $sp, $sp, -8
    sw $ra 4($sp)
    sw $a1 0($sp)
    
    subi $a1, $a1, 1 # $a1-1
    jal FIB
    
    # Copy return value
    move $t6, $v0
    
    # Preserve state
    lw $ra 4($sp)
    lw $a1 0($sp)
    addi $sp, $sp, 8
    
    # Get value of FIB for $a1-2
    addi $sp, $sp, -8
    sw $ra 4($sp)
    sw $a1 0($sp)
    
    subi $a1, $a1, 2 # $a1-2
    jal FIB
    
    # Copy return value
    move $t7, $v0
    
    # Preserve state
    lw $ra 4($sp)
    lw $a1 0($sp)
    addi $sp, $sp, 8
    
    # Add values of FIB for $a1-1 and FIB for $a1-2 together and store in heap
    add $t8, $t6, $t7 # Add fib for $a1-1 and $a1-2
    li $t3, 4 # Load 4 for heap
    mul $t4, $a1, $t3 # Get address to advance heap by
    add $s1, $s1, $t4 # Advance heap
    sw $t8, ($s1) # Store new value in heap
    sub $s1, $s1, $t4 # Go back to initial heap address
    
    # Set newly calculated value as return value
    move $v0, $t8
    
    # Exit loop
    j EXIT_INNER_LOOP
    
INPUT_0:
    # Store 0 as return value
    li $v0, 0
    
    # Exit loop
    j EXIT_INNER_LOOP

INPUT_1:
    #Store 1 as return value
    li $v0, 1
    
    # Exit loop
    j EXIT_INNER_LOOP
    
VALUE_STORED:
    # Take already stored value and return it
    move $v0, $t5
    
    # Exit loop
    j EXIT_INNER_LOOP

EXIT_INNER_LOOP:
    # Return to caller
    jr $ra

END_PROGRAM:
    # Quit program
    li 	$v0,10		 
    syscall