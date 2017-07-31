/*
*getMailboxAddress:Stores mailbox base address in r0
*Input: None
*Output: 
*r0:mailboxAddress
*/
.globl getMailboxAddress
getMailboxAddress:
	ldr r0,=0x2000B880
	mov pc,lr

/*
*mailboxWrite
*Input:
*r0: mailboxNumber
*r1: message
*Output: None
*/
.globl mailboxWrite
mailboxWrite:
	mailboxNumber .req r0
	message .req r1
	cmp mailboxNumber, #15
	movhi pc,lr
	tst message,#0b1111
	movne pc,lr

	mov r2, mailboxNumber
	.unreq mailboxNumber
	mailboxNumber .req r2

	push {lr}
	bl getMailboxAddress
	mailboxAddress .req r0

	waitForStatusWrite$:
		ldr r3, [mailboxAddress,#0x18]
		status .req r3
		tst status, #0x80000000
		bne waitForStatusWrite$

	.unreq status
	add message, mailboxNumber
	str message,[mailboxAddress,#0x20]

	.unreq message
	.unreq mailboxAddress
	.unreq mailboxNumber
	pop {pc}


/*
*mailboxRead:Stores message in mailbox r0 in r0
*Input:
*r0: mailboxNumber
*Output:
*r0: mail
*/
.globl mailboxRead
mailboxRead:

	mailboxNumber .req r0
	cmp mailboxNumber, #15
	movhi pc, lr

	mov r1,mailboxNumber
	.unreq mailboxNumber
	mailboxNumber .req r1

	push {lr}
	bl getMailboxAddress
	mailboxAddress .req r0 

	status .req r2
	correctBox$:
		waitForStatusRead$:
			ldr status,[mailboxAddress,#0x18]
			tst status, #0x40000000
			bne waitForStatusRead$
			.unreq status

			mailLowerFour .req r2
			ldr r3,[mailboxAddress,#0]
			mail .req r3
			and mailLowerFour, mail,#0b1111
			teq mailLowerFour, mailboxNumber
			bne correctBox$
	.unreq mailLowerFour

	and mail,#0xfffffff0
	.unreq mailboxAddress
	mov r0, mail
	.unreq mail
	.unreq mailboxNumber

	pop {pc}









