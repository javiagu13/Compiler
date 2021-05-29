#include "Kodea.h"

using namespace std;


/*****************/
/* Eraikitzailea */
/*****************/

Kodea::Kodea() {
  hurrengoId = 1;
}


/*******************/
/* hurrengoAgindua */
/*******************/

int Kodea::hurrengoAgindua() const {
  return aginduak.size() + 1;
}


/************/
/* idBerria */
/************/

string Kodea::idBerria() {
  stringstream stream;
  stream << "_t" << hurrengoId++;
  return stream.str();
}


/************/
/* agGehitu */
/************/

void Kodea::agGehitu(const string &aginduKatea) {
  stringstream agindua;
  agindua << hurrengoAgindua() << ": " << aginduKatea;
  aginduak.push_back(agindua.str());
}

/**********************/
/* erazagupenakGehitu */
/**********************/

void Kodea::erazagupenakGehitu(const string &motaIzena, const IdLista &idIzenak) {
  IdLista::const_iterator iter;
  for (iter=idIzenak.begin(); iter!=idIzenak.end(); iter++) {
    agGehitu(string(motaIzena + " " + *iter));
  }
}

/**********************/
/* parametroakGehitu  */
/**********************/

void Kodea::parametroakGehitu(const string &motaIzena, const IdLista &idIzenak, const string &pMota){ 
  string pMotaAux ;
  if      (pMota == "in") pMotaAux = "val" ;
  else if (pMota == "out") pMotaAux = "ref" ;
  else if (pMota == "in out") pMotaAux = "ref" ;
  IdLista::const_iterator iter;
  for (iter=idIzenak.begin(); iter!=idIzenak.end(); iter++) {
    agGehitu(pMotaAux + "_" + motaIzena + " " + *iter);
   // agGehitu(pMota + "_" + motaIzena + " " + *iter);
  }
}

/***********/
/* agOsatu */
/***********/

void Kodea::agOsatu(ErrefLista &aginduZenbakiak, const int balioa) {
  stringstream stream;
  ErrefLista::iterator iter;
  stream << " " << balioa;
  for (iter = aginduZenbakiak.begin(); iter != aginduZenbakiak.end(); iter++) {
    aginduak[*iter-1].append(stream.str());
  }
}


/**********/
/* idatzi */
/**********/

void Kodea::idatzi() {
  vector<string>::const_iterator iter;
  for (iter = aginduak.begin(); iter != aginduak.end(); iter++) {
    cout << *iter << " ;" << endl;
  }
}


/**************/
/* lortuErref */
/**************/

int Kodea::lortuErref() const {
  return hurrengoAgindua();
}


