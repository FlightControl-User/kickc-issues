#include <cx16.h>
#include <conio.h>
#include <printf.h>


typedef struct {
    signed int test[32];
} test_t;

test_t t;

void main() {

    clrscr();
    gotoxy(0,10);

    t.test[2] = 2;

    signed int a = 0;
    for(char i=0; i<8; i++) {
        a+=i;
    }

    signed int b = 0;
    for(char i=0; i<8; i++) {
        b+=i;
    }

    signed int c = a + b + t.test[2];

    printf("c=%i",c);

}
