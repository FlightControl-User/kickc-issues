
#include <conio.h>
#include <printf.h>
#include <string.h>


int main() {

    char text[16];
    int test = 1;
    char text2[16];
    int test2 = 2;

    clrscr();

    strcpy(text, "hello");
    strcat(text, " world");

    strcpy(text2, "is");
    strcat(text2, " overwritten");

    printf("text = %s\n", text);
    printf("text2 = %s\n", text2);
    printf("test = %i, test2 = %i\n", test, test2);

    return 1;
}

