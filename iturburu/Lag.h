#ifndef LAG_H_
#define LAG_H_
#define YYDEBUG 1
#include <string>
#include <set>
#include <vector>
#include <list>

typedef std::list<std::string> IdLista;
typedef std::list<int> ErrefLista;

struct expressionstruct {
  std::string izena ;
  ErrefLista trueL ;  // true hitz erreserbatua c-z
  ErrefLista falseL ; // false hitz erreserbatua c-z
};

struct skipexitstruct{
ErrefLista skip;
ErrefLista exit;
};

#define SINTEGER "int"
#define SFLOAT "real"

#endif /* LAG_H_ */
