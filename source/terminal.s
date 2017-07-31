.section .data
	.align 4
	terminalStart:
	.int terminalBuffer
	terminalStop:
	.int terminalBuffer
	terminalView:
	.int terminalBuffer
	terminalColour:
	.byte 0x0D
	.align 8
	terminalBuffer:
	.rept 128*128
	.byte 0x7f
	.byte 0x0
	.endr
	terminalScreen:
	.rept 1024/8 * 768/16
	.byte 0x7f
	.byte 0x0
	.endr
	colorChangePrompt:
	.asciz "Choose Color:\n1:Blue\n2:Green\n3:Cyan\n4:Red\n5:Magenta\n6:Brown\n7:Light Grey\n8:Grey\n9:Light Blue\nA:Light Green\nB:Light Cyan\nC:Light Red\nD:Light Magenta\nE:Yellow\nF:White\n"
	colorBuffer:
	.byte 0
	
.section .text
	
	/*
	*terminalColor:Converts 4 bit color number to 16 bit high color and calls setForeColor
	*Input:
	*r0:colorNumber (4 bit)
	*Output:None
	*/	
		
	.globl terminalColor
	terminalColor:
		
		colorNumber .req r4
		sixteenBitColor .req r5
		
		push {r4,r5,lr}
		mov colorNumber,r0
		mov sixteenBitColor,#0
		
		teq colorNumber,#6
		ldreq sixteenBitColor,=0b0000001010110101
		beq doneConvert$
		
		tst colorNumber,#0b1000
		ldrne sixteenBitColor,=0b0101001010101010
		
		tst colorNumber,#0b0100
		addne sixteenBitColor,#0b1010100000000000
		
		tst colorNumber,#0b0010
		addne sixteenBitColor,#0b0000010101000000
		
		tst colorNumber,#0b0001
		addne sixteenBitColor,#0b0000000000010101
		
		doneConvert$:
		mov r0,sixteenBitColor
		bl setForeColor
		
		pop {r4,r5,pc}
		.unreq colorNumber
		.unreq sixteenBitColor
		
		
	/*
	*terminalDisplay:Copies data from terminalBuffer to terminalScreen and actual screen
	*Input:None
	*Output:None
	*/	
		
	.globl terminalDisplay
	terminalDisplay:

		x .req r4
		y .req r5
		char .req r6
		col .req r7
		screen .req r8
		taddr .req r9
		view .req r10
		stop .req r11

		push {r4,r5,r6,r7,r8,r9,r10,r11,lr}

		
		
		ldr taddr,=terminalStart
		ldr view,[taddr,#terminalView - terminalStart]
		ldr stop,[taddr,#terminalStop - terminalStart]
		add taddr,#terminalBuffer - terminalStart
		add taddr,#128*128*2 
		mov screen,taddr

		mov y,#0
		rowLoop$:
			mov x,#0
			columnLoop$:
				teq view,stop
				ldrneh char,[view]
				moveq char,#0x007f
				ldrh col,[screen]
				teq col,char
				beq screenViewEqual$
				
				strh char,[screen]
				lsr col,char,#8
				and char,#0x7F
				
				lsr r0,col,#4
				bl terminalColor
				
				mov r0,#0x7f
				mov r1,x
				mov r2,y
				bl drawCharacter
				
				and r0,col,#0b0000000000001111
				bl terminalColor
				
				mov r0,char
				mov r1,x
				mov r2,y
				bl drawCharacter
				
				screenViewEqual$:
					add screen,#2
					
					teq view,stop
					addne view,#2
					
					teq view,taddr
					subeq view,#128*128*2
					
					add x,#8
					teq x,#1024
					bne columnLoop$
			add y,#16
			teq y,#768
			bne rowLoop$
		
		.unreq x
		.unreq y
		.unreq char
		.unreq col
		.unreq screen
		.unreq taddr
		.unreq view
		.unreq stop
		
		pop {r4,r5,r6,r7,r8,r9,r10,r11,pc}

	/*
	*terminalClear:clear display
	*Input:None
	*Output:None
	*/		
	.globl terminalClear
	terminalClear:
		ldr r0,=terminalStart
		add r1,r0,#terminalBuffer-terminalStart
		str r1,[r0]
		str r1,[r0,#terminalStop-terminalStart]	
		str r1,[r0,#terminalView-terminalStart]	
		mov pc,lr
		
	/*
	*print
	*Input:
	*r0:stringAddress
	*r1:length
	*Output:None
	*/		
	.globl print
	print:
		teq r1,#0
		moveq pc,lr

		push {r4,r5,r6,r7,r8,r9,r10,r11,lr}
		bufferStart .req r4
		taddr .req r5
		x .req r6
		string .req r7
		length .req r8
		char .req r9
		bufferStop .req r10
		view .req r11

		mov string,r0
		mov length,r1

		ldr taddr,=terminalStart
		ldr bufferStop,[taddr,#terminalStop-terminalStart]
		ldr view,[taddr,#terminalView-terminalStart]
		ldr bufferStart,[taddr]
		add taddr,#terminalBuffer-terminalStart
		add taddr,#128*128*2
		and x,bufferStop,#0xfe
		lsr x,#1
		
		charLoop$:
			ldrb char,[string]
			and char,#0x7f
			teq char,#'\n'
			bne charNormal$

			mov r0,#0x7f
			clearLine$:
				strh r0,[bufferStop]
				add bufferStop,#2
				add x,#1
				cmp x,#128
				blt clearLine$

			b charLoopContinue$

		charNormal$:
			strb char,[bufferStop]
			ldr r0,=terminalColour
			ldrb r0,[r0]
			strb r0,[bufferStop,#1]
			add bufferStop,#2
			add x,#1
			
		charLoopContinue$:
			cmp x,#128
			blt noScroll$

			mov x,#0
			subs r0,bufferStop,view
			addlt r0,#128*128*2
			cmp r0,#128*(768/16)*2
			addge view,#128*2
			teq view,taddr
			subeq view,taddr,#128*128*2

		noScroll$:
			teq bufferStop,taddr
			subeq bufferStop,taddr,#128*128*2

			teq bufferStop,bufferStart
			addeq bufferStart,#128*2
			teq bufferStart,taddr
			subeq bufferStart,taddr,#128*128*2

			subs length,#1
			add string,#1
			bgt charLoop$

		charLoopBreak$:
		
		sub taddr,#128*128*2
		sub taddr,#terminalBuffer-terminalStart
		str bufferStop,[taddr,#terminalStop-terminalStart]
		str view,[taddr,#terminalView-terminalStart]
		str bufferStart,[taddr]

		pop {r4,r5,r6,r7,r8,r9,r10,r11,pc}
		.unreq bufferStart 
		.unreq taddr 
		.unreq x 
		.unreq string
		.unreq length
		.unreq char
		.unreq bufferStop
		.unreq view
		
	/*
	*readLine
	*Input:
	*r0:targetLocation
	*r1:maxLength
	*Output:
	*r0:readLength
	*/		
	.globl readLine
	readLine:
		teq r1,#0
		moveq r0,#0
		moveq pc,lr

		string .req r4
		maxLength .req r5
		input .req r6
		taddr .req r7
		length .req r8
		view .req r9

		push {r4,r5,r6,r7,r8,r9,lr}

		mov string,r0
		mov maxLength,r1
		ldr taddr,=terminalStart
		ldr input,[taddr,#terminalStop-terminalStart]
		ldr view,[taddr,#terminalView-terminalStart]
		mov length,#0

		cmp maxLength,#128*64
		movhi maxLength,#128*64
		sub maxLength,#1
		mov r0,#'_'
		strb r0,[string,length]

		readLoop$:		
			str input,[taddr,#terminalStop-terminalStart]
			str view,[taddr,#terminalView-terminalStart]

			mov r0,string
			mov r1,length
			add r1,#1
			bl print
			bl terminalDisplay		
			bl keyboardUpdate
			bl keyboardGetChar
			
			teq r0,#'\n'	
			beq readLoopBreak$
			teq r0,#0
			beq cursor$
			teq r0,#'\b'
			bne standard$

		delete$:
			cmp length,#0
			subgt length,#1
			b cursor$
		
		standard$:	
			cmp length,maxLength
			bge cursor$

			strb r0,[string,length]
			add length,#1
					
		cursor$:
			ldrb r0,[string,length]
			teq r0,#'_'
			moveq r0,#' '
			movne r0,#'_'
			strb r0,[string,length]
					
			b readLoop$
		readLoopBreak$:
		
		mov r0,#'\n'
		strb r0,[string,length]

		str input,[taddr,#terminalStop-terminalStart]
		str view,[taddr,#terminalView-terminalStart]
		mov r0,string
		mov r1,length
		add r1,#1
		bl print
		bl terminalDisplay
		
		mov r0,#0
		strb r0,[string,length]

		mov r0,length
		pop {r4,r5,r6,r7,r8,r9,pc}
		.unreq string
		.unreq maxLength
		.unreq input
		.unreq taddr
		.unreq length
		.unreq view
		


	/*Change text color*/		
	.globl changeTextColor
	changeTextColor:
		push {lr}
		ldr r0,=colorChangePrompt
		mov r1,#colorBuffer-colorChangePrompt
		bl print
		
		ldr r0,=colorBuffer
		mov r1,#2
		bl readLine
		
		ldr r0,=colorBuffer
		ldrb r0,[r0]
		
		cmp r0,#0x39
		subls r0,#0x30
		bls doneAsciiConvert$
		
		cmp r0,#46
		subls r0,#0x37
		bls doneAsciiConvert$
		
		sub r0,#0x57
		doneAsciiConvert$:
		
		ldr r1,=terminalColour
		ldr r1,[r1]
		and r1,#0xF0
		and r0,#0x0F
		orr r0,r1
		
		ldr r1,=terminalColour
		
		strb r0,[r1]
		pop {pc}
