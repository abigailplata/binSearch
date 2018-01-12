.data 

original_list: .space 100 #max 20 integers because 1 int = 4 bytes
sorted_list: .space 100

str0: .asciiz "Enter size of list (between 1 and 25): " 
str1: .asciiz "Enter one list element: \n" #str1 holds the contents of the list
str2: .asciiz "Content of list: "
str3: .asciiz "Enter a key to search for: "
strYes: .asciiz "Key found!"
strNo: .asciiz "Key not found!"

whitespace: .asciiz " "
nextline: .asciiz "\n"

.text 
#This is the main program.
#It first asks user to enter the size of a list.
#It then asks user to input the elements of the list, one at a time.
#It then calls printList to print out content of the list.
#It then calls inSort to perform insertion sort
#It then asks user to enter a search key and calls bSearch on the sorted list.
#It then prints out search result based on return value of bSearch
main: 
	addi $sp, $sp -8
	sw $ra, 0($sp)
	li $v0, 4 		
	la $a0, str0		#addi $v0, $v0, 4
	la $a0, str0 		#lui $a0, upper(srt0)
				#ori $a0, lower(str0) 
	
	syscall 
	li $v0, 5	#Read size of list from user
				#li is:
				#lui $v0, upper(5)
				#ori $vo, lower(5)
	syscall	
	move $s0, $v0		#addi $s0, $v0, 0 
	move $t0, $0		#addi $t0, $0, 0
	la $s1, original_list	#lui $s1, upper(original_list)
				#ori $1, lower(original_list)
loop_in:
	li $v0, 4 
	la $a0, str1 
	syscall 
	sll $t1, $t0, 2
	add $t1, $t1, $s1
	li $v0, 5	#Read elements from user
	syscall
	sw $v0, 0($t1)
	addi $t0, $t0, 1
	bne $t0, $s0, loop_in
	
	li $v0, 4 
	la $a0, str2 
	syscall 
	move $a0, $s1
	move $a1, $s0
	jal printList	#Call print original list
	
	jal inSort	#Call inSort to perform insertion sort in original list
	sw $v0, 4($sp)
	li $v0, 4 
	la $a0, str2 
	syscall 
	lw $a0, 4($sp)
	jal printList	#Print sorted list
	
	li $v0, 4 
	la $a0, str3 
	syscall 
	li $v0, 5	#Read search key from user
	syscall
	move $a2, $v0
	lw $a0, 4($sp)
	jal bSearch	#Call bSearch to perform binary search
	
	beq $v0, $0, notFound
	li $v0, 4 
	la $a0, strYes 
	syscall 
	j end
	
notFound:
	li $v0, 4 
	la $a0, strNo 
	syscall 
end:
	lw $ra, 0($sp)
	addi $sp, $sp 8
	li $v0, 10 
	syscall
	#printList takes in a list and its size as arguments. 
#It prints all the elements in one line.
printList:
	#Your implementation of printList here	
	addi $sp, $sp -4 #since we have 2 arguments
	sw $ra, 0($sp)
	
	#set $a0 as the address of the array & $a1 is the array size
	move $t0, $a0 #moves the array address from $a0 to $t0
	move $t1, $a1 # since we set $a1 is the array size then $a1 is used as i, increment
	
	forLoop:#for (i=0; i < n; i++)
	
	lw $a0, 0($t0) #load word the contents of the array
	li $v0, 1
	syscall
	
	addi $t0, $t0, 4 
	addi $t1, $t1, -1

	beq $t1, $zero, append #check if $t1 is equal to zero, go to append before printing 
	j space

space: 
	la $t2, whitespace
	move $a0, $t2
	li $v0, 4
	syscall #execute
	
	j forLoop
append:
	la $t2, nextline
	move $a0, $t2
	li $v0, 4
	syscall	#execute
	#don't forget to restrore $ra!
	lw $ra, 0($sp) 
	addi $sp, $sp 4
	
	jr $ra	

#inSort takes in a list and it size as arguments. 
#It performs INSERTION sort in ascending order and returns a new sorted list
#You may use the pre-defined sorted_list to store the result
inSort:
	#Your implementation of inSort here
	addi $sp, $sp, -32 #this makes 8 spaces
	sw $ra, 8($sp)
	sw $s0, 12($sp)
	sw $s1, 16($sp)
	sw $s2, 20($sp)
	sw $s3, 24($sp)
	sw $s4, 28($sp)
	
	move $s0, $s1 #this the address of the array
	move $s1, $a1 #size of array
	addi $s2, $zero, 1 #this is i = 1
	
		thisIsarray:
		la $t0, original_list #this loads the original_list to $t0
		la $t1, sorted_list #this loads the sorted_list to $t1
		addi $t6, $t6, 0 #this will iterate the list
		
	
		thisIsarrayLoop:
		beq $s1, $t6, thisIsarrayAppend #compares $s1 and $t6 and if they are equal go to thisIsarrayAppend
		
		lw $t2, ($t0)
		sw $t2, ($t1)
		#this move the pointers and iterators to their next index
		addi $t0, $t0, 4 
		addi $t1, $t1, 4
		addi $t6, $t6, 1
		
		j thisIsarrayLoop #go back to start of the array 

		thisIsarrayAppend:
		la $t1, sorted_list
		move $s0, $t1
	
	
	loopForIterator:
	beq $s2, $s1, thisIsEnd #checks if i is equal to the array size, then if it is go to thisIsEnd
	
	sll $t2, $s2, 2 #shift left by 2 because i * 4
	add $t3, $s0, $t2  #$t3 is offset + original_list address
	lw $s3, ($t3) #don't forget to do load the contents; $t[3] = a[i]
	addi $s4, $s2, -1 #we add -1 because j = i - 1
	
		loopForJ:
		bltz $s4, thisIsEndForJ #check if it less than zero
		move $a0, $s3 #this sets $a0 to key
	
		la $t0, ($s0) 
		sll $t2, $s4, 2 #shift left by 2
		add $t3, $t0, $t2  #sets $t3 to a[j]
		lw $a1, ($t3) #don't forget to load the contents!
		
		jal stringLess
		
		move $t0, $v0
		beq $t0, $zero, thisIsEndForJ #checks if $t0 is equal to 0
		
		#this part: a[j+1] = a[j];
		#j = j - 1 or j = j--
		la $t0, ($s0) 
		sll $t2, $s4, 2 #shift left by 2
		add $t3, $t0, $t2
		lw $t4, 0($t3) #don't forget to load the contents! basically $t4 = a[j]

		addi $t2, $s4, 1 #this sets $t2 = j + 1
		sll $t3, $t2, 2 #shift left by 2
		add $t1, $t3, $s0 # a[j+i], address of this part
		sw $t4, 0($t1) #basically this part: a[j+1] = a[j];
		addi $s4, $s4, -1  #decrements j by 1
		
		j loopForJ #go back from the start
		
		thisIsEndForJ: #if j is equal to key
		move $t0, $s4
		addi $t0, $t0, 1
		sll $t2, $t0, 2
		add $t1, $s0, $t2
		
		sw $s3, ($t1) #don't forgert to save contents!
		
		
		addi $s2, $s2, 1 
		j loopForIterator #go back to here and start again
	
	thisIsEnd:
	move $a1, $s1 #get the contents of $s1 then put to $a1
	
	lw $ra, 8($sp) #don;t forget to load contents!
	lw $s0, 12($sp)
	lw $s1, 16($sp)
	lw $s2, 20($sp)
	lw $s3, 24($sp)
	lw $s4, 28($sp)
	addi $sp, $sp, 32
	
	la $v0, sorted_list #load the contents onto sorted_list/get the address
	jr $ra

		
stringLess: 

	move $t0, $a0 #are they equal to the key? then to this a[i]
	move $t1, $a1 #do this a[j]

	stringLessLoop:
	blt $t0, $t1, lessThan #checks if $t0 is less than $t1, then go to lessThan
	bge $t0, $t1, moreThan #checks if $t0 is bigger than $t1
	
	j stringLessLoop #go back from start
	
	thisIsEndForString:
	beq $t2, $zero, lessThan  #checks if $t2 is less than zero, then go to lessThan
	j moreThan #condition above is not true, then jump
	
	lessThan: 
	li $v0, 1 #now if the statement is true, then go onto do the next instruction
	j thisIsEndforStringLess 
	
	moreThan:
	li $v0, 0 #condition above is not true, then jump
	j thisIsEndforStringLess

	thisIsEndforStringLess: 
	jr $ra
	
	
#bSearch takes in a list, its size, and a search key as arguments.
#It performs binary search RECURSIVELY to look for the search key.
#It will return a 1 if the key is found, or a 0 otherwise.
#Note: you MUST NOT use iterative approach in this function.
bSearch:
	#Your implementation of bSearch here
#	move $s0, $a0 
#	move $s1, $a1 
#	move $s2, $a2 
#	move $s3, $a3 
#	li $s5, 0 
	
#	blt $s1, $s3, thisBsearchisFalse
	
#	sub $t0, $s1, $s3
#	div $t0, $t0, 2
#	add $s5, $s3, $t0
	
#	sll $t1, $s5, 2
#	add $t2, $s0, $t1
#	lw $t1, ($t2)
	
	
#	beq $t1, $s2, thisBsearchisTrue
	
#	li $t4, 0
#	li $t5, 0
	
#	slti $t4, $a3, 1
#	slti $t5, $a1, 1
	
#	add $t4, $t4, $t5
#	li $t5, 2
#	beq $t4, $t5, thisBsearchisFalse
	
#	bgt $t1, $s2,bSearchisGreater 
	
#	add $a3, $s5, $s3
#	j bSearch
	
	
#	bSearchisGreater:
#	sub $a1, $s5, $s3
#	j bSearch
	

#	thisBsearchisTrue:
#	li $v0, 1
#	jr $ra
	
#	thisBsearchisFalse:
#	li $v0, 0
#	jr $ra
beq $t3, $0, bStart
	move $t6, $0
	beq $s5, $0, no_return
	addi $s5, $s5, -1
	sll $t2, $s4, 2
	add $t1, $0, $s1
	add $t1, $t2, $t1
	lw $t6, ($t1)
	beq $t6, $s2, return
	slt $t8, $t6, $s2
	beq $t8, $0, front
	j back
	jal bSearch
	
bStart:
	move $t0, $0		#counter = 0
	move $t1, $0		#t1 = 0
	addi $t3, $0, 1
	sll $t1, $t0, 2		# 0 -> 4
	add $t1, $t1, $s1	#t1 = a		
	add $t6, $0, 1		#$t6 = True; terminate if no match
	add $s2, $0, $a2	#arg -> s2
	move $v0, $0		#$v0 = 0 for syscall
	add $s4, $s0, $0	
	div $s4, $s4, 2		#size div 2
	j bSearch
	
front:
	addi $s4, $s4, -1
	add $s0, $s4, $0
	j bSearch
	
back:
	addi $s4, $s4, 1
	add $a3, $0, $s4
	j bSearch
	
return: 

	add $v0, $0, 1
	jr $ra
	
no_return:
	jr $ra
