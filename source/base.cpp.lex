%{
/* The MIT-Zero License

Copyright (c) 2016 Dejan D. M. Milosavljevic

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/


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

SCOPE_NAME ({NAME}("::"{NAME})*)

FILE_NAME           ({ALPHA}":")?({ALNUM}|[.|\\])+

TAG_NAME        (({ALPHA}|"_")(({ALNUM}|"_"|"-")*))
TAG_PARAM_NAME  {TAG_NAME}


STRING_PASCAL      ('(([^'\n]|"\\'")*)')
STRING_C_SOLID     (\"(([^"\n]|"\\\"")*)\")
STRING_C          ({STRING_C_SOLID}({SPACES}{STRING_C_SOLID})*)
STRING            ({STRING_PASCAL}|{STRING_C})


COMMENT_CPP ("//"([^\n]*))


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


TAG_PARAM_VAL    ({STRING_C_SOLID}|{STRING_PASCAL}|{FLOAT}|{INTEGER}|{TAG_NAME})

%x c_com

%%


{BINAR}       {  SAY( printf( "BINAR    (%s)\n",  yytext ) );  WORK( yylval.number = str2int(   yytext ); return TOKEN__tINTEGER ); }
{OCTAL}       {  SAY( printf( "OCTAL    (%s)\n",  yytext ) );  WORK( yylval.number = str2int(   yytext ); return TOKEN__tINTEGER ); }
{DECAD}       {  SAY( printf( "DECAD    (%s)\n",  yytext ) );  WORK( yylval.number = str2int(   yytext ); return TOKEN__tINTEGER ); }
{HEX}         {  SAY( printf( "HEX      (%s)\n",  yytext ) );  WORK( yylval.number = str2int(   yytext ); return TOKEN__tINTEGER ); }
{INTEGER}     {  SAY( printf( "INTEGER  (%s)\n",  yytext ) );  WORK( yylval.number = str2int(   yytext ); return TOKEN__tINTEGER ); }
{FLOAT}       {  SAY( printf( "FLOAT    (%s)\n",  yytext ) );  WORK( yylval.number = str2float( yytext ); return TOKEN__tFLOAT   ); }

{FILE_NAME}   { SAY( printf( "FILE_NAME  (      %s)\n", yytext ) );  WORK( strcpy( yylval.string, yytext ); return TOKEN__tFILE_NAME  ); }
{STRING}      { SAY( printf( "STRING (%s)\n",  yytext ) ) ;          WORK( strcpy( yylval.string, yytext ); return TOKEN__tSTRING     ); }

{NAME}        {  SAY( printf( "NAME       (%s)\n", yytext ) ) ;  WORK( strcpy( yylval.string, yytext ); return TOKEN__tNAME       ); }

{SCOPE_NAME}  {  SAY( printf( "SCOPE_NAME (%s)\n", yytext ) ) ;  WORK( strcpy( yylval.string, yytext ); return TOKEN__tSCOPE_NAME ); }


{SPACE}       { /*SAY( printf( "<space>\n") );*/ }
{COMMENT_CPP} { SAY( printf( "CPP_COMMENT (%s)\n", yytext ) ); }

"/*"            { CC_counter=1; BEGIN( c_com ); }
<c_com>"/*"     { if( F_nested != 0 ) CC_counter++; }
<c_com>"\n"     { }
<c_com>{STRING} { }
<c_com>.        { }
<c_com><<EOF>>  { unput( *yytext ); BEGIN( INITIAL ); }
<c_com>"*/"     { if( --CC_counter == 0 ) { BEGIN( INITIAL ); } }

{ENDL}        {  SAY( printf( "endl\n" ) ); }
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

int main()
 {
  return yylex();
 }