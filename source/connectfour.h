#include <stdint.h>

#define MAX_COLUMN 5
#define MAX_ROW 5

void clearBoardArea();
void drawBoard();
void drawM(uint32_t row,uint32_t column);
void drawT(uint32_t row,uint32_t column);
void drawMark(uint32_t row,uint32_t column, uint32_t player);
char checkVerticalWin(char board[MAX_ROW+1][MAX_COLUMN+1]);
char checkHorizontalWin(char board[MAX_ROW+1][MAX_COLUMN+1]);
char checkDiagonalWin(char board[MAX_ROW+1][MAX_COLUMN+1]);
char checkWin(char board[MAX_ROW+1][MAX_COLUMN+1]);
void connectFour();
