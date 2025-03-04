int f(int a, int b){
    if (a)
    {
    }

    a = a*b-a +4;
    return a;
}

int main()
{
    int a = 5;
    int b = 10;

    if(a < f(a,b)){
        b = f(a,b); 
        if( b < a ){
            a = b;
        }
    }
    return 0;
}
