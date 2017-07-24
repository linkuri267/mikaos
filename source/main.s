.section .init
.globl _start
_start:

b main

.section .text
main:
	mov sp,#0x8000

	/*Width = 1024, Height = 768, 16 bits per pixel (high color)*/
	mov r0,#1024
	mov r1,#768
	mov r2,#16
	bl initializeFrameBuffer /*Returns pointer to draw in r0 if no error*/

	teq r0,#0
	bne noError$
	
	/*Turn on OK if GPU returns error*/
	mov r0, #16
	mov r1, #1
	bl setGpioFunc

	mov r0, #16
	mov r1, #0
	bl setGpio

	error$:
	b error$

	noError$:


	frameBufferInfoAddress .req r4
	mov frameBufferInfoAddress, r0 /*Pointer to write to screen */
	bl setGraphicsAddress


	/*Delay 1.5s*/
	ldr r0,=1500000
	bl timerWaitMs
	
	/*Print OS Name slowly*/
	ldr r0,=osName
	mov r1,#0
	mov r2,#0
	ldr r3,=250000
	bl drawStringDelay
	
	# mov r0,#-98
	# ldr r1,=testString
	# mov r2,#2
	# bl number2StringS
	
	# ldr r0,=testString
	# mov r1,#0
	# mov r2,#16
	# bl drawString
	
	ldr r0,=testString3
	push {r0}
	ldr r0,=testString
	ldr r1,=testString2
	mov r2,#1
	bl formatString
	add sp,#4
	
	ldr r0,=testString2
	mov r1,#0
	mov r2,#16
	bl drawString


	/*Delay 5s*/
	ldr r0,=5000000
	bl timerWaitMs

	/*Draw random lines with random color */
	lastRandomNum .req r5
	currentColor .req r6
	lastX .req r7
	lastY .req r8
	nextX .req r9
	nextY .req r10

	mov lastRandomNum,#0
	mov currentColor,#0
	mov lastX,#0
	mov lastY,#0
	
	drawRandomLoop$:
		mov r0,lastRandomNum
		bl random
		mov nextX,r0
		bl random
		mov nextY,r0
		mov lastRandomNum,nextY
		
		mov r0, currentColor
		bl setForeColor
		mov r0, lastRandomNum
		bl random
		lsr r0,#16
		mov currentColor, r0
		
		lsr nextX,#22
		lsr nextY,#22
		cmp nextY,#768
		bhs drawRandomLoop$
		mov r0, lastX
		mov r1, lastY
		mov r2, nextX
		mov r3, nextY
		mov lastX,nextX
		mov lastY,nextY
		
		bl drawLine
		b drawRandomLoop$
		
.section .data
	osName:
	.asciz "MikaOS v9.3"
	testString:
	.asciz "hellooooo%s"
	testString2:
	.word 0
	.word 0
	.word 0
	.word 0
	.word 0
	testString3:
	.asciz "test"
	numChar:
	.word 0
	numCharAscii:
	.word 0


	





