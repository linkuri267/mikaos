.section .data
	.align 4
	.globl frameBufferInfo 
	frameBufferInfo:
	.int 1024 /* #0 Physical Width */
	.int 768 /* #4 Physical Height */
	.int 1024 /* #8 Virtual Width */
	.int 768 /* #12 Virtual Height */
	.int 0 /* #16 GPU - Pitch */
	.int 16 /* #20 Bit Depth */
	.int 0 /* #24 X */
	.int 0 /* #28 Y */
	.int 0 /* #32 GPU - Pointer */
	.int 0 /* #36 GPU - Size */

.section .text
	/*
	*initializeFrameBuffer
	*Inputs:
	*r0: width
	*r1: height
	*r2: bitDepth
	*Output: result if success, 0 if error
	*/
	.globl initializeFrameBuffer
	initializeFrameBuffer:
		width .req r0
		height .req r1

		bitDepth .req r2
		cmp width, #4096
		cmpls height, #4096
		cmpls bitDepth, #32
		movhi r0,#0 /*Inputs out of bounds, return 0 */
		movhi pc, lr

		frameBufferInfoAddress .req r4
		ldr frameBufferInfoAddress,=frameBufferInfo
		str width, [frameBufferInfoAddress,#0]
		str height, [frameBufferInfoAddress,#4]
		str width, [frameBufferInfoAddress,#8]
		str height, [frameBufferInfoAddress,#12]
		str bitDepth, [frameBufferInfoAddress,#20]
		.unreq width
		.unreq height
		.unreq bitDepth

		add r1,frameBufferInfoAddress,#0x40000000
		mov r0, #1 /*Mailbox 1*/
		push {lr}
		bl mailboxWrite

		mov r0,#1
		bl mailboxRead

		result .req r0
		teq result, #0
		movne r0, #0
		popne {pc}

		mov result, frameBufferInfoAddress
		.unreq frameBufferInfoAddress
		.unreq result
		pop {pc}
