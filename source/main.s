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
	
	bl setGraphicsAddress
	bl UsbInitialise
	
	reset$:

		mov sp,#0x8000
		bl terminalClear

		ldr r0,=welcome
		mov r1,#welcomeEnd-welcome
		bl print

	loop$:
		ldr r0,=prompt
		mov r1,#promptEnd-prompt
		bl print

		ldr r0,=command
		mov r1,#commandEnd-command
		bl readLine

		teq r0,#0
		beq loopContinue$

		mov r4,r0

		ldr r5,=command
		ldr r6,=commandTable

		ldr r7,[r6,#0]
		ldr r9,[r6,#4]
		commandLoop$:
			ldr r8,[r6,#8]
			sub r1,r8,r7

			cmp r1,r4
			bgt commandLoopContinue$

			mov r0,#0
			commandName$:
				ldrb r2,[r5,r0]
				ldrb r3,[r7,r0]
				teq r2,r3
				bne commandLoopContinue$
				add r0,#1
				teq r0,r1
				bne commandName$

			ldrb r2,[r5,r0]
			teq r2,#0
			teqne r2,#' '
			bne commandLoopContinue$

			mov r0,r5
			mov r1,r4
			mov lr,pc
			mov pc,r9
			b loopContinue$



		commandLoopContinue$:
		add r6,#8
		mov r7,r8
		ldr r9,[r6,#4]
		teq r9,#0
		bne commandLoop$

	ldr r0,=commandUnknown
	ldr r1,=formatBuffer
	ldr r3,=command
	push {r3}
	bl formatString

	mov r1,r0
	ldr r0,=formatBuffer
	bl print



	loopContinue$:
		bl terminalDisplay
		b loop$
	
	echo:
		cmp r1,#5
		movle pc,lr

		add r0,#5
		sub r1,#5 
		b print



	ok:
		teq r1,#5
		beq okOn$
		teq r1,#6
		beq okOff$
		mov pc,lr

		okOn$:
			ldrb r2,[r0,#3]
			teq r2,#'o'
			ldreqb r2,[r0,#4]
			teqeq r2,#'n'
			movne pc,lr
			mov r1,#0
			b okAct$
		okOff$:
			ldrb r2,[r0,#3]
			teq r2,#'o'
			ldreqb r2,[r0,#4]
			teqeq r2,#'f'
			ldreqb r2,[r0,#5]
			teqeq r2,#'f'
			movne pc,lr
			mov r1,#1



		okAct$:
			mov r0,#16
			b setGpio


	hug:
		ldr r0,=hug
		mov r1,#hugPromptEnd - hugPrompt
		b print



	drawRandom:
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
	.align 2
	welcome: .ascii "Welcome to MikaOS v9.3"
	welcomeEnd:
	.align 2
	prompt: .ascii "\n> "
	promptEnd:
	.align 2
	command:
	.rept 128
	.byte 0
	.endr
	commandEnd:
		.byte 0
		.align 2
		commandUnknown: .asciz "Command `%s' was not recognised.\n"
		commandUnknownEnd:
		.align 2
		formatBuffer:
	.rept 256
	.byte 0
	.endr
	formatEnd:
	.align 2
	commandStringEcho: .ascii "echo"
	commandStringReset: .ascii "reset"
	commandStringOk: .ascii "ok"
	commandStringCls: .ascii "cls"
	commandStringChangeTextColor: .ascii "changeTextColor"
	commandStringLight: .ascii "lightUpMyWorld"
	commandStringConnectFour: .ascii "connectFour"
	commandStringHug: .ascii "hug"
	commandStringDrawRandom: .ascii "drawRandom"
	commandStringEnd:

	.align 2
	commandTable:
	.int commandStringEcho, echo
	.int commandStringReset, reset$
	.int commandStringOk, ok
	.int commandStringCls, terminalClear
	.int commandStringChangeTextColor, changeTextColor
	.int commandStringLight, lightUpMyWorld
	.int commandStringConnectFour, connectFour
	.int commandStringHug, hug
	.int commandStringDrawRandom, drawRandom
	.int commandStringEnd, 0

	.align 2
	hugPrompt: .ascii "Stand up and close your eyes for 10 seconds\n"
	hugPromptEnd:






