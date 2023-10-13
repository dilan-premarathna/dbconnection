import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/http;
import ballerina/sql;
import ballerina/io;

//Variables for MySQL database connection
configurable string mdhHost = ?;
configurable string mdhUser = ?;
configurable string mdhPassword = ?;
configurable string mdhDatabase = ?;
configurable int mdhPort = ?;

//Get MySql database connection
mysql:Client mdhEndpoint = check new (host = mdhHost, user = mdhUser, password = mdhPassword, database = mdhDatabase, port = mdhPort);

//Test connection
type TestTable record {
    string? messageType;
    string? vendorType;
};

//Create generic order flag type
type GenericOrderFlag record {
    string messagetype;
    string vendortype;
    string msdnumber;
};

//Create generic order type for all incoming orders
type GenericOrder record {
    GenericOrderFlag Flag;
    json Order;
};

service /KeyplexoLenovoClient on new http:Listener(9090) {

    //Single endpoint for all incoming message types
    resource function get result() returns json|error|sql:ExecutionResult {
        io:println("Resource invocke ");
        sql:ParameterizedQuery query = `SELECT * FROM TempTestTable`;
        io:println("Query: ", query);
        sql:ExecutionResult result = check mdhEndpoint->execute(query);
        io:print("result: ", result);
        return result;
    }

    //Test the connection of the API to MySql database
    resource function post TestConnection(@http:Payload TestTable payload) returns json|error {
        sql:ProcedureCallResult callResponse = check mdhEndpoint->call(`call usp_TempTestTableInsertion(${payload.messageType}, ${payload.vendorType}, ${payload.toString()})`);
        json resp = {"MessageResponse": "Success"};
        check callResponse.close();
        return resp;
    }
}
