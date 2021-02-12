
##**Web Service** 
----------------

  A Web service is a way for two machines to communicate with each other over a `network.`
 
**API(Application Programming Interface)** 
-------------------------------------------

  A set of definitions and protocols that allow one application to communicate with another application.
  Mostly we deal with web APIs only which are nothing but web services only. But there are APIs also used wihtout network connection. 

> _All web services are API, not all APIs are web service._

**REST API** 
----------------

  A REST API is a standardized architecture style for creating a Web Service API. One of the requirements to be a REST API is 
  the utilization of HTTP methods to make a request over a network.
  
  REST APIs are a standardized architecture for building web APIs using HTTP methods.

**API request** 
----------------
  
  - An API request allows you to retrieve data from a data source, or to send data. 
  - Http reruest methods [GET, POST, PUT, DELETE]. Detailed reading from [MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods) 
  

  ![Rest_API_Architecture](https://phppot.com/wp-content/uploads/2015/10/restful-web-services-api-architecture.jpg)
    
 A REST request from the client to the server usually consists of the following components
     
  1. URL Path [https://api.example.com/user]
  1. HTTP Method [GET, PUT, POST, PATCH, DELETE]
  1. Header – (optional) additional information that the client needs to pass along in the request such as Authorization credentials, Content-Type of the body, User-Agent to define what type of application is making the request, and more]
  1. Parameters – (optional) variable fields that alter how the resource will be returned.
  1. Body – (optional) contains data that needs to be sent to the server.
    
**API response** 
----------------

  HTTP Response is the packet of information sent by Server to the Client in response to an earlier request made by the client. 
  
A response from the server to the client usually consists of the following components

  1. A Status-line
  2. Zero or more header (General|Response|Entity) fields followed by CRLF
  3. An empty line (i.e., a line with nothing preceding the CRLF) indicating the end of the header fields
  4. Optionally a message-body
   
   ![Response_Headers](https://toolsqa.com/wp-content/gallery/restapi/Response-Status-Line.png)
   
**HTTP Status Codes** 
----------------
   
  - 1xx: Informational
  - 2xx: Success
  - 3xx: Redirection
  - 4xx: Client Error
  - 5xx: Server Error
  
  Detailed information on [MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)
  
  [Begineer level video tutorial](https://www.youtube.com/watch?v=GZvSYJDk-us)
  
  [REST API for learning purpose](https://gorest.co.in/) 
 
***Resource used to gather this information:***
  - https://www.smashingmagazine.com/2018/01/understanding-using-rest-api/
  - https://rapidapi.com/blog/api-vs-web-service/
