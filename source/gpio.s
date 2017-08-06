/* 
*getGpioAddress:Gets the base address of GPIO registers
*Input:None
*Output: 
*r0:gpioAddress
*/
.globl getGpioAddress
getGpioAddress:
	ldr r0,=0x20200000
	mov pc,lr

/*
*setGpioFunc:Sets the function of given GPIO pin to given function number
*Input:
*r0:pinNum
*r1:pinFunction
*Output:None
*/
.globl setGpioFunc
setGpioFunc:
	pinNum .req r0
	pinFunc .req r1
	cmp pinNum,#53
	cmpls pinFunc,#7
	movhi pc,lr
	
	push {lr}
	mov r2,pinNum
	.unreq pinNum
	pinNum .req r2
	bl getGpioAddress
	gpioAddress .req r0

	getGroupLoop$:
		cmp pinNum,#9
		subhi pinNum,#10
		addhi gpioAddress,#4
		bhi getGroupLoop$

	add pinNum, pinNum,lsl #1
	lsl pinFunc,pinNum
	
	mov r3,#0b111
	mask .req r3
	lsl mask,pinNum
	mvn mask,mask
	
	.unreq pinNum
	ldr r2,[gpioAddress]
	oldGpioRegister .req r2
	
	and oldGpioRegister,mask
	orr pinFunc,oldGpioRegister
	str pinFunc,[gpioAddress]
	pop {pc}

/*
*setGpio:Sets the status of GPIO pin to on or off
*Inputs:
*r0: pinNum
*r1: pinVal (0 for off)
*Ouput:None
*/
.globl setGpio
setGpio:
	pinNum .req r0
	pinVal .req r1
	cmp pinNum,#53
	movhi pc, lr

	mov r2, pinNum
	.unreq pinNum
	pinNum .req r2
	push {lr}
	bl getGpioAddress
	gpioAddress .req r0

	cmp pinNum, #31
	addhi gpioAddress, #4
	and pinNum, #0b111111 /*  if (pinNum > 31) -> pinNum -= 31  */

	mov r3, #1
	setBit .req r3
	lsl setBit, pinNum
	.unreq pinNum

	cmp pinVal, #0
	.unreq pinVal
	streq setBit, [gpioAddress,#40]
	strne setBit, [gpioAddress,#28]
	.unreq setBit
	.unreq gpioAddress
	pop {pc}


