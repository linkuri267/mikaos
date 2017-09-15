#include <stdint.h>
#include <mergesort.h>

void merge(uint32_t* arrayPtr,uint32_t start,uint32_t end,uint32_t mid)
{
		
	uint32_t* arrayBuffer;
	//arrayBuffer = malloc(4*(end-start+1));
	uint32_t group1Pos = start;
	uint32_t group2Pos = mid+1;
	uint32_t arrayBufferPos = 0;
	uint32_t x;
	while ((group1Pos <= mid)&&(group2Pos <=end))
	{
		if (arrayPtr[group2Pos]<arrayPtr[group1Pos])
		{
			arrayBuffer[arrayBufferPos] = arrayPtr[group2Pos];
			group2Pos ++;
		}
		else 
		{	
			arrayBuffer[arrayBufferPos] = arrayPtr[group1Pos];
			group1Pos ++;
		}
			
		arrayBufferPos ++;
	
	}
	if (group1Pos <= mid)
	{
		for (x = group1Pos;x<=mid;x++)
		{
			arrayBuffer[arrayBufferPos] = arrayPtr[x];
			arrayBufferPos ++;
		}
	}
	else if (group2Pos <= end)
	{
		for (x = group2Pos;x<=end;x++)
		{
			arrayBuffer[arrayBufferPos] = arrayPtr[x];
			arrayBufferPos ++;
		}
	}
	for (x = 0;x<arrayBufferPos;x++)
	{
		arrayPtr[x+start] = arrayBuffer[x];
	} 
	
	//free(arrayBuffer);
}


void mergesort(uint32_t* arrayPtr,uint32_t start,uint32_t end)
{
	if (start == end)
	{
		return;
	}
	uint32_t mid = (end+start)/2;
	mergesort(arrayPtr,start,mid);
	mergesort(arrayPtr,mid+1,end);
	merge(arrayPtr,start,end,mid);

}

