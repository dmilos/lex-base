%{
  /* freeware freeware freeware freeware freeware freeware */
  /** this file is freeware
   * @author   Dejan D. M. Milosavljevic
   * @created  1997.
   * @comment framework for lex files
   *
  */
 /* freeware freeware freeware freeware freeware freeware */


  #include   <math.h>
  #include <string.h>
  //#include <alloc.h> by Watcom
  #include <malloc.h>
  //#include "y_tab.h"

  // LEX stuff
  /*
  #undef YY_DECL
  #define YY_DECL int yylex( YYSTYPE *yylval, YYLTYPE *yylloc )
  */

  /*
  #undef YY_INPUT
  #define YY_INPUT(buf,res,max)         \
   {                                    \
    res = fread( buf, 1, max, yyin );    \
    if( res == 1 )                      \
     {                                  \
      if(*(buf)=='\n' ) yy_no_line ++;  \
     }                                  \
   }
  */

  int yy_no_line = 0;
  /* locals vars*/

  /* locals funcs */

  double str2float( char * );
  long   str2int( char * );


  /* debugs */
  #define SAY(a)  a
  #define WORK(a)

  /* main's  */


%}

ENDL     \n
WHITE    [ \t]
WHITES   ([ \t]+)
OWHITES  ([ \t]*)

SPACE    ({ENDL}|{WHITE})
OSPACE   (({ENDL}|{WHITE})?)
SPACES   ({SPACE}+)
OSPACES  ({SPACE}*)

ALPHA    [a-zA-Z]
ALNUM    (({ALPHA}|[0-9]))

NAME     (({ALPHA}|"_")(({ALNUM}|"_")*))



CHAR     (("\'"."\'")|( "\'" \\0x[0-9]([0-9]){,2}"\'" )

STRING_PASCAL      ('(([^'\n]|"\\'")*)')
STRING_C_SOLID     (\"(([^"\n]|"\\\"")*)\")
STRING_C          ({STRING_C_SOLID}({SPACES}{STRING_C_SOLID})*)
STRING            ({STRING_PASCAL}|{STRING_C})


ZERO     "0"
UBINAR   ("0b"[01]+)
BINAR    (("+"|"-")?{UBINAR})
UOCTAL   (("0"[0-7]+)|("0o"[0-7]+))
OCTAL    (("+"|"-")?{UOCTAL})
UDECAD   (([1-9][0-9]*)|("0d"[0-9]+))
DECAD    (("+"|"-")?{UDECAD})
UHEX     ("0x"[0-9a-fA-F]+)
HEX      (("+"|"-")?{UHEX})

UINTEGER   ({UBINAR}|{UOCTAL}|{UDECAD}|{UHEX}|{ZERO})
INTEGER   (("+"|"-")?{UINTEGER})

FLOAT_LEFT   {UINTEGER}"."
FLOAT_RIGHT  "."{UINTEGER}
FLOAT_FULL  {UINTEGER}"."{UINTEGER}
FLOAT       ("+"|"-")?({UINTEGER}|{FLOAT_LEFT}|{FLOAT_RIGHT}|{FLOAT_FULL})((("e"|"E"){INTEGER})?)
UFLOAT                ({UINTEGER}|{FLOAT_LEFT}|{FLOAT_RIGHT}|{FLOAT_FULL})((("e"|"E"){INTEGER})?)


%x c_com

%%


{BINAR}       {  SAY( printf( "BINAR    (%s)\n",  yytext ) );  WORK( yylval.number = str2int(   yytext ); return TOKEN__tINTEGER ); }
{OCTAL}       {  SAY( printf( "OCTAL    (%s)\n",  yytext ) );  WORK( yylval.number = str2int(   yytext ); return TOKEN__tINTEGER ); }
{DECAD}       {  SAY( printf( "DECAD    (%s)\n",  yytext ) );  WORK( yylval.number = str2int(   yytext ); return TOKEN__tINTEGER ); }
{HEX}         {  SAY( printf( "HEX      (%s)\n",  yytext ) );  WORK( yylval.number = str2int(   yytext ); return TOKEN__tINTEGER ); }
{INTEGER}     {  SAY( printf( "INTEGER  (%s)\n",  yytext ) );  WORK( yylval.number = str2int(   yytext ); return TOKEN__tINTEGER ); }
{FLOAT}       {  SAY( printf( "FLOAT    (%s)\n",  yytext ) );  WORK( yylval.number = str2float( yytext ); return TOKEN__tFLOAT   ); }

{CHAR}        {  SAY( printf( "CHAR       (%s)\n", yytext ) ) ;  WORK( strcpy( yylval.string, yytext ); return TOKEN__tCHAR       ); }
{STRING}      {  SAY( printf( "STRING     (%s)\n", yytext ) ) ;  WORK( strcpy( yylval.string, yytext ); return TOKEN__tSTRING     ); }
{NAME}        {  SAY( printf( "NAME       (%s)\n", yytext ) ) ;  WORK( strcpy( yylval.string, yytext ); return TOKEN__tNAME       ); }

{SPACE}       { /*SAY( printf( "<space>\n") );*/ }

.             {  /*SAY( printf( "junk char(%c,%i)\n", *yytext, *yytext ) ); */WORK( return *yytext ); }

%%

static double str2float( char *num )
 {
  //#error unfinished
  return atof( num );
 }
static long str2int( char *str )
 {
  if( str[0] == '0' )
   switch( str[ 1 ] )
    {
     case( '\0' ):  return  0;
     case(  'b' ):  return strtol( str+2, NULL,  2 );
     case(  'o' ):  return strtol( str+2, NULL,  8 );
     case(  'd' ):  return strtol( str+2, NULL, 10 );
     case(  'x' ):  return strtol( str+2, NULL, 16 );
     default:       return strtol( str+1, NULL,  8 );
    }

  return strtol( str, NULL, 10 );
 }
/*
int main()
 {
  return yylex();
 }
 
 */