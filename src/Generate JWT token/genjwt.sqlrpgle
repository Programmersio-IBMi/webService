**free
     ctl-opt dftActGrp(*no) bndDir('WEBSRCBND');

      /copy qsysinc/qrpglesrc,qusec

     dcl-pr writeToWeb extProc('QtmhWrStout');
       datavar char(65535) Options(*varsize);
       datavarlen int(10) const ;
       errcode char(8000) Options(*varsize);
     end-pr;

     dcl-pr getEnv pointer extproc('getenv');
       *n pointer value options(*string);
     end-pr;

     dcl-pr readStdInput extproc('QtmhRdStin');
       rtnBuffer char(65535) options(*varsize);
       bufLen int(10) const;
       rtnLen int(10);
       qusec like(qusec);
     end-pr;

     dcl-pr translate extPgm('QDCXLATE');
       length packed(5:0) const;
       data char(32766) options(*varsize);
       table char(10) const;
     end-pr;

     dcl-pr validateUserProfile extPgm('QSYGETPH');
       uId char(10);
       pwd char(10);
       handle char(12);
       errorDs like(erDs);
       pwdLength int(10) options(*nopass);
       ccsid int(10) options(*nopass);
     end-pr;

     dcl-pr sha256Enc extPgm('ENC256');
       clientID char(9999);
       secret char(100);
       sgnture char(64);
     end-pr;

     dcl-ds errDs qualified ;
       bytesprov int(10) inz(0) ;
       bytesavail int(10) inz(0) ;
     end-ds;

     dcl-ds erDs;
       bytesProvided int(10) inz(%size(erDs));
       bytesAvail int(10) inz(0);
       errMsgId char(7);
       reserved char(1);
       errMsg char(1024);
     end-ds;

     dcl-ds apiError likeds( qusec ) inz;

     dcl-s contentType char(100);
     dcl-s data char(5000);
     dcl-s handler char(12) inz;
     dcl-s message char(100);
     dcl-s passWord char(10);
     dcl-s pwdLen int(10) inz;
     dcl-s pwdCcsid int(10) inz(0);
     dcl-s reqMethod char(20);
     dcl-s rtnBuffer char(65535);
     dcl-s rtnLen int(10);
     dcl-s userName char(10);

     dcl-c crlf x'0d25';

     //*****************************************************************
     // MAINLINE
     //*****************************************************************

       exec sql set option commit = *none;

       // Get request method for web service
       reqMethod = %str(getEnv('REQUEST_METHOD'));

       // Setting header for the webservice
       data = 'Content-Type: text/plain' + crlf + crlf ;
       writeToWeb(data: %len(%trim( data )): errDS);

       if reqMethod = 'POST';
         // Get content type for web service
         contentType = %str(getEnv('CONTENT_TYPE'));

         if contentType = 'application/json';
           // Reading body data sent with webservice
           readStdInput(rtnBuffer: %size(rtnBuffer): rtnLen: apiError);

           if rtnBuffer <> *blanks;
             // Convert return data to ebcDic
             translate(%len(%trim(rtnBuffer)): rtnBuffer: 'QTCPEBC');

             // Parse username and password and validate it with system
             parseAndValidate();

             if message = 'Authenticated';
               genJwt(userName);
             endIf;
           endif;

         endIf;

       endIf;

       *inlr = *on;
     //*****************************************************************
     // parseAndValidate: Parse and validate username and password
     //*****************************************************************
       dcl-proc parseAndValidate;
       dcl-s bodyData varChar(10000);
       dcl-c lower const('abcdefghijklmnopqrstuvwxyz');
       dcl-c upper const('ABCDEFGHIJKLMNOPQRSTUVWXYZ');

         if rtnBuffer <> *blanks;

           bodyData = %trim(rtnBuffer);
           exec sql drop variable bodyData;

           exec sql create variable bodyData varChar(10000);

           exec sql set bodyData = trim(:bodyData);

           exec sql
             select userName, passWord
             into  :userName,:passWord
             from JSON_TABLE( bodyData, '$'
             columns(
               userName char(10) PATH '$.username',
               passWord char(10) PATH '$.password'
                    ) );

           if sqlcod = 0 and userName <> *blanks and passWord <> *blanks;
             userName = %xlate(lower: upper: userName);

             pwdLen = %len(passWord);

             validateUserProfile(userName: passWord: handler:
                                 erDs: pwdLen: pwdCcsid);

             // validating authentication
             if bytesAvail > 0;
               select;
               when errMsgId = 'CPF2203';
                   message = 'User profile' + %Trim(userName) + 'not correct';
               when errMsgId = 'CPF2204';
                   message = 'User profile' + %Trim(userName) + 'not found';
               when errMsgId = 'CPF22E3';
                   message = 'User profile' + %Trim(userName) + 'is disabled';
               when errMsgId = 'ÇPF22E2';
                   message = 'Password not correct for user profile' +
                               %Trim(userName);
               other;
                   message = 'Failed with Message ID' + %Trim(errMsgId);
               endSl;
             else;
               message = 'Authenticated';
             endIf;

           endIf;

         endIf;

       end-proc;
     //*****************************************************************
     // genJwt: Procedure to generate jwt access token
     //*****************************************************************
       dcl-proc genJwt;
       dcl-pi genJwt;
         userId char(10);
       end-pi;

       dcl-s base64Header_ascii varchar(500) CCSID(1208);
       dcl-s base64PayLoad_ascii varchar(500) CCSID(1208);
       dcl-s header varchar(500);
       dcl-s header_ascii varchar(500) CCSID(1208);
       dcl-s headerPayLoad char(9999);
       dcl-s jwtToken char(2000);
       dcl-s payLoad varchar(500);
       dcl-s payLoad_ascii varchar(500) CCSID(1208);
       dcl-s secretKey char(100);
       dcl-s signature char(64);
       dcl-s signature_ascii char(64) CCSID(1208);
       dcl-s signature_encoded char(64) CCSID(1208);

         exec sql call qsys2.qcmdExc('CHGJOB CCSID(37)');

         header_ascii = '{"alg":"HS256","typ":"JWT"}';
         exec sql set :base64Header_ascii =
           systools.base64encode( trim(:header_ascii) );

         // base64 encoded header
         header = base64Header_ascii;

         payLoad_ascii = '{"sub":"1234567890","name":' +
                       '"' + %trim(userId) + '","iat":1516239022}';
         exec sql set :base64payLoad_ascii =
           systools.base64encode( trim(:payLoad_ascii) );

         // base64 encoded payLoad
         payLoad = base64payLoad_ascii;

         payLoad = %subst(payLoad: 1: %len(payLoad)-2);

         headerPayLoad = %trim(header) + '.' + %trim(payLoad);
         secretKey = %char(%timestamp());

         sha256Enc(headerPayLoad: secretKey: signature);

         signature_ascii = signature;

         // base64 encoded header.payLoad
         exec sql set :signature_encoded =
           systools.base64encode( trim(:signature_ascii) );

         clear signature;
         signature = signature_encoded;

         jwtToken = %trim(header) + '.' + %trim(payLoad) + '.' +
                    %trim(signature);

         data = '{' + crlf + '"access_token":"' + %trim(jwtToken) +
                 '",' + crlf + '"token_type":"JWT",' +  crlf +
                 '"expires_in": 3600' + crlf +
                 '}';
         writeToWeb(data: %len(%trim( data )): errDS);
         jwtToken = 'JWT ' + %trim(jwtToken) ;

         exec sql
           insert into $JWTTOKEN ( userName, jwtToken )
           values ( :userId, :jwtToken );

       end-proc;
