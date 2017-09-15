#include <stdint.h>

#define NULL 0

//Type definition of singly linked list
typedef struct{
	uint32_t val;
	struct linkedListNode* next;
}linkedListNode;

//Type definition of doubly linked list
typedef struct doubleLinkedListNode{
	uint32_t val;
	struct linkedListNode* previous;
	struct linkedListNode* next;
}doubleLinkedListNode;

//Prints a singly linked list 
//Must pass in 0 for second argument with format specified in variable printMessage
void printLinkedList(linkedListNode* head, uint32_t index){
	char printBuffer[40];
	char printMessage[] = "Index: %d Value: %d\n";
	uint32_t length;
	
	if (head->val != NULL){
		return;
	}
	else{
		length = formatString(printMessage,printBuffer,0,0,index,head->val);
		print(printBuffer,length);
	}
	
	while ((head->next) != NULL)
	{
		index ++;
		printLinkedList(head->next,index);
	}
}

//Prints a singly linked list in reverse with format specified in variable printMessage
//Must pass in 0 for second argument
void printLinkedListReverse(linkedListNode* head, uint32_t index){
	char printBuffer[40];
	char printMessage[] = "Index: %d Value: %d\n";
	uint32_t length;
	
	if (head->next == NULL){
		if(head->val != NULL){
			length = formatString(printMessage,printBuffer,0,0,index,head->val);
			print(printBuffer,length);
			return;
		}
	}
	index ++;
	printLinkedListReverse(head->next,index);
	index --;
	length = formatString(printMessage,printBuffer,0,0,index,head->val);
	print(printBuffer,length);
}

void pushLinkedList(linkedListNode* head, uint32_t val){
	while(head->next != NULL){
		pushLinkedList(head->next,val);
	}
	//head->next = malloc(4+4); 
	linkedListNode* new = 0x1233; //PLACEHOLDER until malloc is done
	head->next = new;
	new->val = val;
	new->next = NULL;
}


