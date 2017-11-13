/*==========================================================================================
Rotating LED pattern. Write a routine that will demonstrate a rotating pattern using the 8
LEDs of the module in connector JA. Try to have the change occur every half of a second.
The initial direction should be right-to-left. Once the LEDs are rotating, have the two
buttons control the direction: push the left button, the pattern rotates right-to-left; push the
right button, the pattern rotates left-to-right.
===========================================================================================*/
.global alarm
.text
.set noreorder
.set UTX, 0x6020
.ent alarm

/* --------------------------------------------------------
	initializes registers and configures
	the PORT for operation.
-------------------------------------------------------- */
alarm:
	lui $s0,0xBF80
	li $t0,0xbf886100	#load address of TRISE into register $t0
						# adjust above to the proper port that the led is plugged into
	
	li $t1,0x000000FF	#initialized bitfield
	sw $zero, 0x0($t0)
	#sw $t1,0x000C($t0)	#store bitfield into TRISE inverted
	li $t1,0x00000008
	sw $t1,0x10($t0)
	lui $t1, 0xBF80
	#start timer at (10, 36) ESC[r;cH	0x1b 0x5b 0x31 0x30 0x3b 0x33 0x36 0x48
	#									ESC	  [    1    0    ;    3    6    H
	li $t2, 0xA0000200
	li $t9, 0x30315b1b
	sw $t9, 0x0($t2)
	li $t9, 0x4836333b
	sw $t9, 0x4($t2)
	li $t8, 8
	clear_:
	lb $t9, 0x0($t2)
	sw $t9, UTX($s0)
	bal wait_1
	nop
	nop
	nop
	addi $t8, $t8, -1 
	addi $t2, $t2, 1
	bne $t8, $zero, clear_
	nop
	nop
	la $t2, data_alarm
	nop
write_alarm:
	lb $t9, 0x0($t2)
	beq $t9, $zero, shift_left
	nop
	sb $t9, UTX($s0)
	bal wait_1
	nop
	nop
	addi $t2, $t2, 1
	b write_alarm
	nop


/* --------------------------------------------------------
	checks for button presses
-------------------------------------------------------- */
check:
	li $t9,0xbf886000	#load address of button locations

	lb $t5, 0x10($t9)
	and $t6,$t5,0x80
	bgtz $t6,shift_left
	nop
	and $t6,$t5,0x40
	bgtz $t6,shift_right
	nop
	beqz $t7,shift_left
	nop
	bgtz $t7, shift_right
	nop

	
/* --------------------------------------------------------
	this bitshifts left.
-------------------------------------------------------- */
shift_left:
	li $s4, 0x4000
	sw $s4, 0x8601C($s0)
	li $t3,0x00000000	#restart delay timer
	sll $t1,$t1,1		#shift register left
#	sw $t1,0x10($t0)	#store light left
	b left_check		#check if pattern is on board still
	li $t7,0x00000000

/* --------------------------------------------------------
	this bitshifts right.
-------------------------------------------------------- */
shift_right:

	li $t3,0x00000000	#restart delay timer
	srl $t1,$t1,1		#shift register left
#	sw $t1,0x10($t0)	#store light left
	b right_check		#check if pattern is on board still
	li $t7,0x00000001

/* --------------------------------------------------------
	keeps left bit shift in bounds of the program
-------------------------------------------------------- */
left_check:
	bne $t1,0x00100, delay	#pattern on board, send to delay
	nop
	beq $t1,0x00100, delay	#pattern off board
	li $t1, 0x00000001		#set pattern reset to far left and send to delay

/* --------------------------------------------------------
	keeps right bit shift in bounds of the program
-------------------------------------------------------- */
right_check:
	bne $t1,0x00, delay	#pattern on board, send to delay
	nop
	beq $t1,0x00100, delay	#pattern off board
	li $t1, 0x80		#set pattern reset to far left and send to delay

/* --------------------------------------------------------
	delays time between shifts
-------------------------------------------------------- */
delay:
	#li $s5, 0x20
	#li $t9,0xbf886000
	lw $s1, 0x86010($s0)
	andi $s1, $s1, 0x80
	bgtz $s1, restart
	nop
	sw $t1,0x10($t0)
	addi $t3,$t3,1				#arbitrary add counter
	slt $t4, $t3, 0x00000FFF	#check if t3 is less than FFFF
	beqz $t4, check		#resent to shift_left when t4 is not less than FFFF
	nop	
	b delay						#otherwise repeat delay loop
	nop
	#sw $s5, 0x1c ($t9)

.end alarm

restart:
	sw $zero, 0x10($t0)
	la $t1, main
	jr $t1
	nop
wait_1:
  	b wait_1
	nop
	
data_alarm:
	.asciiz "\x1b[5;31mALARM!\x1b[0m"
