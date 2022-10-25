#include <cx16.h>
#include <conio.h>
#include <printf.h>

typedef struct {
    signed int py[8];
} towers_t;

towers_t towers;

void main() {

    clrscr();
    gotoxy(0,10);

    printf("before increment:\n");
    for(char i=0; i<8; i++) {
        towers.py[i] = (signed int)i;
        printf("tower %u = %i\n", i, towers.py[i]);
    }

    for(char i=0; i<8; i++) {
        unsigned int py = (unsigned int)towers.py[i];
        py++;
        towers.py[i] = (signed int)py;
    }

    printf("\nafter increment:\n");
    for(char i=0; i<8; i++) {
        printf("tower %u = %i\n", i, towers.py[i]);
    }
}
