 // In this program two copybooks are used, first QUSEC is the system copybook which is used to detect error while write data on web.
 // Second base64_h is scott klement copybook which is used to convert base64 encoded data to ASCII format.
 // 'SetEnvIf Authorization "(.*)" HTTP_AUTHORIZATION=$1' this line should be added to http config file to get HTTP_AUTHORIZATION in our program.

**FREE
        ctl-opt dftActGrp(*no) bndDir('QC2LE':'USRBND');

        /copy qsysinc/qrpglesrc,qusec
        /copy qwebsrc,base64_h

        dcl-s data char(5000);
        dcl-s contentType char(100);
        dcl-s reqMethod char(20);
        dcl-s errMsg varchar(500)   ;
        dcl-s authName char(5000);
        dcl-c CRLF x'0d25';

     //External Procedure for writing data into browser
     // ------------------------------------------------------------- //
     // write to web                                                  //
     // ------------------------------------------------------------- //
        dcl-pr writeToWeb extproc('QtmhWrStout');
          dataVar char(65535) options(*varsize);
          dataVarLen int(10) const;
          errCode char(8000) options(*varsize);
        end-pr;

     //Procedure for getting environment variables
     // ------------------------------------------------------------- //
     // get environment                                               //
     // ------------------------------------------------------------- //
        dcl-pr getEnv pointer extproc('getenv');
          *n pointer value options(*string);
        end-pr;
        
     //Procedure for checking authorization
     // ------------------------------------------------------------- //
     // check authorization                                          //
     // ------------------------------------------------------------- //
        dcl-pr checkAuth char(5000);
          authName char(5000);
        end-pr;
     // ------------------------------------------------------------- //
     // translate: to convert ASCII to EBCDIC                         //
     // ------------------------------------------------------------- //
        dcl-pr translate extPgm('QDCXLATE');
          length packed(5:0) const;
          data char(32766) options(*varsize);
          table char(10) const;
        end-pr;

        dcl-ds errDs qualified ;
          bytesProv int(10) inz(0) ;
          bytesAvail int(10) inz(0) ;
        end-ds;

     //MAIN PROGRAM

        reqMethod = %Str(getEnv('REQUEST_METHOD'));
        data = 'Content-type: text/plain' + CRLF + CRLF ;
        writeToWeb(data: %len(%trim( data )): errDS);
        
        authName = %Str(getEnv('HTTP_AUTHORIZATION'));
        if authName <> *blanks;
          authName = checkAuth(authName);
        endif;
        
        return;


      // Procedure for checking authorization
      // ------------------------------------------------------------- //
      // check authorization                                           //
      // ------------------------------------------------------------- //
         dcl-proc checkAuth ;
           dcl-pi *n char(5000);
             authName char(5000);
           end-pi;
           dcl-pr authuser extPgm('AUTHUSER');
             userId char(10);
             passwd char(10);
             Message char(50);
           end-pr;
           dcl-s lenpos int(3);
           dcl-s userId char(10);
           dcl-s passwd char(10);
           dcl-s Message char(50);
           dcl-s encString char(100) inz;
           dcl-s base64EncLength int(10:0);

           lenpos = %checkr(' ':authName);
           authName = %subst(authName:7:lenpos);

        // base64 decoding of authName
           base64EncLength = base64_decode( %addr(authName)
                                            : %len(%trim(authName))
                                            : %addr(encString)
                                            : %size(encString));
           authName = encString;
        // converting authName ASCII to EBCDIC
           if authName <> *blanks;
             translate(%len(%trim(authName)):authName:'QTCPEBC');
           endif;

        // spliting userid and password
           lenpos = %scan(':':authName);
           userId = %subst(authName:1:lenpos-1);
           passWd = %subst(authName:lenpos + 1);

        // For validating user id and password
           authuser(userId: passWd: message);

           message = message ;
           writeToWeb(message: %len(%trim( message )): errDS);
           return authName;
         end-proc;
