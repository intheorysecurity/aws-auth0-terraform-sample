function remove(id, callback) {
    // This script remove a user from your existing database.
    // It is executed whenever a user is deleted from the API or Auth0 dashboard.
    //
    // There are two ways that this script can finish:
    // 1. The user was removed successfully:
    //     callback(null);
    // 2. Something went wrong while trying to reach your database:
    //     callback(new Error("my error message"));

    var request = require("request");

    var options = {
        method: 'POST',
        url: 'https://${auth0_domain}/oauth/token',
        headers: { 'content-type': 'application/json' },
        body: '{"client_id":"' + configuration.client_id + '","client_secret":"' + configuration.client_secret + '","audience":"https://auth0-jwt-authorizer","grant_type":"client_credentials"}'
    };

    request(options, function (error, response, body) {
        if (error) throw new Error(error);

        var jsonBody = JSON.parse(body);

        var options2 = {
            method: 'DELETE',
            url: '${awsAPIGatewayURL}users/' + id,
            headers: { 'content-type': 'application/json', 'Authorization': 'Bearer ' + jsonBody.access_token }
        };

        request(options2, function (error, response, body) {
            if (error) { callback(new Error(error)); }

            else { callback(null); }
        });
    });
}
