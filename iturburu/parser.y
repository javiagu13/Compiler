
%{
   #include <stdio.h>
   #include <iostream>
   #include <vector>
   #include <list>
   #include <string>
   using namespace std; 

   extern int yylex();
   extern int yylineno;
   extern char *yytext;
   
   void yyerror (const char *msg) {
     printf("line %d: %s at '%s'\n", yylineno, msg, yytext) ;
   }

   #include "Kodea.h"
   #include "Lag.h"


   Kodea kodea;

%}

/*******************************************************************************/
/* Ikurrek zein atributu-mota izan dezaketen.                                  */
/* Gogoratu ikur bakoitzak bakarra eta oinarrizko motak (osoko, erreal,        */
/* karaktere, erakusle).                                                       */

%union {
    string *izena ;
    string *mota ;
    IdLista *izenak ;
    expressionstruct *adi ;
    ErrefLista *next;
    int erref ;
    skipexitstruct *skipExit;
}
/*******************************************************************************/
/* Tokenak erazagutu. Honek tokens.l fitxategiarekin bat etorri behar du.      */
/* .izena atributua duten tokenak:                                             */

%token <izena> TID TINTEGER TFLOAT

/* Hauek bakarrik itzulpenaren inplementazioa erraztearren dute atributua:     */
/* Inplementazio erabakia, ez dakar espezifikazio lexikoa aldatzea igual estan mal          */

%token <izena> TCEG TCLGE TCEQ TCNE TCLT TCLE TCGT TCGE TADD TSUB TMUL TDIV

/* Hauek ez dute atributurik:         */

%token TLPAREN TRPAREN TLBRACE TRBRACE TCOMMA TCOLON TSEMIC TASSIG TLBRACKET TRBRACKET
%token RPROGRAM RINTEGER RFLOAT RIF RINT RPROC RDO RUNTIL RSKIP RELSE RREAD RPRINTLN RWHILE RFOREVER REXIT RAND ROR RNOT 

/*******************************************************************************/


/* Hemen erazagutu atributuak dauzkaten ez-bukaerakoak. Adibidea:
%type <izena> adierazpena
*/

%type <izena> aldagaia
%type <mota> mota par_mota
%type <adi> adierazpena
%type <izenak> id_zerrenda id_zerrendaren_bestea
%type <erref> M
%type <next> N
%type <skipExit> sententzia sententzia_zerrenda

/* Gainerako ez-bukaerakoek ez dute atributurik                                */

/*******************************************************************************/
/* Eragileen lehentasunak erazagutu:                                           */
/* Bukaerako izena ez da token bat eta ez dakar SZIEa aldatzea                 */
/* Inplementazioa errazten du baina ez du aldatzen espezifikazioa              */

%nonassoc TCEQ TCNE TCLT TCLE TCGT TCGE  /* azken hau ez da token bat */
%left RAND ROR RNOT
%left TADD TSUB                          
%left TMUL TDIV                          


/*******************************************************************************/

/* Hasierako ikurra erazagutu. Ez da derrigorrezkoa. Idazten ez bada,          */
/* lehenenego agertzen dena hartzen du.                                        */
/*******************************************************************************/


%start programa

%%

programa : RPROGRAM TID 
{ kodea.agGehitu("prog " + *$<izena>2); } 
erazagupenak azpiprogramen_erazagupena TLBRACE sententzia_zerrenda TRBRACE
		{kodea.agGehitu("halt");
          kodea.idatzi();}
        ;


erazagupenak: mota id_zerrenda TSEMIC 
{ 
					kodea.erazagupenakGehitu(*$<mota>1,*$<izenak>2); 
					delete $<izenak>2; delete $<mota>1;
				}
erazagupenak
		| /* hutsa */
		; 


id_zerrenda :  TID id_zerrendaren_bestea
		{
				$<izenak>$ = $<izenak>2 ;
				$<izenak>$->push_back(*$<izena>1); 
				delete $<izena>1;
			}
			;

id_zerrendaren_bestea : TCOMMA TID id_zerrendaren_bestea
							{$<izenak>$ = $<izenak>3 ;
							 $<izenak>$->push_back(*$<izena>2); 
							delete $<izena>2;}
						;
		| /* hutsa */
		{
							$<izenak>$ = new IdLista;
						}
		; 

mota: RINT
{ $<mota>$ = new std::string ; *$<mota>$ = SINTEGER; }    
    | RFLOAT 
    { $<mota>$ = new std::string ; *$<mota>$ = SFLOAT;}
	;

azpiprogramen_erazagupena : azpiprogramaren_erazagupena azpiprogramen_erazagupena
		| /* hutsa */
		; 

azpiprogramaren_erazagupena : RPROC TID 
{ kodea.agGehitu("proc " + *$<izena>2); } 
argumentuak erazagupenak azpiprogramen_erazagupena TLBRACE sententzia_zerrenda TRBRACE
		{ kodea.agGehitu("endproc");} ; 

argumentuak : TLPAREN par_zerrenda TRPAREN
	 | /* hutsa */
         ;

par_zerrenda : mota par_mota id_zerrenda 
				{kodea.parametroakGehitu(*$<mota>1,*$<izenak>3,*$<mota>2); 
				delete $<mota>1; delete $<mota>2; delete $<izenak>3;}
par_zerrendaren_bestea 
           ; 

par_mota : TCEG{$<mota>$ = new std::string ; *$<mota>$ = "in";}
	  	  | TCLE {$<mota>$ = new std::string ; *$<mota>$ = "out";}
          | TCLGE {$<mota>$ = new std::string ; *$<mota>$ = "in out";};
          
          

par_zerrendaren_bestea : TSEMIC mota par_mota id_zerrenda 
				{kodea.parametroakGehitu(*$<mota>2,*$<izenak>4,*$<mota>3); 
				delete $<mota>2; delete $<mota>3; delete $<izenak>4;}
				par_zerrendaren_bestea
				|/* Hutsa */;


sententzia_zerrenda : sententzia sententzia_zerrenda 
{$<skipExit>$ = new skipexitstruct;
$<skipExit>$->exit= $<skipExit>1->exit;
$<skipExit>$->exit.insert($<skipExit>$->exit.end(),$<skipExit>2->exit.begin(), $<skipExit>2->exit.end());
$<skipExit>$->skip= $<skipExit>1->skip;
$<skipExit>$->skip.insert($<skipExit>$->skip.end(),$<skipExit>2->skip.begin(), $<skipExit>2->skip.end());
delete $<skipExit>1;
delete $<skipExit>2;
}
                    | /* hutsa */
                    {$<skipExit>$=new skipexitstruct;}
                    ;



sententzia :  aldagaia TASSIG adierazpena TSEMIC
			{
			$<skipExit>$=new skipexitstruct; 
			kodea.agGehitu(*$<izena>1 + " := " + $<adi>3->izena); 
			delete $<izena>1 ; delete $<adi>3;
			}


            | RIF adierazpena M TLBRACE sententzia_zerrenda TRBRACE M TSEMIC
            { 
            $<skipExit>$=new skipexitstruct; 
            kodea.agOsatu($<adi>2->trueL, $<erref>3); 
			kodea.agOsatu($<adi>2->falseL, $<erref>7);
			delete $<adi>2;
			$<skipExit>$->skip=$<skipExit>5->skip;
			$<skipExit>$->exit=$<skipExit>5->exit;}


            | RWHILE RFOREVER M TLBRACE sententzia_zerrenda TRBRACE N M TSEMIC
            {$<skipExit>$=new skipexitstruct; 
            kodea.agOsatu(*$<next>7, $<erref>3);
            kodea.agOsatu($<skipExit>5->exit, $<erref>8);
            $<skipExit>$->skip=$<skipExit>5->skip;
            delete $<skipExit>5;}


            | RDO M TLBRACE sententzia_zerrenda TRBRACE RUNTIL M adierazpena RELSE M TLBRACE sententzia_zerrenda TRBRACE TSEMIC M
            { 
			$<skipExit>$=new skipexitstruct; 
            kodea.agOsatu($<adi>8->trueL, $<erref>10); 
			kodea.agOsatu($<adi>8->falseL, $<erref>2);
			kodea.agOsatu($<skipExit>4->skip, $<erref>7);
			kodea.agOsatu($<skipExit>4->exit, $<erref>15);
			kodea.agOsatu($<skipExit>12->exit, $<erref>15);
			
			$<skipExit>$->skip=$<skipExit>12->skip;
			delete $<adi>8;
			delete $<skipExit>4;	
			delete $<skipExit>12;	
			}



            | RSKIP RIF adierazpena TSEMIC M
	    	{$<skipExit>$=new skipexitstruct;  
	    	kodea.agOsatu($<adi>3->falseL, $<erref>5);
	    	$<skipExit>$->skip=$<adi>3->trueL;
			delete $<adi>3;}


	    | REXIT TSEMIC
	    { $<skipExit>$=new skipexitstruct;
	      $<skipExit>$->exit.push_back(kodea.lortuErref());
	      kodea.agGehitu("goto");
	    }
	  ;


	    | RREAD TLPAREN aldagaia TRPAREN TSEMIC
	    { kodea.agGehitu("read " + *$<izena>3);
	    $<skipExit>$=new skipexitstruct;}



	    | RPRINTLN TLPAREN adierazpena TRPAREN TSEMIC
           { 
			kodea.agGehitu("write " + $<adi>3->izena);
			kodea.agGehitu("writeln");
			delete $<adi>3;
			$<skipExit>$=new skipexitstruct;}
			;


adierazpena : adierazpena TADD adierazpena
            {$<adi>$ = new expressionstruct;
             $<adi>$->izena = kodea.idBerria();
             kodea.agGehitu($<adi>$->izena + " := " + $<adi>1->izena + " + " + $<adi>3->izena);
             delete $<adi>1; delete $<adi>3;}



            | adierazpena TSUB adierazpena
            {$<adi>$ = new expressionstruct;
             $<adi>$->izena = kodea.idBerria();
             kodea.agGehitu($<adi>$->izena + " := " + $<adi>1->izena + " - " + $<adi>3->izena);
             delete $<adi>1; delete $<adi>3;}



            | adierazpena TMUL adierazpena
            {$<adi>$ = new expressionstruct;
             $<adi>$->izena = kodea.idBerria();
             kodea.agGehitu($<adi>$->izena + " := " + $<adi>1->izena + " * " + $<adi>3->izena);
             delete $<adi>1; delete $<adi>3;}


            | adierazpena TDIV adierazpena
            {$<adi>$ = new expressionstruct;
             $<adi>$->izena = kodea.idBerria();
             kodea.agGehitu($<adi>$->izena + " := " + $<adi>1->izena + " / " + $<adi>3->izena);
             delete $<adi>1; delete $<adi>3;}



            | adierazpena TCEQ adierazpena
            {$<adi>$ = new expressionstruct;
             $<adi>$->trueL.push_back(kodea.lortuErref());
             kodea.agGehitu("if " + $<adi>1->izena + " == " + $<adi>3->izena + " goto");
             $<adi>$->falseL.push_back(kodea.lortuErref());
             kodea.agGehitu("goto");
             delete $<adi>1; delete $<adi>3;}/*BIEN*/



            | adierazpena TCLT adierazpena
            {$<adi>$ = new expressionstruct;
             $<adi>$->trueL.push_back(kodea.lortuErref());
             kodea.agGehitu("if " + $<adi>1->izena + " < " + $<adi>3->izena + " goto");
             $<adi>$->falseL.push_back(kodea.lortuErref());
             kodea.agGehitu("goto");
             delete $<adi>1; delete $<adi>3;}/*BIEN*/



            | adierazpena TCGT adierazpena
            {$<adi>$ = new expressionstruct;
             $<adi>$->trueL.push_back(kodea.lortuErref());
             kodea.agGehitu("if " + $<adi>1->izena + " > " + $<adi>3->izena + " goto");
             $<adi>$->falseL.push_back(kodea.lortuErref());
             kodea.agGehitu("goto");
             delete $<adi>1; delete $<adi>3;}/*BIEN*/



            | adierazpena TCGE adierazpena
            {$<adi>$ = new expressionstruct;
             $<adi>$->trueL.push_back(kodea.lortuErref());
             kodea.agGehitu("if " + $<adi>1->izena + " >= " + $<adi>3->izena + " goto");
             $<adi>$->falseL.push_back(kodea.lortuErref());
             kodea.agGehitu("goto");
             delete $<adi>1; delete $<adi>3;}/*BIEN*/



            | adierazpena TCLE adierazpena
            {$<adi>$ = new expressionstruct;
             $<adi>$->trueL.push_back(kodea.lortuErref());
             kodea.agGehitu("if " + $<adi>1->izena + " <= " + $<adi>3->izena + " goto");
             $<adi>$->falseL.push_back(kodea.lortuErref());
             kodea.agGehitu("goto");
             delete $<adi>1; delete $<adi>3;}/*BIEN*/

             | adierazpena TCNE adierazpena
            {$<adi>$ = new expressionstruct;
             $<adi>$->trueL.push_back(kodea.lortuErref());
             kodea.agGehitu("if " + $<adi>1->izena + " /= " + $<adi>3->izena + " goto");
             $<adi>$->falseL.push_back(kodea.lortuErref());
             kodea.agGehitu("goto");
             delete $<adi>1; delete $<adi>3;}/*BIEN*/

            |adierazpena ROR M adierazpena
			{$<adi>$ = new expressionstruct;
			kodea.agOsatu($<adi>1->falseL,$<erref>3);
			$<adi>$->trueL=$<adi>1->trueL;
			$<adi>$->trueL.insert($<adi>$->trueL.end(),$<adi>4->trueL.begin(),$<adi>4->trueL.end());
			$<adi>$->falseL=$<adi>4->falseL;
			$<adi>$->izena=$<adi>1->izena;
			}

			|adierazpena RAND M adierazpena
			{$<adi>$ = new expressionstruct;
			kodea.agOsatu($<adi>1->trueL,$<erref>3);
			$<adi>$->falseL=$<adi>1->falseL;
			$<adi>$->falseL.insert($<adi>$->falseL.end(),$<adi>4->falseL.begin(),$<adi>4->falseL.end());
			$<adi>$->trueL=$<adi>4->trueL;
			$<adi>$->izena=$<adi>1->izena;
			}


			|RNOT adierazpena
			{$<adi>$ = new expressionstruct;
			$<adi>$->trueL=$<adi>2->falseL;
			$<adi>$->falseL=$<adi>2->trueL;}

            | aldagaia
            {$<adi>$ = new expressionstruct;
             $<adi>$->izena = *$<izena>1;
             delete $<izena>1;}/*BIEN*/

	          | TINTEGER
            {$<adi>$ = new expressionstruct;
             $<adi>$->izena = *$<izena>1;
             delete $<izena>1;}/*BIEN*/


            | TFLOAT
            {$<adi>$ = new expressionstruct;
             $<adi>$->izena = *$<izena>1;
            delete $<izena>1;} /*BIEN*/


      	    | TLPAREN adierazpena TRPAREN
            {$<adi>$ = $<adi>2;};/*BIEN*/

			aldagaia : 	TID
			;


M : /* produkzio hutsa */ { $<erref>$ = kodea.lortuErref(); }
  ;

N : /* produkzio hutsa */
    { $<next>$ = new ErrefLista;
      $<next>$->push_back(kodea.lortuErref());
      kodea.agGehitu("goto");
    }
  ;


%%



