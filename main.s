.global main
.text
.set noreorder

.set T1BASE, 0xBF80
.set T1CONCLR, 0x0604
.set T1CONSET, 0x0608
.set T1CONINV, 0x060C
.set TMR1SET, 0x0618
.set IFS0, 0x81030
.set IEC0, 0x81060
.set PORTB, 0x86050
.set LATB, 0x86060
.set LEDS, 0x3C00


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
.ent main

main:
	li $s0, 0xA0000400
	li $t3, 0xA0000228					# base time address	
	nop
	li $t9, 0x30
	sw $t9, 0x0($t3)					# zero time
	sw $t9, 0x4($t3)
	sw $t9, 0x8($t3)
	sw $t9, 0xC($t3)
	nop
	lui $t1, T1BASE						# base address for TMR1 on $t1
	sw $zero, 0x0600($t1)				# zero T1CON
	li $t9, 0x0030
	sw $t9, T1CONSET($t1)
	nop
	li $t9, 0xC0						# load buttons to $t9
	sw $t9, 0x86000($t1)				# store input through TRISA
	nop
	li $t9, 0x8B00						# enable UART 8-bit, no parity, 1 stop bit
	sw $t9, UMODE($t1)					# store to UART MODE
	li $t9, 0x1400						# set RXEN TXEN
	sw $t9, USTA($t1)					# store to UART STATUS
	li $t9, 0x20						# 19200 baud
	sw $t9, UBRG($t1)					# store to BRG
	nop
	li $t9, 0x1000						# MVEC
	sw $t9, 0x81000($t1)				# activated!
	li $t9, 0xD							# priority 3
	sw $t9, 0x810A0($t1)				# assign priority in IPC1 (timer)
	sw $t9, 0x81110($t1)				# assign priority in IPC8 (uart2)
	sw $t9, 0x810F0($t1)				# assign priority in IPC6 (uart1)	
	li $t9, 0x10						# bit 4 (T1) on
	sw $t9, IEC0($t1)					# store to IEC0 (enable)
	
	#li $t9, 0x600						# bit 9-10 (U2RX U2TX)
	li $t9, 0x18000010					# bit 27-28 (U1RX U1TX)
	#sw $t9, 0x81070($t1)				# store to IEC1 (enable) (UART2)
	sw $t9, IEC0($t1)					# store to IEC0 (enable) (UART1)
	
	sw $zero, 0x81030($t1)				# clear flags in IFS0
	sw $zero, 0x81040($t1)				# clear flags in IFS1
	nop
	li $t9, 0x401						# init status register
	mtc0 $t9, $12, 0					# store in status register
	nop
	ei									# enable interrupts
	nop

.end main

clear:
	la $t9, prompt
	jr $t9
	nop


.global draw
.set noreorder
.ent draw

draw:

	nop
/* drawing the screen for 80x23 terminal */
draw_init:
	#start timer at (10, 36) ESC[r;cH	0x1b 0x5b 0x31 0x30 0x3b 0x33 0x36 0x48
	#									ESC	  [    1    0    ;    3    6    H
	li $t2, 0xA0000220
	li $t9, 0x30315b1b
	sw $t9, 0x0($t2)
	li $t9, 0x4836333b
	sw $t9, 0x4($t2)
	li $t8, 8

	nop
		
move_cursor:
	lb $t9, 0($t2)
	sw $t9, UTX($t1)
	bal forever_alone
	nop
	addi $t8, $t8, -1
	addi $t2, $t2, 1
	bne $t8, $zero, move_cursor
	nop
	
write_time:
	li $t8, 0xA0000240
	lw $t9, 0x0($t3)
	sw $t9, UTX($t1)
	sb $t9, 0x0($t8)
	bal forever_alone
	nop
	nop
	lw $t9, 0x4($t3)
	sw $t9, UTX($t1)
	sb $t9, 0x1($t8)
	bal forever_alone
	nop
	nop
	li $t9, 0x3a
	sw $t9, UTX($t1)
	bal forever_alone
	nop
	nop
	lw $t9, 0x8($t3)
	sw $t9, UTX($t1)
	sb $t9, 0x2($t8)
	bal forever_alone
	nop
	nop
	lw $t9, 0xC($t3)
	sw $t9, UTX($t1)
	sb $t9, 0x3($t8)
	addi $t9, $t9, -1
	sw $t9, 0xC($t3)
	bal forever_alone
	nop
	nop
#	lw $t9, 0x0($t8)
#	beq $t9, 0x30303030, alarm
	nop
	
draw_check:
	
.end draw
	
check:
	lw $t9, 0x86010($t1)				# retrieve raw button data
	nop
	andi $t9, $t9, 0x40					# look for speed control button
	bgtz $t9, set_timer_10x
	nop
	
	
set_timer_1x:
	li $t9, 39062					# (((80Mhz/8)/1)/1)
	sw $t9, 0x0620($t1)					#
	li $t9, 0x8000						#
	sw $t9, T1CONSET($t1)				#
	b forever_alone						#
	nop

set_timer_10x:
	li $t9, 3906						# (((80Mhz/8)/1)/1)/10
	sw $t9, 0x0620($t1)					#
	li $t9, 0x8000						#
	sw $t9, T1CONSET($t1)				#
	b forever_alone						#
	nop
	
forever_alone:
	b forever_alone						#
	nop
	b check
	nop
	