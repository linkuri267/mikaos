/*
*number2StringS:Convert signed number to string store in address r1
*Input:
*r0:value
*r1:destination
*r2:base
*r3:0 for no null terminator,non zero for null terminator
*Output: 
*r0:length without null terminator
*/

.globl number2StringS
number2StringS:

	value .req r0
	destination .req r1
	base .req r2
	null .req r3
	
	cmp value,#0
	blt signed$
	/*>=0 Case */
	push {lr}
	bl number2StringU
	pop {pc}
	
	signed$:
	cmp destination,#0
	ble destinationNegative$
	push {r4}
	mov r4,#'-'
	strb r4,[destination]
	pop {r4}
	add destination,#1
	
	destinationNegative$:
	mvn value,value
	add value,#1
	push {lr}
	bl number2StringU
	add r0,#1 /*Add 1 to length for '-'*/
	pop {pc}
	
	.unreq value
	.unreq destination
	.unreq base
	.unreq null

/*
*number2StringU:Convert unsigned number to string store in address r1
*Input:
*r0:value
*r1:destination
*r2:base
*r3:0 for no null terminator,non zero for null terminator
*Output: 
*r0:length excluding null terminator
*/

.globl number2StringU
number2StringU:
	push {r4,r5,r6,r7,r8,r9,lr}

	value .req r4
	destination .req r5
	base .req r6
	length .req r7
	remainder .req r8
	null .req r9
	
	mov value,r0
	mov destination,r1
	mov base,r2
	mov null,r3

	mov length,#0

	numberConvertLoop$:
		mov r0,value
		mov r1,base
		bl divideU32
		mov value,r0 
		mov remainder,r1 
		
		cmp remainder,#10
		subhs remainder,#10
		addhs remainder,#'a'
		addlo remainder,#'0'
		
		cmp destination,#0
		ble destinationNegative2$
		strb remainder,[destination,length]
		
		destinationNegative2$:
		add length,#1
		cmp value,#0
		bhi numberConvertLoop$	
		
	cmp destination,#0
	ble destinationNegative3$
	
	mov r0, destination
	mov r1, length
	bl reverseString
	

	destinationNegative3$:

	/*Append null terminator if null!=0*/
	teq null,#0
	beq noAppend$
	mov r1,#0
	strb r1,[destination,length]
	
	noAppend$:
	mov r0,length
	
	pop {r4,r5,r6,r7,r8,r9,pc}
	
	.unreq value
	.unreq destination
	.unreq base
	.unreq length
	.unreq remainder
	.unreq null
	
/*
*reverseString:Reverse string r0 of length r1
*Input:
*r0:string
*r1:length
*Output: None
*/
	.globl reverseString
	reverseString:
	
	push {r4}
	
	string .req r0
	length .req r1
	tmp1 .req r2
	tmp2 .req r3
	end .req r4
	
	sub length,#1
	add end,string,length
	
	reverseStringLoop$:
		cmp end,string
		bls finishReverse$
		ldrb tmp1, [string]
		ldrb tmp2, [end]
		strb tmp2, [string]
		strb tmp1, [end]
		add string,#1
		sub end,#1
		b reverseStringLoop$
	finishReverse$:
	
	.unreq string
	.unreq length
	.unreq tmp1
	.unreq tmp2
	.unreq end
	pop {r4}
	mov pc,lr
		
/*
*formatString
*Input:
*r0:formatStringAddress
*r1:destinationStringAddress
*r2:null
*stack:arguments
*Output:length
*/
	.globl formatString
	formatString:
	
	formatStringAddress .req r4
	destinationStringAddress .req r5
	argumentListAddress .req r6
	currentChar .req r7
	currentArgument .req r8
	length .req r9
	tmpChar .req r10
	null .req r11
	
	
	push {r4,r5,r6,r7,r8,r9,r10,r11,lr}
	mov formatStringAddress,r0
	mov destinationStringAddress,r1
	mov null,r2
	add argumentListAddress,sp,#36 /* 4*8 */

	mov length,#0
	
	formatLoop$:
		ldrb currentChar,[formatStringAddress]
		add formatStringAddress,#1
		
		/*Test if null*/
		teq currentChar,#0
		beq nullTerminate$
		
		/*Test if %*/
		teq currentChar,#'%'
		bne notFormat$ 
		ldrb currentChar,[formatStringAddress]
		add formatStringAddress,#1
		
			/*Test if %*/
			teq currentChar,#'%'
			bne notPercent$
			strb currentChar,[destinationStringAddress]
			add destinationStringAddress,#1
			add length,#1
			b formatLoop$
			notPercent$:
			
			/*Char:test if c*/
			teq currentChar,#'c'
			bne notChar$
			ldr currentArgument,[argumentListAddress]
			add argumentListAddress,#4
			strb currentArgument,[destinationStringAddress]
			add destinationStringAddress,#1
			add length,#1
			b formatLoop$
			notChar$:
			
			/*Base 10 signed:test if d or i*/
			teq currentChar,#'d'
			cmpne currentChar,#'i'
			bne notDecimal$
			ldr currentArgument,[argumentListAddress]
			add argumentListAddress,#4
			mov r0,currentArgument
			mov r1,destinationStringAddress
			mov r2,#10
			mov r3,#0
			bl number2StringS
			add destinationStringAddress,r0
			add length,r0
			b formatLoop$
			notDecimal$:
			
			/*Base 8 unsigned:test if o*/
			teq currentChar,#'o'
			bne notOctal$
			ldr currentArgument,[argumentListAddress]
			add argumentListAddress,#4
			mov r0,currentArgument
			mov r1,destinationStringAddress
			mov r2,#8
			mov r3,#0
			bl number2StringU
			add destinationStringAddress,r0
			add length,r0
			b formatLoop$
			notOctal$:
		
			/*Base 10 unsigned:test if u*/
			teq currentChar,#'u'
			bne notUnsigned$
			ldr currentArgument,[argumentListAddress]
			add argumentListAddress,#4
			mov r0,currentArgument
			mov r1,destinationStringAddress
			mov r2,#10
			mov r3,#0
			bl number2StringU
			add destinationStringAddress,r0
			add length,r0
			b formatLoop$
			notUnsigned$:
			
			/*Binary unsigned:test if b*/
			teq currentChar,#'b'
			bne notBinary$
			ldr currentArgument,[argumentListAddress]
			add argumentListAddress,#4
			mov r0,currentArgument
			mov r1,destinationStringAddress
			mov r2,#2
			mov r3,#0
			bl number2StringU
			add destinationStringAddress,r0
			add length,r0
			b formatLoop$
			notBinary$:

			/*Hex unsigned:test if x*/
			teq currentChar,#'x'
			bne notHex$
			ldr currentArgument,[argumentListAddress]
			add argumentListAddress,#4
			mov r0,currentArgument
			mov r1,destinationStringAddress
			mov r2,#16
			mov r3,#0
			bl number2StringU
			add destinationStringAddress,r0
			add length,r0
			b formatLoop$
			notHex$:
			
			/*Null terminated string:test if s*/
			teq currentChar,#'s'
			bne notString$
			ldr currentArgument,[argumentListAddress] /*currentArgument is now pointer to argument string*/
			add argumentListAddress,#4
			
			storeString$:
				ldrb tmpChar,[currentArgument]
				add currentArgument,#1
				teq tmpChar,#0
				beq nullTerminateArgumentString$
				strb tmpChar,[destinationStringAddress]
				add destinationStringAddress,#1
				add length,#1
				b storeString$
			nullTerminateArgumentString$:
			b formatLoop$
			notString$:
			
			/*NOT WORKING!!!!Store number of characters printed so far:test if n*/
			teq currentChar,#'n'
			bne notNumber$
			ldr currentArgument,[argumentListAddress]
			add argumentListAddress,#4
			str length,[currentArgument]		
			b formatLoop$
			notNumber$:
		notFormat$:
		strb currentChar,[destinationStringAddress]
		add destinationStringAddress,#1
		add length,#1
		b formatLoop$
	
	nullTerminate$:
	
	teq null,#0
	beq noNull$
	mov r1,#0
	strb r1,[destinationStringAddress]
	noNull$:
	
	mov r0,length

	.unreq formatStringAddress
	.unreq destinationStringAddress
	.unreq argumentListAddress
	.unreq currentChar
	.unreq currentArgument
	.unreq length
	.unreq tmpChar
	.unreq null
	
	pop {r4,r5,r6,r7,r8,r9,r10,r11,pc}
	
