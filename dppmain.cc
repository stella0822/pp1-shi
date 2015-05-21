/* File: dppmain.cc
 * ----------------
 * This file defines the main() routine for the preprocessor, 
 * the filtering tool which runs before the compiler.
 */

#include "scanner.h"
#include <stdio.h>
#include "errors.h"
#include <string>
#include <cstring>
#include <unordered_map>
using namespace std;

#define MAX_LENGTH 31

/* Function: main()
 * ----------------
 * Entry point to the preprocessor.
 * As given below, this "filter" just copies stdin to stdout unchanged.
 * It will be your job to actually do some filtering, either by hand-coded
 * transformation of the input or by setting up a lex scanner in the dpp.l
 * file and changing the main below to invoke it via yylex. When finished,
 * the preprocessor should echo stdin to stdout making the transformations
 * to strip comments and handle preprocessor directives.
 */
int main(int argc, char *argv[])
{
    int ch;
    int ch2, ch3;  //temp variable
    
    int lineNum=1;
    
    ReportError rError;
 
    unordered_map<char*, char*>hashTableDir;
 
    ch =getc(stdin);
   
  while (ch != EOF){
      if(ch=='/'){  //start with '/' means there may be some comments
          ch2=getc(stdin);
          if(ch2=='/'){  //the content after "//" is a single-line comment
              ch2=getc(stdin);
              while(ch2!='\n'){  //'\n'is the end of a single-line comment
                  putc(' ', stdout);
                  ch2=getc(stdin);
              }
              putc(ch2, stdout);
              lineNum++;
          }
          
          else if(ch2=='*'){  //the content after "/*" are multi-line comments
              ch2=getc(stdin);
              if(ch2!=EOF){
                  ch3=getc(stdin);
                  while((ch2!='*' || ch3!='/') && ch3!=EOF){  //the end of multi-line comments is "*/"
                      if(ch2=='\n'){
                          putc(ch2,stdout);
                          lineNum++;
                      }
                      ch2=ch3;
                      ch3=getc(stdin);
                  }
                  if(ch3==EOF){  //if the file ends without "*/", we should report an error.
                      rError.UntermComment();
                  }
              }
              else{  //if the file ends without "*/", we should report an error.
                  rError.UntermComment();
              }
          }

         else{
               putc(ch, stdout);
               putc(ch2, stdout);
         }
      }
      
      else if(ch=='#'){  //start with '#' means there is "#define" or "#NAME"
          ch2=getc(stdin);
          char* str1 = (char*)malloc(sizeof(char)); 
          char* str2 = (char*)malloc(sizeof(char));
          char* str3 = (char*)malloc(sizeof(char));//str2 for NAME, and str3 for replacement
          string str="";
        
          int i=0;
          while (((ch2-'A'>=0)&&(ch2-'Z'<=0))||((ch2-'a'>=0)&&(ch2-'z'<=0))) {  //read the word after '#'
              str+=ch2;
              str1[i++]=ch2;
              ch2=getc(stdin);
          } 
       
          int temp=0;
          if (str.compare("define")==0) {  //it is a macro definition
              ch2=getc(stdin);int j=0;
              while (ch2!=' ') {  //read NAME
                  temp=0;
                  if ((ch2-'A'>=0)&&('Z'-ch2>=0)) {
                      //put NAME in the variable str2
                      str2[j++]=ch2;
                      ch2=getc(stdin);
                  }
                  else {
                      rError.InvalidDirective(lineNum);
                      ch2=getc(stdin);
                      while (ch2!='\n') {
                          ch2=getc(stdin);
                      }
                      lineNum++;
                      temp=1;
                      putc('\n',stdout);
                  }
              }

              if (!temp) {
                  ch2=getc(stdin);int k=0;
                  while (ch2!='\n') {  //read replacement
                      str3[k++]=ch2;  //put replacement in the variable str3
                      ch2=getc(stdin);
                  }
                  lineNum++;
                  
                  hashTableDir.insert(pair<char*, char*>(str2, str3));//keep str2 and str3 into the table
              }
          }
          else{  //it is a NAME to be replaced
              int tt=0;
              unordered_map<char*, char*>::iterator it=hashTableDir.begin();
              while(it!=hashTableDir.end()){
                 if(strcmp(it->first,str1)==0){
                     printf("%s",it->second);
                     tt=1;
                     break;
                 }
                 it++;
              }
              if(!tt) rError.InvalidDirective(lineNum);
          }
      }
      
      else{
          if(ch=='\n'){
              lineNum++;
          }
          putc(ch, stdout);
          //ch=getc(stdin);
      }
ch=getc(stdin);
  }

  unordered_map<char*, char*>::iterator itt=hashTableDir.begin();
  while(itt!=hashTableDir.end()){
      free(itt->first);
      itt++;
  }

  return 0;
}
