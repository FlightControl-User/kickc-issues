#include <cx16.h>
#include <conio.h>
#include <printf.h>

#pragma var_model(zp)

inline unsigned char fun(unsigned char x, unsigned char y)
{
    return x+y;
}

void main() {

    clrscr();
    gotoxy(0,10);

    unsigned int i = 257;
    unsigned char c = i;
    printf("%u\n", c);

    for(unsigned int x=0; x<5; x++) {
        for(unsigned int y=0; y<3; y++) {
            unsigned char val = fun(x, y);
            printf("x=%u, y=%u val=%u\n", x, y, val);
        }
    }
}
