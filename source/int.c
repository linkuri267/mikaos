#include <stdint.h>

int32_t stringToInt(char* string)
{
	int32_t count = 0;
	int32_t pos;
	char sign;
	
	if (string [0]=='-')
	{
		pos = 1;
		sign = 1;
	}
	else 
	{
		pos = 0;
		sign = 0;
	}
	
	
	while((string[pos])!='\0')
	{
		count = count * 10 + string[pos] - '0';
		pos ++;
	}
	
	if (sign == 1)
	{
		count = -count;
	}
	
	return(count);
}
