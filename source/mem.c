#include<stdint.h>
#include<stddef.h>

void* memset(void* s, int c, size_t n){
	unsigned char* destination = s;
	uint32_t i;
	for(i=0;i<n;i++){
		destination[i] = (unsigned char)c;
	}
	return(s);
}