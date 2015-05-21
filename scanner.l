/* File:  scanner.l
 * ----------------
 * Lex inupt file to generate the scanner for the compiler.
 */

%{

/* The text within this first region delimited by %{ and %} is assumed to
 * be C/C++ code and will be copied verbatim to the lex.yy.c file ahead
 * of the definitions of the yylex() function. Add other header file inclusions
 * or C++ variable declarations/prototypes that are needed by your code here.
 */

#include <string.h>
#include "scanner.h"
#include "utility.h" // for PrintDebug()
#include "errors.h"

/* Global variable: yylval
 * -----------------------
 * This global variable is how we get attribute information about the token
 * just scanned to the client. The scanner sets the global variable
 * appropriately and since it's global the client can just read it.  In the
 * future, this variable will be declared for us in the y.tab.c file
 * produced by Yacc, but for now, we declare it manually.
 */
YYSTYPE yylval;  // manually declared for pp1, later Yacc provides

/* Global variable: yylloc
 * -----------------------
 * This global variable is how we get position information about the token
 * just scanned to the client. (Operates similarly to yylval above)
 */
struct yyltype yylloc; // manually dclared for pp1, later Yacc provides




/* Macro: YY_USER_ACTION 
 * ---------------------
 * This flex built-in macro can be defined to provide an action which is
 * always executed prior to any matched rule's action. Basically, it is
 * a way of having a piece of code common to all actions factored out to
 * this routine.  We already defined it for you and left the empty
 * function DoBeforeEachAction ready for your use as needed. It will
 * be called once for each pattern scanned from the file, before
 * executing its action.
 */
static void DoBeforeEachAction(); 
#define YY_USER_ACTION DoBeforeEachAction();

void checkleng();
void setint();
int count(int, int);
%}

 /* The section before the first %% is the Definitions section of the lex
  * input file. Here is where you set options for the scanner, define lex
  * states, and can set up definitions to give names to regular expressions
  * as a simple substitution mechanism that allows for more readable
  * entries in the Rules section later. 
  */

tab [ \t]*
newline (\n)*
ws ({tab}|{newline})
letter [A-Za-z]
digit [0-9]
underscore (_)
bool (true)|(false)
id ({letter})({letter}|{digit}|{underscore})*
int (({digit})(({digit})*))|((0x|0X)({digit}|[A-F]|[a-f])(({digit}|[A-F]|[a-f])*))
double ({digit})(({digit})*)\.(({digit})*)((([eE]?)[+\-]{digit}(({digit})*))?)
singlechar_operater \+|\-|\*|\/|\%|<|>|=|!
punctuation ;|,|\.|\[|\]|\(|\)|\{|\}
twochar_operater_lessEqual <=
twochar_operater_greaterEqual >=
twochar_operater_equal ==
twochar_operater_notEqual !=
twochar_operater_and &&
twochar_operater_or \|\|
badstring \"((\?|:|\\|\||&|\^|\$|@|~|`|\'|#|{letter}|{digit}|{underscore}|{singlechar_operater}|{twochar_operater_lessEqual}|{twochar_operater_greaterEqual}|{twochar_operater_equal}|{twochar_operater_notEqual}|{twochar_operater_and}|{twochar_operater_or}|{punctuation}|{tab})*)((newline)*)
string \"(\?|:|\\|\||&|\^|\$|@|~|`|\'|{letter}|{digit}|{underscore}|{singlechar_operater}|{twochar_operater_lessEqual}|{twochar_operater_greaterEqual}|{twochar_operater_equal}|{twochar_operater_notEqual}|{twochar_operater_and}|{twochar_operater_or}|{punctuation}|{tab})*\"
otherchar \?|:|\\|\||&|\^|\$|@|~|`|\'|#|{underscore}


%%             /* BEGIN RULES SECTION */
 /* All patterns and actions should be placed between the start and stop
  * %% markers which delimit the Rules section. 
  */ 
({tab}) {}
({newline}) {for(int i=0;i<yyleng;i++) {yylloc.first_line++;} yylloc.first_column=1; yylloc.last_column=1;}
(void) {return (T_Void);}
(int) {return (T_Int);}
(double) {return (T_Double);}
(bool) {return (T_Bool);}
(string) {return (T_String);}
(class) {return (T_Class);}
(interface) {return (T_Interface);}
(null) {return (T_Null);}
(this) {return (T_This);}
(extends) {return (T_Extends);}
(implements) {return (T_Implements);}
(for) {return (T_For);}
(while) {return (T_While);}
(if) {return (T_If);}
(else) {return (T_Else);}
(return) {return (T_Return);}
(break) {return (T_Break);}
(New) {return (T_New);}
(NewArray) {return (T_NewArray);}//recognize keywords and return the correct token from scanner.h
({bool}) {if(yytext[0]=='t'||yytext[0]=='T') {yylval.boolConstant=true;} else if(yytext[0]=='f'||yytext[0]=='F') {yylval.boolConstant=false;} return (T_BoolConstant);}
({id}) {checkleng(); return (T_Identifier);}//recognize identifiers, and return the correct token, and set appropriate fields of yylval
({int}) {setint(); return (T_IntConstant);}
({double}) {yylval.doubleConstant=atof(yytext); return (T_DoubleConstant);}
({badstring}) {yyltype* yyl=&yylloc; ReportError::UntermString(yyl, yytext); yylloc.first_line++; yylloc.first_column=1; yylloc.last_column=1;}
({string}) {yylval.stringConstant=yytext; return (T_StringConstant);}//recognize int, double, bool and string constants, and return the correct token, and set appropriate field of yylval
({singlechar_operater}) {int ascii=yytext[0]; return (ascii);}
({punctuation}) {int ascii=yytext[0]; return (ascii);}
({twochar_operater_lessEqual}) {return (T_LessEqual);}
({twochar_operater_greaterEqual}) {return (T_GreaterEqual);}
({twochar_operater_equal}) {return (T_Equal);}
({twochar_operater_notEqual}) {return (T_NotEqual);}
({twochar_operater_and}) {return (T_And);}
({twochar_operater_or}) {return (T_Or);}
({otherchar}) {yyltype* yyl=&yylloc; char ch=yytext[0]; ReportError::UnrecogChar(yyl, ch);}

%%
/* The closing %% above marks the end of the Rules section and the beginning
 * of the User Subroutines section. All text from here to the end of the
 * file is copied verbatim to the end of the generated lex.yy.c file.
 * This section is where you put definitions of helper functions.
 */


/* Function: InitScanner
 * ---------------------
 * This function will be called before any calls to yylex().  It is designed
 * to give you an opportunity to do anything that must be done to initialize
 * the scanner (set global variables, configure starting state, etc.). One
 * thing it already does for you is assign the value of the global variable
 * yy_flex_debug that controls whether flex prints debugging information
 * about each token and what rule was matched. If set to false, no information
 * is printed. Setting it to true will give you a running trail that might
 * be helpful when debugging your scanner. Please be sure the variable is
 * set to false when submitting your final version.
 */
void InitScanner()
{
    yylloc.first_column=1;
    yylloc.first_line=1;
    yylloc.last_column=1;
    PrintDebug("lex", "Initializing scanner");
    yy_flex_debug = true;
}


/* Function: DoBeforeEachAction()
 * ------------------------------
 * This function is installed as the YY_USER_ACTION. This is a place
 * to group code common to all actions.
 */
static void DoBeforeEachAction()
{//printf("%s",yytext);
    if((yylloc.first_column==1)&&(yylloc.last_column==1)){
       yylloc.last_column+=yyleng-1;
    }
    else{  
       yylloc.first_column=yylloc.last_column+1;
       yylloc.last_column+=yyleng;
    }
}

void checkleng(){
    int i;
    for(i=0;i<32;i++){
        yylval.identifier[i]='\0';
    }
    if(yyleng>MaxIdentLen){
        yyltype* yyl=&yylloc; char* ch=yytext;
        ReportError::LongIdentifier(yyl, ch);
        for(i=0;i<31;i++){
            yylval.identifier[i]=yytext[i];
        }
        yyleng=31;
    }
    else{
        for(i=0;i<yyleng;i++){
            yylval.identifier[i]=yytext[i];
        }
    }
}

void setint(){
  int i;
  int temp=0;
  if((yytext[1]=='x')||(yytext[1]=='X')){
       for(i=2;i<yyleng;i++){
             switch(yytext[i]){
                   case 'a':
                   case 'A': temp+=10*count(16,yyleng-i-1); break;
                   case 'b':
                   case 'B': temp+=11*count(16,yyleng-i-1); break;
                   case 'c':
                   case 'C': temp+=12*count(16,yyleng-i-1); break;
                   case 'd':
                   case 'D': temp+=13*count(16,yyleng-i-1); break;
                   case 'e':
                   case 'E': temp+=14*count(16,yyleng-i-1); break;
                   case 'f':
                   case 'F': temp+=15*count(16,yyleng-i-1); break;
                   default: temp+=(yytext[i]-'0')*count(16,yyleng-i-1); break;
             }
       }
  }
  else{
       temp=0;
       for(i=0;i<yyleng;i++){
             temp=temp+(yytext[i]-'0')*count(10,yyleng-i-1);
       }
  }
  yylval.integerConstant=temp;
}

int count(int t, int num){
  int i;
  int result=1;
  for(i=0;i<num;i++){
     result*=t;
  }
  return result;
}
