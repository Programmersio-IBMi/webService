--  BSON AND JSON 
set  gajender.aaa = '{"empno" :"12345", "name": "Random", "pay": {"salary": 12345}}' ;
set schema gajender;

drop table t1;

create table t1 (c1 varchar(300));

create table t1 (c1 BLOB(512) INLINE LENGTH 512);

INSERT INTO t1 VALUES ( '{"empno" :"12345", "name": "Random", "pay": {"salary": 12345}}' );

INSERT INTO t1 VALUES ( JSON_TO_BSON('{"empno" :"12345", "name": "Random", "pay": {"salary": 12345}}' ));

CREATE VARIABLE BSONVAR VARBINARY(2000);

SELECT BSON_TO_JSON(C1)  FROM T1 ;

SELECT C1 FROM T1 ;

SET BSONVAR = 'SELECT C1 FROM T1';


--

drop variable gajender.jsonData ;

create variable gajender.jsonData varchar(10000);

set gajender.jsonData = '{"name":"Pankaj Sharma","age":23,"mobno":9123453213,"dept":"RPG"}';

select name,age, mobnumber,department                             
from  JSON_TABLE(gajender.jsondata, '$'      
      Columns(                                 
      name varchar(50) path '$.name',          
      age decimal(2) path '$.age',      
      mobnumber decimal(10) path '$.mobno',
      department char(10) path '$.dept' ) ) as parsedJson;
      


drop variable gajender.jsonData ; 

create variable gajender.jsonData varchar(10000); 
  
set gajender.jsonData = '{"name":"Pankaj Sharma","age":23,"mobno":9123453213,"dept":{"LANG":"RPG"}}';

values(gajender.jsonData);

select *                        
from  JSON_TABLE(gajender.jsondata, '$'      
      Columns(                                 
      name varchar(50) path '$.name',          
      age decimal(2) path '$.age',      
      mobnumber decimal(10) path '$.mobno',
      department char(10) format json path '$.dept' )) ;


drop variable gajender.jsonData ; 

create variable gajender.jsonData varchar(10000); 
  
set gajender.jsonData = '{"employee":[{"name":"Pankaj Sharma","age":23,"mobno":9123453213,"dept":"RPG"},{"name":"Karan Sharma","age":24,"mobno":9123432213,"dept":"CBL"}]}';

select *                         
from  JSON_TABLE(gajender.jsondata, '$'      
      Columns( nested '$.employee[*]' 
      columns (
      name varchar(50) path '$.name',          
      age decimal(2) path '$.age',      
      mobnumber decimal(10) path '$.mobno',
      department char(10) path '$.dept'  ) ) ) as parsedJson;
      
