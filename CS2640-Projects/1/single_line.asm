# Who:  Kristine Vo
# What: single_line.asm
# Why:  We did this to get a feel of the MIPS programming language. In this program, we need to print all the inputs in a single line.
# When: Created March 1, 2019, Due March 3, 2019 @ 23:59
# How:  $t0, $t1, $t2, $t3, $a0, $v0

.data
#allocate space for the array 20 * 4
array: .space 80

#prompt for user input and space between int values when printed
prompt: .asciiz "Please enter in an int and then press enter (This will repeat 20 times): "
space: .asciiz " "

.text
.globl main

main:
  #insert array into $t0
  la $t0, array
  #establish an index for the userInput $t1
  li $t1, 80
  #userInput $t2
  li $t2, 0
  #establish an index for the printLoop $t3
  li $t3, 80
  #start input
  j inputLoop
  
inputLoop:
  #while ($t1 != 0)
  beq $t1, 0, printLoop
  
  #print prompt
  la $a0, prompt
  li $v0, 4
  syscall
  
  #get input data
  li $v0, 5
  syscall
  
  #store input data
  move $t2, $v0
  sw $t2, 0($t0)
  
  #increment
  addiu $t1, $t1, -4
  addiu $t0, $t0, 4
  
  #loop back
  j inputLoop

printLoop:
  #start at beginning of loop
  #while ($t3 == 0)
  beq $t3, 0, exit
  
  #print out array element
  lw $a0, -80($t0)
  li $v0, 1
  syscall
  
  #print space
  la $a0, space
  li $v0, 4
  syscall
  
  #increment/decrement index and pointer location
  addiu $t3, $t3, -4
  addiu $t0, $t0, 4
  
  #loop back
  j printLoop
  
exit: 
  li $v0, 10
  syscall
