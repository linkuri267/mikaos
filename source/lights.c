#include <stdint.h>
#include "lights.h"

void lightNine()
{
	setGpio(25,1);
	setGpio(8,1);
	setGpio(7,1);
	setGpio(24,1);
}

void lightDot()
{
	setGpio(4,1);

}

void lightThree()
{
	setGpio(9,1);
	setGpio(17,1);
	setGpio(23,1);
	setGpio(11,1);
	setGpio(10,1);
	setGpio(22,1);
}

void lightUpMyWorld()
{
	char length;
	char message[] = "OK Mika!";
	char messageBuffer[30];

	length = formatString(message,messageBuffer,0);
	print(messageBuffer,length);
	timerWaitMs(2500000);


	setGpioFunc(9,1);
	setGpioFunc(17,1);
	setGpioFunc(23,1);
	setGpioFunc(11,1);
	setGpioFunc(10,1);
	setGpioFunc(22,1);

	setGpioFunc(4,1);

	setGpioFunc(25,1);
	setGpioFunc(8,1);
	setGpioFunc(7,1);
	setGpioFunc(24,1);

	lightNine();
	timerWaitMs(2500000);
	lightDot();
	timerWaitMs(2500000);
	lightThree();


}

