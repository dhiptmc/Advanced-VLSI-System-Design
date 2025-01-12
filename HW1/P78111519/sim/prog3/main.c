int div(int,int);
int gcd(int,int);
int main(void){
    extern int div1;
    extern int div2;
    extern int _test_start;
    int ans = gcd(div1,div2);
    (&_test_start)[0] = ans;
    return 0;
}





int gcd(int u,int v){
    unsigned int shift=0;
    if(u==0) return v;
    if(v==0) return u;
    while(((u|v)&1)==0){
        shift ++;
        u >>= 1;
        v >>= 1;
    }
    while((u&1) == 0)
            u >>= 1;
    do{
        while((v&1) == 0) v >>=1;
        if(u>v){
            v^=u;
            u^=v;
            v^=u;
        }
        v-=u;
    }while(v!=0);
    return u << shift;
}