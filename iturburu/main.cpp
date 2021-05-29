#include <stdio.h>
#include <iostream>
extern int yyparse();
using namespace std;

int main(int argc, char **argv)
{
  cout << "hasi da..." << endl ;
  yyparse();
  cout << "bukatu da..." << endl ;
  return 0;
}
