 // SOURCE CODE:

H DFTACTGRP(*NO) ACTGRP(*NEW) BNDDIR('QC2LE':'YASH/YASHWANT')
*---------Procedure declaration for write data on web-----------*
Dwritetoweb       pr                  extproc('QtmhWrStout')
D Datavar                    65535A   Options(*varsize)
D Datavarlen                    10I 0 const
D Errorcode                   8000A   Options(*Varsize)
*-------Error data structure used as a parameter for errcode----*
DErrDs            ds                  qualified
D BytesProv                     10I 0 Inz(0)
D BytesAvail                    10I 0 Inz(0)
* 
D CRLF            C                   x'0d25'
D DATA            S           5000A
*--------------Main Program---------------*
/Free
    // setting up header
    DATA = 'Content-type: Text/html' + CRLF + CRLF ;
    writetoweb(DATA: %len(%trim(DATA)): ErrDs);

    DATA = 'This data will written on web'+ CRLF;
    writetoweb(DATA: %len(%trim(DATA)): ErrDs);

    DATA = 'Hey Yashwant, Welcome to the web services';
    writetoweb(DATA: %len(%trim(DATA)): ErrDs);

    *Inlr = *On;
    Return;
/End-Free
