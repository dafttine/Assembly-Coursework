# Who:  Kristine Vo
# What: 4.asm
#       encryption.txt
#       decryption.txt
#       source.txt
#       passphrase is 'baby'
# Why:  This programs requires that one takes a source file that will encrypt in a user-given destination as a separate file. 
#       This file can only be decrypted given a user-generated password. 
# When: Created: May 2, 2019, Due: May 5, 2019
# How:  $a0-a2  (for the syscalls)
#       $v0-v1  ($v0 were the return values, used $v1 for the return value of how many bytes read)
#       $t0-$t2 (used strictly for XOR-ing bytes)
#       $s0-$s1 (save locations of buffers or descriptor)
#       10 registers, but if v and a registers are free, then 5 registers


.data
SRC_PATH_BUFFER:      .space 256
DEST_PATH_BUFFER:     .space 256
PASSPHRASE_BUFFER:    .space 257 
ENCRYPT_BUFFER:       .space 1024

SRC_PATH_PROMPT:      .asciiz "Enter the source path: " 
DEST_PATH_PROMPT:     .asciiz "Enter the destination path: "
PASSWORD_PROMPT:      .asciiz "Please enter in your password (you may need an MMIO Simulator if using MARS): "
newLine:              .asciiz "\n"
ERR_MESS:             .asciiz "\nThe passphrase may only be 256 characters long. Please try again.\n"
.align 2
.text
.globl main

main:
getString:
  #prompt for source path
  la $a0, SRC_PATH_PROMPT
  li $v0, 4
  syscall
  
  #src_filepath = getString(src_buffer)
  li $v0, 8
  la $a0, SRC_PATH_BUFFER
  li $a1, 256
  syscall
  
  la $s0, SRC_PATH_BUFFER
  jal NULL_TERM_SEARCH

  #prompt for destination path
  la $a0, DEST_PATH_PROMPT
  li $v0, 4
  syscall
  
  #dst_filepath = getString(dst_buffer)
  li $v0, 8
  la $a0, DEST_PATH_BUFFER
  li $a1, 256
  syscall
  
  la $s0, DEST_PATH_BUFFER
  jal NULL_TERM_SEARCH
  j getPassPhrase

NULL_TERM_SEARCH: #searches for \n and replaces with a null terminator, $s0 is the buffer
  lb $t1, 0($s0)
  lb $t2, newLine
  beq $t1, $t2, NULL_TERM
  addiu $s0, $s0, 1
  j NULL_TERM_SEARCH
  
NULL_TERM:
  sb $0, 0($s0)
  jr $ra
  
############################################################################################################
.data
   .eqv	SYS_PRINT_CHAR	        0xB
   .eqv	EXIT			0x0a #newLine
   .eqv ASTERISK                0x2a
  
    #read to an I/O device 
   .eqv	CONSOLE_RECEIVER_CONTROL           0xffff0000
   .eqv	CONSOLE_RECEIVER_READY_MASK        0x00000001
   #write to an I/O device
   .eqv	CONSOLE_RECEIVER_DATA              0xffff0004
    
   .text
    getPassPhrase:
     la $s0, PASSPHRASE_BUFFER
     li	$t1, EXIT
     li $s1, 0
     
     la $a0, PASSWORD_PROMPT
     li $v0, 4 
     syscall
     
     # Spin-wait for key to be pressed
    key_wait:
     lw      $t0, CONSOLE_RECEIVER_CONTROL
     andi    $t0, $t0, CONSOLE_RECEIVER_READY_MASK  # Isolate ready bit
     beqz    $t0, key_wait
     
     # Read in new character from keyboard to low byte of $a0
     lbu     $a0, CONSOLE_RECEIVER_DATA
     beq     $a0, $t1, exit
     sb      $a0, 0($s0)
     addiu   $s0, $s0, 1
     addiu   $s1, $s1, 1
     beq     $s1, 256, ERROR
   
     #Print asterisk
     la $a0, ASTERISK
     li $v0, SYS_PRINT_CHAR
     syscall
     	    
     b key_wait	    
  
    ERROR: #if the passphrase is too long, then we go back
     la $a0, ERR_MESS
     li $v0, 4
     syscall
     j getPassPhrase
     
    exit: #null terminates this buffer
     jal NULL_TERM
     
########################################################################################
.data
  .eqv OPEN_FILE   13
  .eqv READ_FILE   14
  .eqv WRITE_FILE  15

.text
  encryptFile:
    la $s0, PASSPHRASE_BUFFER
    
    li $v0, OPEN_FILE
    la $a0, DEST_PATH_BUFFER
    la $a1, 9
    la $a2, 0
    syscall 
    move $s2, $v0 # $s2 = descriptor for destination file path
    
    li $v0, OPEN_FILE
    la $a0, SRC_PATH_BUFFER
    la $a1, 0
    la $a2, 0
    syscall
    
    move $s1, $v0 # $s1 = descriptor for source file path
    la $a2, 1024
    
  read:
    #$a2 will initially = 1024, but after this, it can be 1024 if the file is long or less if it's the last buffer
    move $a0, $s1
    la $a1, ENCRYPT_BUFFER
    li $v0, READ_FILE
    syscall
    
    # when $v0 is returned as 0, that means we've reached the end
    beqz $v0, FIN
    
    #$v1 is the # of characters read used later to write into the encrypted file
    move $v1, $v0
    
  XOR_loop:
    #s0 is passphrase buffer
    #a1 is the Encrypted buffer
    #v0 = return value/# of characters read
    #t0 is what we are writing in the destination file
    #t1 is the byte in the to-be-encrypted buffer
    #t2 is the byte of the passphrase
    beqz $v0, WRITE_TO_FILE
    beq $t2, $0, RESET_PP_POSITION #when we hit the null terminator, we start at the beginning of the passphrase
    lb $t1, 0($a1)
    lb $t2, 0($s0)
    xor $t0, $t1, $t2
    sb $t0, 0($a1)
    addiu $a1, $a1, 1
    addiu $s0, $s0, 1
    subiu $v0, $v0, 1
    j XOR_loop

  RESET_PP_POSITION:
    la $s0, PASSPHRASE_BUFFER
    lb $t2, 0($s0)
    j XOR_loop
    
  WRITE_TO_FILE:     
    move $a0, $s2 #correct descriptor in argument
    li $v0, WRITE_FILE
    la $a1, ENCRYPT_BUFFER
    move $a2, $v1
    syscall
    j read
   
  FIN:
    #close off your files and end the program
    la $a0, DEST_PATH_BUFFER
    li $v0, 16
    syscall
    la $a0, SRC_PATH_BUFFER
    li $v0, 16
    syscall
    li $v0, 10
    syscall
