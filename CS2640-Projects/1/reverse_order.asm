# Who:  Kristine Vo
# What: reverse_order.asm
# Why:  We did this to get a feel of the MIPS programming language. In this program, we need to print all input values, n integers per a line, in reverse order.
# When: Created March 1, 2019, Due March 3, 2019 @ 23:59
# How:  $t0, $t1, $t2, $t3, $t4, $a0, $v0

.data
#allocate space for the arrray
array: .space 80

#initialize prompt lines, space and new line for the outputs
N: .asciiz "How many ints per a line would you like displayed (0 < n <= 20): "
prompt: .asciiz "Please enter in an int and then press enter (This will repeat 20 times): "
space: .asciiz " "
newLine: .asciiz "\n"

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
  
  #user input for lines, stored in $t4
  la $a0, N
  li $v0, 4
  syscall
  
  #get user input
  li $v0, 5
  syscall
  
  #set N to $t4
  move $t4, $v0
  
  
  
inputLoop:
  #while ($t1 != 0)
  beq $t1, 0, print
  
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
  
  #increment/decrement the index and the pointer location
  #I'm sorry if my numbers seem wonky, this is primarily due to the fact that I didn't know how to reset the pointer before the due date
  addiu $t1, $t1, -4
  addiu $t0, $t0, 4
  
  j inputLoop
  
print:
  #sets the index for the counter (how many numbers have been printed for a line) to 0
  move $t1, $0
  
  #goes back in the loop that prints the array elements
  j printLoop

printLoop:
  #start at beginning of loop
  #while ($t3 == 0)
  beq $t3, 0, exit
  
  #if $t1 == $t4 then we have a new line
  beq $t1, $t4, nextLine
  
  #print out array element
  lw $a0, -4($t0)
  li $v0, 1
  syscall
  
  #print space
  la $a0, space
  li $v0, 4
  syscall
  
  #decrement and the pointer the index for this loop
  addiu $t3, $t3, -4
  addiu  $t0, $t0, -4
  
  #increment the index for whether or not we need a new line
  addi $t1, $t1, 1
  
  j printLoop
 
nextLine:
  #prints a new line
  la $a0, newLine
  li $v0, 4 
  syscall
  
  #resets $t1 to 0
  li $t1, 0
  
  #back to loop
  j printLoop
  
exit: 
  li $v0, 10
  syscall
