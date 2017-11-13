.global prompt
.set noreorder
.text

.set UMODE, 0x6000
.set USTA, 0x6010
.set UTX, 0x6020
.set URX, 0x6030
.set UBRG, 0x6040
/*
.set UMODE, 0x6200
.set USTA, 0x6210
.set UTX, 0x6220
.set URX, 0x6230
.set UBRG, 0x6240
*/
.ent prompt

prompt:
	bal clear
	nop
	nop
	#move cursor to 0,0		0x1b 0x5b 0x3f 0x36 0x68
	#						ESC	 [	  ?	   6	h
	li $t2, 0xA0000220
	li $t9, 0x363f5b1b
	sw $t9, 0x0($t2)
	li $t9, 0x68
	sw $t9, 0x4($t2)
	li $t8, 5
	sw $zero, UTX($t1)
	
move_cursor_origin:	
	lb $t9, 0($t2)
	sw $t9, UTX($t1)
	bal wait_
	nop
	nop
	addi $t2, $t2, 1
	addi $t8, $t8, -1
	bne $t8, $zero, move_cursor_origin
	nop
	
prompt_load:
	#beq $t7, 0x1, prompt_bad
	nop
	la $t2, data_good
	b prompt_loop
	nop
prompt_bad:
	la $t2, data_bad
	li $s0, 0xA0000400
	sw $zero, 0x0($s0)
	b prompt_loop
	nop
	
prompt_loop:
	lb $t9, 0x0($t2)
	beq $t9, $zero, reply_init
	nop
	sb $t9, UTX($t1)
	bal wait_
	nop
	nop
	addi $t2, $t2, 1
	b prompt_loop
	nop
	
reply_init:
	li $t9, 0xd
	sw $t9, UTX($t1)
	li $t9, 0xa
	sw $t9, UTX($t1)
	sb $zero, 0x0($s0)
	
reply:
	bal wait_
	nop
	nop
	lb $t9, 0x0($s0)
	addi $t9, $t9, -13
	addi $s0, $s0, 1	
	bne $t9, $zero, reply
	nop
	#li $s0, 0xA0000400

load_time:
	addi $s0, $s0, -2
	lb $t9, 0x0($s0)
	bal load_check
	nop
	sw $t9, 0xC($t3)
	addi $s0, $s0, -1
	lb $t9, 0x0($s0)
	bal load_check
	nop
	sw $t9, 0x8($t3)
	addi $s0, $s0, -2
	lb $t9, 0x0($s0)
	bal load_check
	nop
	sw $t9, 0x4($t3)
	addi $s0, $s0, -1
	lb $t9, 0x0($s0)
	bal load_check
	nop
	sw $t9, 0x0($t3)
	bal clear
	nop
	nop
	la $t9, draw
	jr $t9
	nop
	nop
	
load_check:
	add $t6, $t9, 0
	div $t6,16
	mflo $t6
	bne $t6, 3, bad_check
	nop 
	jr $ra
	nop
	
	
bad_check:
	b prompt_bad
	#li $t7, 0x1
	nop
	
wait_:
  	b wait_
	nop
	
clear:
	#clear the terminal screen 			0x1b 0x5b 0x32 0x4a 
	#									ESC	  [    2    J  
	#sw $zero, UTX($t1)
	li $t2, 0xA0000220
	sw $ra, 0x0($t2)
	lw $t7, 0x0($t2)
	li $t9, 0x4a325b1b
	sw $t9, 0x0($t2)
	li $t8, 4
	sw $zero, UTX($t1)
	
clear_:
	lb $t9, 0x0($t2)
	sw $t9, UTX($t1)
	bal wait_
	nop
	nop
	nop
	addi $t8, $t8, -1 
	addi $t2, $t2, 1
	bne $t8, $zero, clear_
	nop 
	jr $t7
	nop
	
data_good:
	.asciz "\x1b[0mEnter alarm time in the format MM:SS"
data_bad:
	.asciz "\x1b[32;2mInvalid input, please input in the format MM:SS\x1b[0m"
.end prompt
