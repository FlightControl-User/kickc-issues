#include <c64.h>
#include <conio.h>
#include <printf.h>

inline unsigned char key_get(unsigned char key) {
    return key % 256;
}


void main() {
    clrscr();
    gotoxy(0,1);

    unsigned char i = 5;
    do {
        printf("i=%u\n", key_get(i));
        i++;
    } while(i<10);
}
