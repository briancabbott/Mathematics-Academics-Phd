#include <csolve.h>

void main(){
  int x,y,b;
  b = nondet();
  if (b){
    x = 10;
    y = 10;
  } else {
    x = 20;
    y = 20;
  }
  csolve_assert (x == y);
}
