const AWS = require("aws-sdk");

const dynamo = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event, context) => {
  let body;
  let statusCode = 200;
  const headers = {
    "Content-Type": "application/json"
  };

  try {
    let requestJSON;
    switch (event.routeKey) {
      case "DELETE /users/{id}":
        await dynamo
          .delete({
            TableName: "sample-users-table",
            Key: {
              id: event.pathParameters.id
            }
          })
          .promise();
        body = `Deleted item ${event.pathParameters.id}`;
        break;
      case "GET /users/{id}":
        var params = {
          TableName: "sample-users-table",
          FilterExpression: "id = :id OR username=:id",
          ExpressionAttributeValues: {
            ":id": event.pathParameters.id
          },
          ProjectionExpression: "id, username, givenname, surname, email_verified, perferMFA"
        }
        body = await dynamo.scan(params).promise();
        break;
      case "PUT /users/{id}":
        requestJSON = JSON.parse(event.body);
        var params = {
          TableName: "sample-users-table",
          FilterExpression: "id = :id OR username=:id",
          ExpressionAttributeValues: {
            ":id": event.pathParameters.id
          },
          ProjectionExpression: "id"
        }
        body = await dynamo.scan(params).promise();
        params = {
          TableName: "sample-users-table",
          Key: { "id": body.Items[0].id },
          UpdateExpression: "set password = :p",
          ExpressionAttributeValues: {
            ":p": requestJSON.password
          },
        };
        body = await dynamo.update(params).promise();
        break;
      case "GET /users":
        var params = {
          TableName: "sample-users-table",
          ProjectionExpression: "id, username, givenname, surname, email_verified, perferMFA",
          Select: "SPECIFIC_ATTRIBUTES"
        }
        body = await dynamo.scan(params).promise();
        break;
      case "PUT /users":
        requestJSON = JSON.parse(event.body);
        await dynamo
          .put({
            TableName: "sample-users-table",
            Item: {
              id: requestJSON.id,
              username: requestJSON.username,
              givenname: requestJSON.givenname,
              surname: requestJSON.surname,
              email_verified: requestJSON.email_verified,
              perferMFA: requestJSON.perferMFA,
              password: requestJSON.password   //added for password
            }
          })
          .promise();
        body = `User, ${requestJSON.username}, created successfully`;
        statusCode = 201;
        break;
      case "POST /users":
        statusCode = 201;
        break;
      case "POST /verify":
        requestJSON = JSON.parse(event.body);
        if (requestJSON.username) {
          var params = {
            TableName: "sample-users-table",
            FilterExpression: "id = :id OR username=:id",
            ExpressionAttributeValues: {
              ":id": requestJSON.username
            },
            ProjectionExpression: "password"
          }
          body = await dynamo.scan(params).promise();
        }
        else {
          throw new Error('Invalid username/pasword');
        }
        break;
      case "POST /changepassword/{id}":
        requestJSON = JSON.parse(event.body);
        var params = {
          TableName: "sample-users-table",
          FilterExpression: "id = :id OR username=:id",
          ExpressionAttributeValues: {
            ":id": event.pathParameters.id
          },
          ProjectionExpression: "id"
        }
        body = await dynamo.scan(params).promise();
        params = {
          TableName: "sample-users-table",
          Key: { "id": body.Items[0].id },
          UpdateExpression: "set password = :p",
          ExpressionAttributeValues: {
            ":p": requestJSON.password
          },
        };
        body = 'User password has been updated';
        break;
      default:
        throw new Error(`Unsupported route: "${event.routeKey}"`);
    }
  } catch (err) {
    statusCode = 400;
    body = err.message;
  } finally {
    body = JSON.stringify(body);
  }

  return {
    statusCode,
    body,
    headers
  };
};