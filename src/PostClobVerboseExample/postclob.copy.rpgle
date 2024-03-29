**Free
       dcl-pr postClobV extPgm('POSTCLOBV');
         email  char(30);
         name   char(25);
         gender char(10);
         status char(10);
       end-pr;

       dcl-pr postClob_t extpgm('POSTCLOB_T');
         email  char(30);
         name   char(25);
         gender char(10);
         status char(10);
       end-pr;

       dcl-pr system zoned(10:0) extproc('system');
         szcmd pointer Value Options(*String);
       end-pr;

       dcl-s body Char(200);
       dcl-s command Char(200);
       dcl-s messageText varchar(32740);
       dcl-s messageLength int(5);
       dcl-s responseMsg Varchar(9999);
       dcl-s responseHeader Varchar(1000);
       dcl-s responsePos Packed(4);
       dcl-s returnedSQLCode char(5);
       dcl-s tokenheader Char(500);
       dcl-c fail const('FAIL');
       dcl-c pass const('PASS');
       dcl-c rcd const('Record Not Found');
       dcl-c tokenKey const('Bearer 7b5c1de0f0e3885c6101f18a5b13+
                        de749ac0fb6b008276af56c1b767107c0f03');
       dcl-c url const('https://gorest.co.in/public-api/users');
