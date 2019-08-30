# Who:  Kristine Vo
# What: 2.asm
# Why:  calculate the n-th Fibonacci number.
# When: Created 14 March 2019, due 17 March 2019
# How:  $s0(saved array for f(n)), $s1(used as holder of n-value), 
#       $t0(used as counter), $t1(used as pointer for loops), $t2(used as 'a' in FibFunction), $t3(used as 'b' in FibFunction), 
#       $t4(used as shifted array), $t5 (used for temp holder in FibFunction)


.data
fibonacci_arr:  .space 188
prompt:         .asciiz "Enter a value 'n' to find the n-th value of the fibonacci sequence: "
invalid_input:  .asciiz "Error: 'n' must be a positive value from 0 to 47, please try again. "
answer:         .asciiz "n-th value of the fibonacci sequence: "
sequence:       .asciiz "The rest of the sequence beginning with n = 0 : "
newLine:        .asciiz "\n"
space:          .asciiz " "
.text
.globl main


main:	# program entry
  
  #prompt for user input
  la $a0, prompt
  li $v0, 4
  syscall

  #get user input and store in reg
  li $v0, 5
  syscall
  # save n for later usage
  move $s1, $v0
  
  #if the user input is invalid, send it to the error message and start from main
  blt $t0, $zero, invalid
  bgt $t0, 46, invalid
  
  #if nothing is wrong with the input then continue the program
  #load array into register so that we can modify it
  la $s0, fibonacci_arr
 
  #pointer
  li $t1, 1   
  j baseCase
 
baseCase:
  #counter
  li $t0, 0
  
  #initialize a and b
  li $t2, 0
  li $t3, 1
  
  #t4 will be the original array being modified but we use t4 to shift
  addu $t4, $s0, $zero
  
  # arr[0] = a, 0
  sw $t2, 0($t4) 
  
  #if the value is already 0, then there is no need to continue 
  beq $t0, $s1, print
  
  #shift the array over 4 bits
  sll $t1, $t1, 2
  
  #0 index of the array changes
  addu $t4, $s0, $t1
  
  #put b into that array element
  sw $t3, 0($t4)
  
  #increment the counter
  addi $t0, $t0, 2
  
  #if the counter == n then stop
  beq $t0, $s1, print

  #jump to the fibonacci loop for values that are not the base values
  j fibLoop
  
fibLoop:
  #if the counter is larger than n, then we print
  bgt $t0, $s1, print
  
  #shift the array over so that the pointer is at the appropriate location: 4 bits
  sll $t1, $t0, 2
  
  #add offset to beginning of array, call this t4
  addu $t4, $s0, $t1
  
  # temp = b
  la $t5,($t3) 
  # b = a + b
  addu $t3, $t3, $t2
  #a = temp
  addu $t2, $t5, $zero
  
  #store value in next array element
  sw $t3, 0($t4)
  
  #increment counter
  addu $t0, $t0, 1
  j fibLoop
  
print:
  #tells the user that the answer will be displayed
  la $a0, answer
  li $v0, 4
  syscall

  #prints the value at the end of the array
  lw $a0, 0($t4) 
  li $v0, 36
  syscall
  
  # \n
  la $a0, newLine
  li $v0, 4
  syscall
  
  # tells the user that the program will now print the numbers before the answer
  la $a0, sequence
  li $v0, 4
  syscall
  
  #if n is 0, then there are no values in the sequence preceding the answer
  beq $s1, $zero, exit
  
  #reload the array into t4
  la $t4, fibonacci_arr
  
  #print the first value of the array
  # I did this because I would later use the counter > 0 to shift the array
  lw $a0, 0($t4)   
  li $v0, 36
  syscall
  
  la $a0, space
  li $v0, 4
  syscall
  
  # offset and counter are back to 1
  li $t1, 1
  li $t0, 1
  j print_array
 
print_array: 
  #if the counter == n, we're done
  beq $t0, $s1, exit
  #shift the array over 4 bits so that the pointer is at the next value
  sll $t1, $t0, 2
  #t4 starts at (array + offset) 
  addu $t4, $s0, $t1
  
  #loads value at array location into argument to print
  lw $a0, 0($t4)
  li $v0, 36
  syscall
  
  la $a0, space
  li $v0, 4
  syscall
  
  #increment counter
  addi $t0, $t0, 1
  j print_array

invalid:
  #print out the error message and jump back to beginning of program
  la $a0, invalid_input
  li $v0, 4
  syscall
  
  la $a0, newLine
  li $v0, 4
  syscall
  j main
 
exit:
  li $v0, 10		# terminate the program
  syscall
