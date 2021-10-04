     H DFTACTGRP(*NO)
     H debug
      */
     d iconv_t         DS                  qualified
     d                                     based(StructureTemplate)
     d   return_value                10I 0
     d   cd                          10I 0 dim(12)

     d QtqCode_T       DS                  qualified
     d  CCSID                        10I 0 inz
     d  ConvAlt                      10I 0 inz
     d  SubsAlt                      10I 0 inz
     d  ShiftAlt                     10I 0 inz
     d  InpLenOp                     10I 0 inz
     d  ErrorOpt                     10I 0 inz
     d  Reserved                      8A   inz(*ALLx'00')

     d iconv_code_t    DS                  qualified
     d  owner                         8a   inz('IBMCCSID')
     d  CCSID                         5a   inz('00000')
     D  ReservedTo
     d   ConvAlt                      3a   inz('000')
     D                                     overlay(ReservedTo)
     d   SubsAlt                      1a   inz('0')
     D                                     overlay(ReservedTo:*next)
     d   ShiftAlt                     1a   inz('0')
     D                                     overlay(ReservedTo:*next)
     d   InpLenOpt                    1a   inz('0')
     D                                     overlay(ReservedTo:*next)
     d   ErrorOpt                     1a   inz('0')
     D                                     overlay(ReservedTo:*next)
     d   ReservedFrom                12A   inz(*ALLx'00')
     D                                     overlay(ReservedTo:*next)

     D translate       pr                  extpgm('QDCXLATE')
     D length                         5P 0 const
     D data                       32766A   options(*varsize)
     D table                         10A   const

     d QtqIconvOpen    PR                  extproc('QtqIconvOpen')
     d                                     like(iconv_t)
     d    toCode                           likeds(QtqCode_t) const
     d    fromCode                         likeds(QtqCode_t) const

     D iconv_open      PR                  extproc('iconv_open')
     D                                     like(iconv_t)
     D   toCode                            like(iconv_code_t) const
     D   fromCode                          like(iconv_code_t) const

     d iconv           PR            10U 0 extproc('iconv')
     d   cd                                like(iconv_t) value
     d   inbuf                         *
     d   inbytesleft                 10U 0
     d   outbuf                        *
     d   outbytesleft                10U 0

     d QlgTransformUCSData...
     d                 PR            10U 0 extproc('QlgTransformUCSData')
     d   xformtype                   10i 0 value
     d   inbuf                         *
     d   inbytesleft                 10U 0
     d   outbuf                        *
     d   outbytesleft                10U 0
     d   outspacereq                 10U 0

     D ICONV_FAIL      C                   CONST(4294967295)

     D iconv_close     PR            10I 0 extproc('iconv_close')
     D   cd                                like(iconv_t) value
      *----------------------------------------

     d from37          s           9999a
     d from37len       s             10u 0
     D outputbuf       s           9999a
     D outputlen       s             10u 0

     d source          ds                  likeds(QtqCode_t)
     d                                     inz(*likeds)
     d target          ds                  likeds(QtqCode_t)
     d                                     inz(*likeds)
     d toEBC           ds                  likeds(iconv_t)

     D p_input         s               *
     D p_output        s               *
     D inputleft       s             10u 0
     D outputleft      s             10u 0
     D data            s           1000a
     d KeyLength       s             10u 0

      *-------------hash parms----------------
     d binaryHMAC      s             32a
     d SHA_256         c                   const(3)
     D DataLen         s             10u 0
     d dataToHash      s           9999a
     d $hex            s             64a
     d Nullfield       s            100a
     d MySalt          s             64a
     D SaltLen         s             10u 0
      *---------------------------------------------------------------------
      * Stand Alone Fields - BOTTOM
      *---------------------------------------------------------------------
     D ErrorCode       DS                  qualified
     D    bytesProv                  10i 0 inz(0)
     D    bytesAvail                 10i 0 inz(0)

     D WsErrorCode     DS                  qualified
     D    bytesProv                  10i 0 inz(0)
     D    bytesAvail                 10i 0 inz(0)

     D my_key          DS                  qualified
     D    Type                       10i 0 inz(SHA_256)
     D    Len                        10i 0
     D    Fmt                         1a   inz('0')
     D                                3a
     D    Value                      64a

     d cvthc           PR                  ExtProc('cvthc')
     d   target                   65534A   options(*varsize)
     d   src_bits                 32767A   options(*varsize) const
     d   tgt_length                  10I 0 value

     D GetHMAC         PR                  ExtProc('Qc3CalculateHMAC')
     D  datatohash                 9999a   const options(*varsize)
     D  pinDataLen                   10i 0 const
     D  pinFormat                     8a   const
     D  palgDesc                     10i 0 const
     D  palgDescFmt                   8a   const
     D  pkeyDesc                  32767a   const options(*varsize)
     D  pkeyDescFmt                   8a   const
     D  pcryptoProv                   1a   const
     D  pcryptoDev                   10a   const
     D  pHMAC                        64a         options(*varsize)
     D  pErrorCode                32767a         options(*varsize)

     D                 pi
     D ClientID                    9999a
     D Secret                       100a
     D sgnture                       64a

      /FREE
       //data to hash
       from37 = ClientID;

       //data to hash length
       from37len = %len(%trim(from37));

        // set conversion from 37 to 1208
        // -----------------------------------------------

        source.CCSID = 37;
        target.CCSID = 1208;
        toEBC = QtqIconvOpen( target: source );

        if (toEBC.return_value = -1);
           // handle error...
        endif;

        // -----------------------------------------------
        //   Translate data.
        //
        //   the iconv() API will increment/decrement
        //   the pointers and lengths, so make sure you
        //   do not use the original pointers...
        // -----------------------------------------------

        p_input  = %addr(from37);
        inputleft = from37len;

        p_output = %addr(outputbuf);
        outputleft = %size(outputbuf);

        iconv( toEBC
             : p_input
             : inputleft
             : p_output
             : outputleft );

        // -----------------------------------------------
        //  if needed, you can calculate the length of
        //  the decoded data by subtracting the amount
        //  of space left in the buffer from the total
        //  buffer size.
        //
        //  At this point, 'outputbuf' should contain
        //  the EBCDIC data.
        // -----------------------------------------------

        outputlen = %size(outputbuf) - outputleft;
        DataToHash   = %subst(outputbuf:1:outputlen);
        DataLen = outputlen;
        //dump;

       //encode the hash key per API doc
       //The minimum length for an SHA-256 HMAC key is 32 bytes

       //hash key len
        from37len = %len(%trimr(Secret));
        if from37len < 32;
          from37len = 32 ;
        endif;
        clear outputbuf;
        p_input  = %addr(Secret);
        inputleft = from37len;

        p_output = %addr(outputbuf);
        outputleft = %size(outputbuf);

        iconv( toEBC
             : p_input
             : inputleft
             : p_output
             : outputleft );

        outputlen = %size(outputbuf) - outputleft;
        KeyLength = %len(%trim(Secret));
        MySalt = %subst(outputbuf:1:KeyLength);
        SaltLen = outputlen;
        //dump;

        // -----------------------------------------------
        //  you can call iconv() many more times if you
        //  want, using the same 'toEBC' table for
        //  translation.
        //   - -
        //  when you are completely done, call iconv_close()
        //  to free up memory.
        // -----------------------------------------------

        iconv_close(toEBC);
        //---------------------------------------------------------
        //            Calculate the SHA-256 HMAC hash
        //---------------------------------------------------------

        Nullfield = *allx'00';

        my_key.value = %TRIMR(MySalt) + Nullfield;

        my_key.len   =  SaltLen;

        monitor;
              GetHMAC( DataToHash
                          : DataLen
                          : 'DATA0100'
                          : SHA_256
                          : 'ALGD0500'
                          :  my_key
                          : 'KEYD0200'
                          : '0'
                          : *blanks
                          : binaryHMAC
                          : ErrorCode );
        on-error;
          WsErrorCode = ErrorCode;
          Dsply 'Error in Conversion';
        endmon;

        cvthc( $hex: binaryHMAC: %len(binaryHMAC)*2);
        sgnture = $hex ;
        //review the dump spool file to see HMAC in $hex parm
        dump;
        *inlr = '1';
        return;

        /end-free
