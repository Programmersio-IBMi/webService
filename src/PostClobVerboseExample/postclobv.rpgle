**Free
       Ctl-opt option(*srcstmt:*nodebugio);
       Ctl-opt dftactgrp(*no) actgrp(*caller);

      /copy qwebsrcn,postclob_c

       Dcl-pi POSTCLOBV;
         email  char(30);
         name   char(25);
         gender char(10);
         status char(10);
       End-pi;
       //***********************************************************************
       // MainLine
       //***********************************************************************
         *inlr = *on;

         Exec sql set option commit = *none;

         SetEnvironment();
         ProcessApi();

       //***********************************************************************
       // SetRequest - Set the web service variables
       //***********************************************************************
         Dcl-proc SetEnvironment;

           Exec sql CALL QSYS2.QCMDEXC('CHGJOB CCSID(37)');
           Tokenheader = '<httpHeader>'                                      +
                     '<header name="Authorization" value="'                  +
                          %trim(TokenKey) + '">'                             +
                     '</header>'                                             +
                     '<header name="Content-Type" value="application/json">' +
                     '</header>'                                             +
                     '</httpHeader>';


           Body = '{' + '"email":' + '"' + %trim(email)   + '",'    +
                       '"name":'  + '"' + %trim(name)    + '",'     +
                       '"gender":' + '"' + %trim(gender)  + '",'    +
                       '"status":'+ '"' + %trim(status)  + '"' + '}';

         End-proc;
       //***********************************************************************
       // ProcessApi - Send Post Request And Fetch Data
       //***********************************************************************
         Dcl-proc ProcessApi;

           Exec sql
            Select Coalesce(Varchar(ResponseMsg,9999),' '),
                   Varchar(ResponseHttpHeader,1000) into :ResponseMsg,
                                                         :ResponseHeader
            From Table(Systools.HttpPostClobVerbose(Trim(:Url),
                                                    Trim(:Tokenheader),
                                                    Trim(:body)))
                                                    as JsonResponse;

           Diagnostics();
           if ReturnedSqlCode = *Blanks;

             exec sql drop table if exists qtemp/WkTestFile;
             exec sql create table qtemp/WkTestFile(data char(9999));
             exec sql insert into qtemp/WkTestFile(data)
                                     values(:ResponseMsg);

             dsply 'Check WkTestFile file in Qtemp for data';
           endIf;

         End-proc;
       //***********************************************************************
       // Diagnostics - get sql details
       //***********************************************************************
         Dcl-proc Diagnostics ;

           Exec sql GET DIAGNOSTICS CONDITION 1
             :ReturnedSqlCode = DB2_RETURNED_SQLCODE,
             :MessageLength = MESSAGE_LENGTH,
             :MessageText = MESSAGE_TEXT;

         End-proc ;

