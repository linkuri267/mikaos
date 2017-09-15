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

void printLinkedList(linkedListNode* head, uint32_t index);
void printLinkedListReverse(linkedListNode* head, uint32_t index);
void pushLinkedList(linkedListNode* head, uint32_t val);