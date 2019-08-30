# Who:  Kristine Vo
# What: 3.asm
# Why:  Make an array, order it as you enter in values, use binary search to find median, max, min, and non-existing number
# When: Due April 02, 2019
# How:  $s0 was used for the saved array, $s1 was used for the value of array.size
#       $t0/1/2/3/4: t0/t1/2 was often used as a counter in making the array
#                    t3 and t4 were often used to shift the array
#                    in the Binary Search Portion, they were often used for arithmetic


.data
promptN:       .asciiz "\nHow many signed integers would you like to enter?: "
promptArrVal:  .asciiz "\nPlease enter number to store into the array: "
promptSearch:  .asciiz "\nWhat value would you like to search for: "
found:         .asciiz "\nThe value is in the array."
notFound:      .asciiz "\nThe value is not in the array."
space:         .asciiz " "
.text

arraySize:
  #prompt user for N
  la $a0, promptN
  li $v0, 4
  syscall
 
  #$s1 is the array size
  li $v0, 5
  syscall
  la $s1, ($v0) 
  
  #allocate space 
  addu $sp, $sp, $t0 
  #$s0 is array location
  la $s0, ($sp)
  
  #value to indicate empty cells
  li $t3, 2147483648

initializeArrayValues:
   #give values to indicate empty cells
   beq $t0, $s1, reset
   sll $t1, $t0, 2
   addu $t2, $s0, $t1
   sw $t3, 0($t2)
   addiu $t0, $t0, 1
   j initializeArrayValues

reset:
  li $t0, 0
  li $t1, 0
  j arrayValues
  
arrayValues:  
  #$t0 is the counter for how many elements to input
  beq $t0, $s1, reset2
  
  #prompt to enter in array element
  la $a0, promptArrVal
  li $v0, 4
  syscall
  
  #take in user input
  li $v0, 5
  syscall

  #t1 is pointer to last element
  addi $t1, $t1, 4
  
  #increment the counter
  addi $t0, $t0, 1
  
  #$t2 is the offset to insert value
  li $t2, 0
  
  j sortValue
  
sortValue:  
  #get value of array element[i] and cycle through them 
  sll $t4, $t2, 2
  addu $t3, $s0, $t4
  lw $a0, 0($t3) 

  #base case if the next cell is empty
  beq $a0, 2147483648, insert1
  
  #counter for how many values to shift
  addi $t2, $t2, 1
  
  #if(current <= input) then check the next value in the array
  ble $a0, $v0, sortValue

  #if(current > input) then begin to shift values
  blt  $v0, $a0, setLast
  
setLast:
  #set a pointer to the last, active element in the array
  addu $t3, $s0, $t1
  subu $t2, $t0, $t2
  j shiftValues

shiftValues:
  #insert value after we shift all of the value after the insert location
  beq $t2, 0 , insert2
  
  #temp = array[last - 1]
  lw $t4, -8($t3) 
  
  #array[last] = temp
  sw $t4, -4($t3)
  
  #move pointer 
  addi $t3, $t3, -4
  addi $t2, $t2, -1
  j shiftValues

insert1:
  #to insert first value into the array
  sw $v0, 0($t3)
  j arrayValues

insert2:
   #insert value if there are already elements in the array
   sw $v0, -4($t3)
   j arrayValues

print:
  #print the array contents
  beq $t0, $s1, searchPrompt
    
  sll $t1, $t0, 2 
  addu $t3, $s0, $t1
  
  addiu $t0, $t0, 1
  
  lw $a0, 0($t3) 
  li $v0, 1
  syscall
  
  la $a0, space
  li $v0, 4
  syscall
  
  j print

reset2:
  li $t0, 0
  li $t1, 0
  j print

searchPrompt:
  la $a0, promptSearch
  li $v0, 4
  syscall
  
  li $v0, 5
  syscall
  
search:
  #start
  move $t0, $0
  
  #end
  move $t1, $s1
  
  #if(start > end)
  bgt $t0, $t1, false
  
  #(end - start)/2
  subu $t2, $t1, $t0
  sra $t2, $t2, 1
  
  # start + (end - start)/2
  # $t2 = mid
  addu $t2, $t0, $t2
  
  #$t3 = array[mid]
  
  #t3 is the offset
  sll $t3, $t2, 2
  #t3 is the location on array with offset
  addu $t3, $s0, $t3
  #t3 is array[mid]
  lw $t3, 0($t3)
  j BScomparisons
  
BScomparisons: 
  #if(start > end)
  bgt $t0, $t1, false
  
  #if (array[mid] == searchVal) return true;
  beq $v0, $t3, true
  
  #if(array[mid] > searchVal) return Binary(array, start, mid - 1, searchVal);
  blt $v0, $t3, BSFirstHalf
  
  #return binarySeach(array, mid + 1, end, searchVal)
  bgt $v0, $t3, BSSecondHalf

BSFirstHalf:
  #start
  addi $t0, $t0, 0
  
  #mid - 1 aka end
  subiu $t1, $t2, 1

  #start + ((mid - 1) - start)/2
  subu $t2, $t1, $t0
  sra $t2, $t2, 1
  addu $t2, $t0, $t2
    
  #array[mid]
  sll $t3, $t2, 2
  addu $t3, $s0, $t3
  lw $t3, 0($t3) 
  
  j BScomparisons

BSSecondHalf:
  #start aka (mid + 1)
  addi $t0, $t2, 1
  
  #end is $s1
  move $t1, $s1

  #(end - (mid+1))/2
  subu $t2, $t1, $t0
  sra $t2, $t2, 1
  
  #start + (end - (mid+1))/2
  #mid
  addu $t2, $t0, $t2
    
  #array[mid]
  sll $t3, $t2, 2
  addu $t3, $s0, $t3
  lw $t3, 0($t3) 
  
  j BScomparisons

false:
  la $a0, notFound
  li $v0, 4 
  syscall
  j searchPrompt

true:
 la $a0, found
 li $v0, 4 
 syscall
 j searchPrompt
