void test() {
    int i = 0;
    int j = 0;

    while(i<4) {
        if (j == i*2) {
            i = i + 2;
        } else {
            i = i + 1;
        }
    }
    printf(i);
}

