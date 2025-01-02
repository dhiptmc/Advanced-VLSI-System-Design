typedef unsigned int UINT;
extern UINT div1;
extern UINT div2;
extern int _test_start;

UINT gcd(UINT, UINT);
int main(void){
    (&_test_start)[0] = gcd(div1,div2);
    return 0;
}

UINT gcd(UINT u,UINT v){
  UINT r;
  while (v != 0){
    r = u % v;
    u = v;
    v = r;
  }
  return u;
}