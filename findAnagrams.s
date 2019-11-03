	.data
	.align 2
k:      .word   4       # include a null character to terminate string
s:      .asciiz "bac"
n:      .word   6
L:      .asciiz "abc"
        .asciiz "bbc"
        .asciiz "cba"
        .asciiz "cde"
        .asciiz "dde"
        .asciiz "dec"
y:      .asciiz "Amount of strings that are anagrams of key word: "
    .text
### ### ### ### ### ###
### MainCode Module ###
### ### ### ### ### ###
main:
    li $t9,4                # $t9 = constant 4
    
    lw $s0,k                # $s0: length of the key word
    la $s1,s                # $s1: key word
    lw $s2,n                # $s2: size of string list
    
# allocate heap space for string array:    
    li $v0,9                # syscall code 9: allocate heap space
    mul $a0,$s2,$t9         # calculate the amount of heap space
    syscall
    move $s3,$v0            # $s3: base address of a string array
# record addresses of declared strings into a string array:  
    move $t0,$s2            # $t0: counter i = n
    move $t1,$s3            # $t1: address pointer j 
    la $t2,L                # $t2: address of declared list L
READ_DATA:
    blez $t0,FIND           # if i >0, read string from L
    sw $t2,($t1)            # put the address of a string into string array.
    
    addi $t0,$t0,-1
    addi $t1,$t1,4
    add $t2,$t2,$s0
    j READ_DATA
 
FIND: 
#$s0 - length of key word
#$s1 - key word
#$s2 - size of string list
#$s3 - base address of loaded array

###
### Sort all strings in L
###

li $s6, 0; # s6: counter of which string currently, from 0

START_SORT:
    # Check if string counter < amount of strings
    blt $s6, $s2, SORT_STRING

    j STRING_LIST_SORT_END

SORT_STRING:
    li $a1, 0 # Start Index
    subi $a2, $s0, 2 # End Index = length of string - 2 (1 because 0 index, 1 because null terminated)
    mul $t0, $s6, $t9 # Start address of word from array
    add $s3, $s3, $t0 # Advance index
    lw $s4, ($s3) # Current word - referred to as Arr

    jal MERGE_SORT #call merge sort

    sw $s4, ($s3) # Take sorted word (s4) and put back into L

    addi $s6, $s6, 1 # advance word counter by 1

    j START_SORT

MERGE_SORT:
    
    slt $t0, $a1, $a2 #if start < end
    li $t1, 1 # load 1 for comparison
    bne $t0, $t1, END_0

    # calculate variables
    add $t1, $a1, $a2 # start + end
    li $t2, 2 # load 2 for division
    div $a3, $t1, $t2 #mid index: (start + end) / 2
    
    
    
    # store state
    addi $sp, $sp, -12 # allocate space in stack
    sw $ra, 8($sp) # store return address
    sw $a1, 4($sp) # store start index
    sw $a2, 0($sp) # store end index
    
    move $a2, $a3 # set end index as mid
    jal MERGE_SORT # mergeSort(Arr, start, mid);
    
    # preserve state:
    lw $ra, 8($sp) 
    lw $a1, 4($sp)
    lw $a2, 0($sp)
    addi $sp, $sp, 12
    
    
    
    # store state
    addi $sp, $sp, -12 # allocate space in stack
    sw $ra, 8($sp) # store return address
    sw $a1, 4($sp) # store start index
    sw $a2, 0($sp) # store end index

    addi $a1, $a3, 1 # set start index to mid+1
    jal MERGE_SORT # mergeSort(Arr, mid+1, end)
    
    # preserve state:
    lw $ra, 8($sp) 
    lw $a1, 4($sp)
    lw $a2, 0($sp)
    addi $sp, $sp, 12
    
    
    
    # store state
    addi $sp, $sp, -12 # allocate space in stack
    sw $ra, 8($sp) # store return address
    sw $a1, 4($sp) # store start index
    sw $a2, 0($sp) # store end index
    
    jal MERGE # merge(Arr, start, mid, end)
    
    # preserve state:
    lw $ra, 8($sp) 
    lw $a1, 4($sp)
    lw $a2, 0($sp)
    addi $sp, $sp, 12
    
END_0:
    jr $ra
    
MERGE:
    # allocate space in heap for individual word
    li $v0, 9
    mul $a0, $t9, $s0 # $a0 = 4 * length of word
    syscall # $v0: address of heap space
    move $t7, $v0 # $t7: address of heap
    
    # crawlers for intervals and heap
    move $t0, $a1 # int i = start
    addi $t1, $a3, 1 # j = mid + 1
    li $t2, 0 # k = 0
    
    # traverse the heap and word and in each iteration
    # add the smaller of both elements in heap
    #
    # while(i <= mid && j <= end)
WHILE_1:
    # if i <= mid
    ble $t0, $a3, L1
    j WHILE_2
L1:
    #if j <= end - ONLY CHECKED IF i<=mid TRUE!
    ble $t1, $a2, L2
    j WHILE_2
L2:
    # if(Arr[i] <= Arr[j])
    add $t4, $t0, $s4 # Arr[i] - advance address
    add $t3, $t1, $s4 # Arr[j] - advance address
    
    # load bytes from address
    lb $t5, ($t4) #contents of Arr[i]
    lb $t6, ($t3) #contents of Arr[j]

    # compare 
    ble $t5, $t6, IF_1
#ELSE_1
    #temp[k] = Arr[j]
    mul $s7, $t2, $t9 # multiply index by 4 for heap
    add $t7, $t7, $s7 # advance heap to correct address
    sb $t6, ($t7) # store address of Arr[j] in heap
    sub $t7, $t7, $s7 # set address back to initial of Arr
    
    addi $t2, $t2, 1 #k += 1
    addi $t1, $t1, 1 #j += 1
    
    j WHILE_1
    
IF_1:
    #temp[k] = Arr[i]
    mul $s7, $t2, $t9 # multiply index by 4 for heap
    add $t7, $t7, $s7 # advance temp to correct address
    sb $t5, ($t7) # store address of Arr[i] in heap
    sub $t7, $t7, $s7 # set address of heap back to initial of Arr

    addi $t2, $t2, 1 #k += 1
    addi $t0, $t0, 1 #i += 1
    
    j WHILE_1

# add elements left in the first while loop
WHILE_2:
    # if i <= mid
    ble $t0, $a3, L3
    j WHILE_3
    
L3:
    #heap[k] = Arr[i]
    mul $s7, $t2, $t9 # multiply index by 4 for heap
    add $t7, $t7, $s7 # advance heap to correct address
    lb $t5, ($t4) #contents of Arr[i]

    sb $t5, ($t7) # store address of Arr[i] in heap
    sub $t7, $t7, $s7 # set address of heap back to initial of Arr
    
    addi $t2, $t2, 1 #k += 1
    addi $t0, $t0, 1 #i += 1
    
    j WHILE_2

WHILE_3:
    #if j <= end
    ble $t1, $a2, L4
    j END_3
L4:
    #heap[k] = Arr[j]
    mul $s7, $t2, $t9 # multiply index by 4 for heap
    add $t7, $t7, $s7 # advance heap to correct address
    lb $t6, ($t3) #contents of Arr[j]
    sb $t6, ($t7) # store address of Arr[i] in heap
    sub $t7, $t7, $s7 # set address back to initial of Arr
    
    addi $t2, $t2, 1 #k += 1
    addi $t1, $t1, 1 #j += 1
    
    j WHILE_3
    
END_3:
    # reset i = start
    move $t0, $a1
WHILE_4:
    #while i <= end
    ble $t0, $a2, L5
    j END_4
L5:
    #Arr[i] = heap[i]
    add $s4, $s4, $t0 # Arr[i] - advance final to correct address
    mul $s7, $t0, $t9 # multiply index by 4 for heap
    add $t7, $t7, $s7 # heap[i] - advance heap to correct address

    lb $t5, ($t7) #contents of heap[i]
    sb $t5, ($s4) # store address of heap in final

    sub $s4, $s4, $t0 # restore final to initial address
    sub $t7, $t7, $s7 # restore heap to initial address
    
    addi $t0, $t0, 1 #increment i by 1
    j WHILE_4 # loop
END_4:
    jr $ra

###
### Sort key word
###

STRING_LIST_SORT_END:
    li $a1, 0 # Start Index
    sub $a2, $s0, $t0 # End Index = length of string - 1
    move $s4, $s1 # Current word

    jal MERGE_SORT #call function to sort the key word
    #sorted key word now stored in $s4!


    #Check how many sorted strings in L are identical to the sorted string s4
    li $s6, 0; # s6: counter of which string currently, from 0
    li $t7, 0 # Counter of how many strings are anagrams
START_CHECK:
    blt $s6, $s2, CHECK_IF_IN_LIST # if i < amount of strings then show amount of anagrams

    j DISPLAY_COUNT
    
CHECK_IF_IN_LIST:
    lw $s4, 0($s4) # reset key word to the start
    lw $s3, 0($s3)# reset array of strings back to start
    li $t0, 4
    mul $t0, $t0, $s6 # address no to advance to for current string
    add $s3, $s3, $t0 # advance array to correct string

    #check if key[j]=stored[j]
    li $t0, 0 #i, start from 0
    sub $t1, $s0, $t0 #end index = length of word - 1
    blt $t0, $t1, INNER_LOOP #if i < end index

    j END_INNER_LOOP

INNER_LOOP:
    add $s3, $s3, $t0 # advance sorted string
    add $s4, $s4, $t0 # advance key word
    lb $t2, ($s3) # get current character from sorted string
    lb $t3, ($s4) # get current character from key word
    
    beq $t2, $t3, EQUAL
    j END_INNER_LOOP #not equal, advance to the next word
EQUAL:
    #check if last, if last then increase coounter by one and go to next work
    #if not last, increase i and keep going with loop
    subi $t4, $t1, 1 # end index - 1: last character
    ble $t4, $t0, LAST_CHARACTER
    #else - not last character
    addi $t0, $t0, 1 #increment counter
    
    j INNER_LOOP #check next character

#last character and it's equal
LAST_CHARACTER:
    addi $t7, $t7, 1 #increment anagram counter
    addi $s6, $s6, 1 #increment word counter
    j START_CHECK #loop next word
    
END_INNER_LOOP:
    addi $s6, $s6, 1 #increment word counter
    j START_CHECK #loop next word


###
### Display amount of anagrams
###
DISPLAY_COUNT:
    # Print info string before number
    la $a0, y
    li $v0, 4
    syscall

    # Print amount of anagrams
    move $a0, $t7
    li $v0, 1
    syscall

    # Quit program
    li 	$v0,10		 
    syscall
    