/*
*getTimerAddress: Stores timer base address in r0
*Input: Void
*Output:
*r0: Timer base address
*/
.globl getTimerAddress
getTimerAddress:
	ldr r0,=0x20003000
	mov pc, lr

/*
*getCounterValue: Stores counter value in r0 and r1 (r0 lower)
*Input: None
*Output: 
*r0: lower counter
*r1: upper counter
*/
.globl getCounterValue
getCounterValue:
	push {lr}
	bl getTimerAddress
	ldrd r0,r1,[r0,#4]
	pop {pc}
	

/*
*timerWaitMs: Delay r0 ms 
*Input: 
*r0: Delay time in ms
*Output: Void
*/
.globl timerWaitMs
timerWaitMs:
	
	push {lr}
	mov r2,r0
	delayTime .req r2
	bl getCounterValue
	mov r3,r0
	start .req r3
	
	elapsed .req r1
	end .req r0
	counterLoop$:
		bl getCounterValue
		sub elapsed, end, start
		cmp elapsed, delayTime
		bls counterLoop$
	
	.unreq elapsed
	.unreq delayTime
	.unreq end
	.unreq start
		 
	pop {pc}







