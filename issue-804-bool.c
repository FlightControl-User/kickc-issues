#pragma var_model(zp)

#include <c64.h>
#include <conio.h>
#include <printf.h>

#define MAX 5

inline char return_max(unsigned char num)
{
    return (char)(num >= MAX);
}

void main() {
    clrscr();
    gotoxy(0,1);

    for(unsigned char i=0; i<10; i++) {
        printf("num=%u, max=%u\n", i, return_max(i));
    }

}
