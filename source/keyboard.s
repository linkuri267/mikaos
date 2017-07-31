.section .data
.align 3
	keysNormal: 
	.byte 0x0, 0x0, 0x0, 0x0, 'a', 'b', 'c', 'd'
	.byte 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l'
	.byte 'm', 'n', 'o', 'p', 'q', 'r', 's', 't'
	.byte 'u', 'v', 'w', 'x', 'y', 'z', '1', '2'
	.byte '3', '4', '5', '6', '7', '8', '9', '0'
	.byte '\n', 0x0, '\b', '\t', ' ', '-', '=', '['
	.byte ']', '\\', '#', ';', '\'', '`', ',', '.'
	.byte '/', 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0
	.byte 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0
	.byte 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0
	.byte 0x0, 0x0, 0x0, 0x0, '/', '*', '-', '+'
	.byte '\n', '1', '2', '3', '4', '5', '6', '7'
	.byte '8', '9', '0', '.', '\\', 0x0, 0x0, '='



	.align 3
	keysShift: 
	.byte 0x0, 0x0, 0x0, 0x0, 'A', 'B', 'C', 'D'
	.byte 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'
	.byte 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T'
	.byte 'U', 'V', 'W', 'X', 'Y', 'Z', '!', '"'
	.byte 0x0, '$', '%', '^', '&', '*', '(', ')'
	.byte '\n', 0x0, '\b', '\t', ' ', '_', '+', '{'
	.byte '}', '|', '~', ':', '@', 0x0, '<', '>'
	.byte '?', 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0
	.byte 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0
	.byte 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0
	.byte 0x0, 0x0, 0x0, 0x0, '/', '*', '-', '+'
	.byte '\n', '1', '2', '3', '4', '5', '6', '7'
	.byte '8', '9', '0', '.', '|', 0x0, 0x0, '='


	.align 2
	keyboardAddress:
	.int 0
	keyboardOldDown:
	.rept 6
	.hword 0
	.endr

.section .text
	/*
	*keyboardUpdate:Finds new keyboards, stores address in keyboardAddress and saves keys pressed down into keyboardOldDown ending with a 0 if keyCount != 6
	*Input:None
	*Output:
	*r0:return code
	*/	
	.globl keyboardUpdate
	keyboardUpdate:
		push {r4,r5,r6,lr}
		
		ldr r0,=keyboardAddress
		keyboardAddr .req r4
		ldr keyboardAddr, [r0]
		teq keyboardAddr,#0
		bne haveKeyboard$
		
		findKeyboards$:
		bl UsbCheckForChange
		bl KeyboardCount
		teq r0,#0 
		ldreq r1,=keyboardAddress
		streq r0,[r1]
		popeq {r4,r5,r6,pc}

		mov r0,#0
		bl KeyboardGetAddress
		ldr r1,=keyboardAddress
		str r0,[r1]

		teq r0,#0
		popeq {r4,r5,r6,pc}

		mov keyboardAddr,r0
		
		haveKeyboard$:
		keyNum .req r5
		mov keyNum,#0

		savedKeysAddr .req r6
		saveKeys$:
			mov r0,keyboardAddr
			mov r1,keyNum
			bl KeyboardGetKeyDown
			
			ldr savedKeysAddr,=keyboardOldDown
			add savedKeysAddr,keyNum, lsl #1
			strh r0,[savedKeysAddr]
			add keyNum,#1
			cmp keyNum,#6
			blt saveKeys$
			
		mov r0,keyboardAddr
		bl KeyboardPoll

		teq r0,#0
		bne findKeyboards$
		
		.unreq savedKeysAddr
		.unreq keyNum
		.unreq keyboardAddr
		pop {r4,r5,r6,pc}

	/*
	*keyWasDown:Returns 0 if given scan code is not in keyboardOldDown, non zero otherwise
	*Input:
	*r0:scanCode
	*Output:
	*r0:0 or 1
	*/	
	.globl keyWasDown
	keyWasDown:
		oldKey .req r4
		scanCode .req r5
		oldKeyAddr .req r6
		keyNum .req r7
		
		push {r4,r5,r6,r7}
		mov scanCode,r0
		mov keyNum,#0
		
		ldr oldKeyAddr,=keyboardOldDown
		checkOld$:
			ldrh oldKey,[oldKeyAddr]
			add oldKeyAddr,#2
			teq scanCode,oldKey
			moveq r0,#1
			beq returnKeyWasDown$
			add keyNum,#1
			cmp keyNum,#6
			blt checkOld$
		
		mov r0,#0
		returnKeyWasDown$:
		.unreq oldKey
		.unreq scanCode
		.unreq oldKeyAddr
		.unreq keyNum
		pop {r4,r5,r6,r7}
		mov pc,lr
	/*
	*keyboardGetChar:Gets ASCII of a key that has been pressed and released
	*Input:None
	*Output:
	*r0:ASCII code of key
	*/
	.globl keyboardGetChar
	keyboardGetChar:

		ldr r0,=keyboardAddress
		ldr r1,[r0]
		teq r1,#0
		moveq r0,#0
		moveq pc,lr
		
		push {r4,r5,r6,lr}
		keyboardAddr .req r4
		keyNum .req r5
		scanCode .req r6
		
		mov keyboardAddr,r1
		mov keyNum,#0
		
		keyLoop$:
			mov r0,keyboardAddr
			mov r1,keyNum
			bl KeyboardGetKeyDown 
			teq r0,#0
			beq keyLoopBreak$
			mov scanCode,r0
			bl keyWasDown
			teq r0,#0
			bne keyLoopContinue$
			cmp scanCode,#104
			bge keyLoopContinue$
			mov r0,keyboardAddr
			bl KeyboardGetModifiers
			tst r0,#0b00100010
			ldreq r0,=keysNormal
			ldrne r0,=keysShift
			ldrb r0,[r0,scanCode]
			teq r0,#0
			bne keyboardGetCharReturn$
			keyLoopContinue$:
			add keyNum,#1
			cmp keyNum,#6
			blt keyLoop$
			
		keyLoopBreak$:
		mov r0,#0
		keyboardGetCharReturn$:
		pop {r4,r5,r6,pc}
		.unreq keyboardAddr
		.unreq scanCode
		.unreq keyNum