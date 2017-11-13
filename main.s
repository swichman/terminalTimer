.global main
.text
.set noreorder

.set BASE1, 0xBF80
.set BASE2, 0xBF88
.set UMODE, 0x6000
.set USTA, 0x6010
.set UTX, 0x6020
.set URX, 0x6030
.set BRG, 0x6040
.set INTSTAT, 0x1010
.set INTCON, 0x1000
.set IEC0, 0x1060
.set IFS0, 0x1030
.set IFS1, 0x1040
.set IPC6, 0x10F0
.set RTCCON, 0x0200
.set RTCCONSET, 0x0208
.set RTCALRM, 0x0210
.set RTCTIME, 0x0220
.set RTCDATE, 0x0230
.set ALRMTIME, 0x0240
.set ALRMDATE, 0x0250
.set SYSKEY, 0xF230

.ent main

main:
	lui $t0, BASE0
	lui $t1, BASE2
	li $s0, 0xA0000200
	li $t9, 0x1000
	sw $t9, INTCON($t1)
	li $t9, 0xD
	sw $t9, IPC6($t1)
	li $t9, 0x18000000
	sw $t9, IEC0($t1)
	sw $zero, IFS0($t1)
	sw $zero, IFS1($t1)
	nop
	lui $t0, BASE1
	li $t9, 0x8B00
	sw $t9, UMODE($t0)
	li $t9, 0x1400
	sw $t9, USTA($t0)
	li $t9, 0xF							#38400 baud
	sw $t9, BRG($t0)
	nop
	li $t7, 0xAA996655
	li $t8, 0x556699AA
	li $t9, 0x8
	sw $t7, SYSKEY($t0)
	sw $t8, SYSKEY($t0)
	sw $t9, RTCCON($t0)
	li $t9, 0x80C1
	sw $t9, RTCCONSET($t0)
	nop
	
	li $t9, 0x401						# init status register
	mtc0 $t9, $12, 0					# store in status register
	ei
	nop
	b loop
	nop
	
.end main	

	
loop:
	lw $t8, RTCTIME($t0)
	sw $t8, 0x0($s0)
	
write_time:
	lb $t8, 0x0($s0)
	sw $t8, UTX($t0)
	addi $s0, $s0, 1
	bne $s0, 0xA0000204, write_time
	nop
	li $s0, 0xA0000200
	b loop
	nop
	