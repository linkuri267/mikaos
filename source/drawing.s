.section .data
	.align 1
	foreColor:
	.hword 0xFFFF

	.align 2
	graphicsAddress:
	.int 0
	.align 4
	font:
	.incbin "font0.bin"
	
	
.section .text
	.globl setForeColor
	setForeColor:
		cmp r0,#0x10000
		movhs pc,lr
		ldr r1,=foreColor
		strh r0,[r1]
		mov pc,lr

	.globl setGraphicsAddress
	setGraphicsAddress:
		ldr r1,=graphicsAddress
		str r0,[r1]
		mov pc,lr
		
	
	/*
	*setPixel:Set pixel given by x:r0 y:r1 to value in foreColor
	*Inputs:
	*r0:x
	*r1:y
	*Output: None
	*/ 
	.globl setPixel
	setPixel:
		x .req r0
		y .req r1
		
		ldr r2,=graphicsAddress
		address .req r2
		ldr address, [address]
		
		ldr r3,[address,#4]
		height .req r3
		sub height,#1
		cmp y, height
		movhi pc,lr
		.unreq height
		
		ldr r3, [address,#0]
		width .req r3
		sub width,#1
		cmp x, width
		movhi pc, lr
		
		ldr address, [address,#32] /*Now pointer to draw */
		add width,#1
		/*
		*0,0->XXXXX  every X takes up 2 addresses 
		* 	  XXXXX<-(4,1) (1*5 + 4)*2 = 18 offset
		*0,2->XXXXX (2*5+0)*2=20 offset
		*	  XXXXX
		*/
		mul y,width 
		add x,y
		.unreq width
		.unreq y
		add address,x,lsl #1
		.unreq x
		
		ldr r3,=foreColor
		fore .req r3
		ldr fore, [fore]
		
		strh fore,[address]
		
		.unreq fore
		.unreq address
		mov pc,lr
	
	/*
	*drawLine:Draws a line from (r0,r1) to (r2,r3)
	*Inputs:
	*r0:x0
	*r1:y0
	*r2:x1
	*r3:y1
	*Output: None
	*/
	.globl drawLine
	drawLine:
		push {r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}
		x0 .req r9
		x1 .req r10
		y0 .req r11
		y1 .req r12
		
		mov x0,r0
		mov x1,r2
		mov y0,r1
		mov y1,r3
		
		deltax .req r4
		ndeltay .req r5
		stepx .req r6
		stepy .req r7
		err .req r8
		
		cmp x0,x1
		subgt deltax,x0,x1
		movgt stepx,#-1
		suble deltax,x1,x0
		movle stepx,#1
		
		cmp y0,y1
		subgt ndeltay,y1,y0
		movgt stepy,#-1
		suble ndeltay,y0,y1
		movle stepy,#1
		
		add x1,stepx
		add y1,stepy
		add err,deltax,ndeltay
		drawLoop$:
			teq x1,x0
			teqne y1,y0
			beq exitDraw$ 
			/*Draw*/
			mov r0,x0
			mov r1,y0
			bl setPixel
			
			cmp ndeltay, err,lsl #1
			addle err,ndeltay
			addle x0,stepx
			
			cmp deltax, err,lsl #1
			addge err,deltax
			addge y0,stepy
			
			b drawLoop$

		exitDraw$:
		
		.unreq x0
		.unreq x1
		.unreq y0
		.unreq y1
		.unreq deltax
		.unreq ndeltay
		.unreq stepx
		.unreq stepy
		.unreq err
		pop {r4,r5,r6,r7,r8,r9,r10,r11,r12,pc}
		
	/*
	*drawCharacter:Draw character r0 in x:r1 y:r2
	*Inputs:
	*r0:Character code
	*r1:x
	*r2:y
	*Output: 
	*r0:width
	*r1:height
	*/
	.globl drawCharacter
	drawCharacter:
		x .req r4
		y .req r5
		characterAddress .req r6
		push {r4,r5,r6,r7,r8,lr}
		
		mov x,r1
		mov y,r2
		
		cmp r0,#127
		movhi pc,lr 
		
		ldr characterAddress,=font
		add characterAddress,r0, lsl #4

		drawCharacterLoop$:
			bits .req r7
			bit .req r8
			ldrb bits,[characterAddress]
			mov bit,#8
			drawCharacterPixel$:
				subs bit,#1
				blt drawPixelExit$
				lsl bits, #1
				tst bits,#0x100
				beq drawCharacterPixel$
				
				add r0,x,bit
				mov r1,y
				bl setPixel
				teq bit,#0
				bne drawCharacterPixel$
			drawPixelExit$:
			add y,#1
			add characterAddress,#1
			tst characterAddress,#0b1111
			bne drawCharacterLoop$
		
		width .req r0
		height .req r1
		mov width,#8
		mov height,#16
		
		.unreq bits
		.unreq bit 
		.unreq x
		.unreq y
		.unreq characterAddress
		.unreq width
		.unreq height
		pop {r4,r5,r6,r7,r8,pc}
		
	/*
	*drawString:Draw C style string in r0 starting at (r1,r2)
	*Inputs:
	*r0:string
	*r1:x
	*r2:y
	*Output: None
	*/
	.globl drawString
	drawString:

		string .req r4
		x .req r5
		y .req r6
		x0 .req r7
		x1 .req r8
		charWidth .req r9
		charHeight .req r10
		character .req r11
		
		push {r4,r5,r6,r7,r8,r9,r10,r11,lr}
		mov string,r0
		mov x,r1
		mov y,r2
		
		mov x0,x 
		
		drawStringLoop$:
			ldrb character,[string]
			cmp character,#0
			beq nullTerminate$
			
			mov r0,character
			mov r1,x
			mov r2,y
			bl drawCharacter
			mov charWidth,r0
			mov charHeight,r1
			
			/*if (character == LF)*/
			teq character,#0xA 
			moveq x,x0
			addeq y,charHeight
			beq nextChar$
			
			/*if (character == HT)*/
			teq character,#0x9
			bne noHTLF$
			mov x1,x0
			add charWidth,charWidth,lsl #2
			htLoop$:
				cmp x1,x
				addls x1,charWidth
				ble htLoop$
			mov x,x1
			b nextChar$
			
			/*Else*/
			noHTLF$:
			add x,charWidth
			
			nextChar$:
			add string,#1

			b drawStringLoop$
		
		
		nullTerminate$:
		
		.unreq string
		.unreq x
		.unreq x1
		.unreq x0
		.unreq y
		.unreq charHeight
		.unreq charWidth
		.unreq character

		pop {r4,r5,r6,r7,r8,r9,r10,r11,pc}
		
	/*
	*drawStringDelay:Draw C style string in r0 starting at (r1,r2) with r3 (ms) delay between each character
	*Inputs:
	*r0:string
	*r1:x
	*r2:y
	*r3:delay
	*Output: None
	*/
	.globl drawStringDelay
	drawStringDelay:

		string .req r4
		x .req r5
		y .req r6
		x0 .req r7
		x1 .req r8
		charWidth .req r9
		charHeight .req r10
		character .req r11
		delay .req r12
		
		push {r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}
		mov string,r0
		mov x,r1
		mov y,r2
		mov delay,r3
		
		mov x0,x 
		
		drawStringLoopDelay$:
			ldrb character,[string]
			cmp character,#0
			beq nullTerminateDelay$
			
			/*Delay*/
			mov r0,delay
			bl timerWaitMs
			
			mov r0,character
			mov r1,x
			mov r2,y
			bl drawCharacter
			mov charWidth,r0
			mov charHeight,r1
			
			/*if (character == LF)*/
			teq character,#0xA 
			moveq x,x0
			addeq y,charHeight
			beq nextChar$
			
			/*if (character == HT)*/
			teq character,#0x9
			bne noHTLFDelay$
			mov x1,x0
			add charWidth,charWidth,lsl #2
			htLoopDelay$:
				cmp x1,x
				addls x1,charWidth
				ble htLoopDelay$
			mov x,x1
			b nextCharDelay$
			
			/*Else*/
			noHTLFDelay$:
			add x,charWidth
			
			nextCharDelay$:
			add string,#1

			b drawStringLoopDelay$
		
		
		nullTerminateDelay$:
		
		.unreq string
		.unreq x
		.unreq x1
		.unreq x0
		.unreq y
		.unreq charHeight
		.unreq charWidth
		.unreq character
		.unreq delay

		pop {r4,r5,r6,r7,r8,r9,r10,r11,r12,pc}
		
			
			

		