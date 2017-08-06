#include <stdint.h>
#include "connectfour.h"

//Calls setPixel on board area with black forecolor
void clearBoardArea()
{
	setForeColor(0x0);
	
	uint32_t x;
	uint32_t y;
	
	for (y = 34; y <= 730; y++)
	{
		for (x = 112; x<= 910; x++)
		{
			setPixel(x,y);
		}
	}
}

//Draws 6x6 grid 
void drawBoard()
{
	uint32_t x0 = 112;
	uint32_t y0 = 34;
	uint32_t x1 = 910;
	uint32_t y1 = 34;
	
	while (y0 <= 730)
	{
		drawLine(x0,y0,x1,y1);
		y0 += 116;
		y1 += 116;
	}
	
	x0 = 112;
	x1 = 112;
	y0 = 34;
	y1 = 730;
	while (x0 <= 910)
	{
		drawLine(x0,y0,x1,y1);
		x0 += 133;
		x1 += 133;
	}
}

//Draws M at (row,column)
void drawM(uint32_t row,uint32_t column)
{
	uint32_t baseX = 112+(column*133);
	uint32_t baseY = 34+(row*116);
	
	drawLine(baseX+10,baseY+106,baseX+10,baseY+10);
	drawLine(baseX+10,baseY+10,baseX+66,baseY+106);
	drawLine(baseX+66,baseY+106,baseX+123,baseY+10);
	drawLine(baseX+123,baseY+10,baseX+123,baseY+106);
}

//Draws T at (row,column)
void drawT(uint32_t row,uint32_t column)
{
	uint32_t baseX = 112+(column*133);
	uint32_t baseY = 34+(row*116);
	
	drawLine(baseX+10,baseY+10,baseX+123,baseY+10);
	drawLine(baseX+66,baseY+106,baseX+66,baseY+10);
}

//Draws mark based on player parameter: player 1 -> M player 2 -> T at (row,column)
//Row up to down 
//Column left to right 
void drawMark(uint32_t row,uint32_t column,uint32_t player)
{
	if (player == 1)
	{
		drawM(row,column);
	}
	else if (player == 2)
	{
		drawT(row,column);
	}
		
}

//Checks board for 4 in a column
char checkVerticalWin(char board[MAX_ROW+1][MAX_COLUMN+1])
{
	uint32_t countPlayer1 = 0;
	uint32_t countPlayer2 = 0;
	char column;
	char row;
	char win = 0;
	
	for (column = 0;column<=MAX_COLUMN;column++)
	{
		for (row = 0;row<=MAX_ROW;row++)
		{
			if ((board[row][column])==1)
			{
				countPlayer1++;
				countPlayer2 = 0;
			}
			else if ((board[row][column])==2)
			{
				countPlayer2++;
				countPlayer1 = 0;
			}
			else 
			{
				countPlayer1 = 0;
				countPlayer2 = 0;
			}
			if (countPlayer1>=4)
			{
				win = 1;
				goto won;
			}
			else if (countPlayer2>=4)
			{
				win = 2;
				goto won;
			}
		}
	}
	won:
	return(win);
	
}

//Checks board for 4 in a row
char checkHorizontalWin(char board[MAX_ROW+1][MAX_COLUMN+1])
{
	uint32_t countPlayer1 = 0;
	uint32_t countPlayer2 = 0;
	char column;
	char row;
	char win = 0;
	
	for (row = 0;row<=MAX_ROW;row++)
	{
		for (column = 0;column<=MAX_COLUMN;column++)
		{
			if ((board[row][column])==1)
			{
				countPlayer1++;
				countPlayer2 = 0;
			}
			else if ((board[row][column])==2)
			{
				countPlayer2++;
				countPlayer1 = 0;
			}
			else 
			{
				countPlayer1 = 0;
				countPlayer2 = 0;
			}
			if (countPlayer1>=4)
			{
				win = 1;
				goto won;
			}
			else if (countPlayer2>=4)
			{
				win = 2;
				goto won;
			}
		}
	}
	won:
	return(win);
}

//Checks board for 4 marks diagonally
char checkDiagonalWin(char board[MAX_ROW+1][MAX_COLUMN+1])
{
	uint32_t countPlayer1 = 0;
	uint32_t countPlayer2 = 0;
	char column;
	char row;
	int32_t columnOffset;
	int32_t rowOffset;
	char win = 0;
	
	//For 6x6: Checking from 0th row, 0th column until 2nd row 2nd column with step +1,+1
	column = 0;
	for (row = 0;row <= (MAX_ROW-3);row++)
	{
		rowOffset = 0;
		columnOffset = 0;
		while (((row+rowOffset)<=MAX_ROW)&&((column+columnOffset)<=MAX_COLUMN))
		{
			if ((board[row+rowOffset][column+columnOffset])==1)
			{
				countPlayer1++;
				countPlayer2 = 0;
			}
			else if ((board[row+rowOffset][column+columnOffset])==2)
			{
				countPlayer2++;
				countPlayer1 = 0;
			}
			else 
			{
				countPlayer1 = 0;
				countPlayer2 = 0;
			}
			if (countPlayer1>=4)
			{
				win = 1;
				goto won;
			}
			else if (countPlayer2>=4)
			{
				win = 2;
				goto won;
			}
			rowOffset ++;
			columnOffset ++;
		}
	}
	//For 6x6: Checking from 0th row, 1st column until 0th row 2nd column with step +1,+1
	row = 0;
	for (column = 1;column <= (MAX_COLUMN-3);column++)
	{
		rowOffset = 0;
		columnOffset = 0;
		while (((row+rowOffset)<=MAX_ROW)&&((column+columnOffset)<=MAX_COLUMN))
		{
			if ((board[row+rowOffset][column+columnOffset])==1)
			{
				countPlayer1++;
				countPlayer2 = 0;
			}
			else if ((board[row+rowOffset][column+columnOffset])==2)
			{
				countPlayer2++;
				countPlayer1 = 0;
			}
			else 
			{
				countPlayer1 = 0;
				countPlayer2 = 0;
			}
			if (countPlayer1>=4)
			{
				win = 1;
				goto won;
			}
			else if (countPlayer2>=4)
			{
				win = 2;
				goto won;
			}
			rowOffset ++;
			columnOffset ++;
		}
	}
	
	column = 0;
	for (row = MAX_ROW;row >= 3;row--)
	{
		rowOffset = 0;
		columnOffset = 0;
		while (((row+rowOffset)>=0)&&((column+columnOffset)<=MAX_COLUMN))
		{
			if ((board[row+rowOffset][column+columnOffset])==1)
			{
				countPlayer1++;
				countPlayer2 = 0;
			}
			else if ((board[row+rowOffset][column+columnOffset])==2)
			{
				countPlayer2++;
				countPlayer1 = 0;
			}
			else 
			{
				countPlayer1 = 0;
				countPlayer2 = 0;
			}
			if (countPlayer1>=4)
			{
				win = 1;
				goto won;
			}
			else if (countPlayer2>=4)
			{
				win = 2;
				goto won;
			}
			rowOffset --;
			columnOffset ++;
		}
	}
	
	row = MAX_ROW;
	for (column = 1;column <= (MAX_COLUMN-3);column++)
	{
		rowOffset = 0;
		columnOffset = 0;
		while (((row+rowOffset)>=0)&&((column+columnOffset)<=MAX_COLUMN))
		{
			if ((board[row+rowOffset][column+columnOffset])==1)
			{
				countPlayer1++;
				countPlayer2 = 0;
			}
			else if ((board[row+rowOffset][column+columnOffset])==2)
			{
				countPlayer2++;
				countPlayer1 = 0;
			}
			else 
			{
				countPlayer1 = 0;
				countPlayer2 = 0;
			}
			if (countPlayer1>=4)
			{
				win = 1;
				goto won;
			}
			else if (countPlayer2>=4)
			{
				win = 2;
				goto won;
			}
			rowOffset --;
			columnOffset ++;
		}
	}
		won:
		return(win);
}

//Calls checks on every direction
//Returns 0 for no winner. 1 for player 1 win, 2 for player 2 win
char checkWin(char board[MAX_ROW+1][MAX_COLUMN+1])
{
	char win;
	win = checkVerticalWin(board);
	if (win == 0)
	{
		win = checkHorizontalWin(board);
		if (win == 0)
		{
			win = checkDiagonalWin(board);
		}
	}
	
	return(win);
}

//Connect Four implementation 
//6x6 board
void connectFour()
{
	char inputBuffer[4];
	char welcomeMessage[]="Welcome to Connect Four v9.3\n";
	char choicePrompt[]="Player %d please choose column 0-5:";
	char winMessage1[]="Player 1 (Mika) has won!";
	char winMessage2[]="Player 2 (Takahashi) has won!";
	char messageBuffer[40];
	unsigned char player = 1;
	char length;
	char board[6][6] = {{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0}};
	uint32_t column;
	char count;
	char playerHasWon = 0;
	
	terminalClear();
	setForeColor(0xFABF);
	drawBoard();
	print(welcomeMessage,29);
	
	//Turn
	while (playerHasWon == 0)
	{
		length = formatString(choicePrompt,messageBuffer,0,0,player);
		print(messageBuffer,length);
		length = readLine(inputBuffer,4);
		
		column = stringToInt(inputBuffer);
		count = 0;
		while ((board[count][column])!=0)
		{
			count ++;
		}
		board[count][column]=player;
		setForeColor(0xFABF);
		drawMark((MAX_ROW-count),column,player);
		
		//Check if player has won
		playerHasWon = checkWin(board);
		if (playerHasWon==1)
		{
			terminalClear();
			length = formatString(winMessage1,messageBuffer,0);
			print(winMessage1,length);
		}
		else if (playerHasWon==2)
		{
			terminalClear();
			length = formatString(winMessage2,messageBuffer,0);
			print(winMessage2,length);
		}
		
		//Switch players
		if (player == 1)
		{
			player = 2;
		}
		else
		{
			player = 1;
		}
	}
	
	timerWaitMs(2500000);
	clearBoardArea();
	
}
	