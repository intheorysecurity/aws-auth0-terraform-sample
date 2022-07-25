function login(email, password, callback) {


    var request = require("request");
    //added
    var bcrypt = require("bcrypt@5.0.1");

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
            method: 'POST',
            url: '${awsAPIGatewayURL}verify',
            headers: { 'content-type': 'application/json', 'Authorization': 'Bearer ' + jsonBody.access_token },
            body: '{"username": "' + email + '"}'
        };

        request(options2, function (error, response, body) {
            if (error) throw new Error(error);

            var userObject = JSON.parse(body);
            if (userObject.Items[0].password) {
                //compare hash with given password
                bcrypt.compare(password, userObject.Items[0].password, function (err, isMatch) {
                    if (isMatch) {
                        var options2 = {
                            method: 'GET',
                            url: '${awsAPIGatewayURL}users/' + email,
                            headers: { 'content-type': 'application/json', 'Authorization': 'Bearer ' + jsonBody.access_token }
                        };

                        request(options2, function (error, response, body) {
                            if (error) {
                                return callback(new Error(error));
                            }
                            var userObject = JSON.parse(body);

                            if (userObject.Count === 1) {
                                return callback(null, {
                                    id: userObject.Items[0].id,
                                    email: userObject.Items[0].username,
                                    given_name: userObject.Items[0].givenname,
                                    family_name: userObject.Items[0].surname,
                                    email_verified: userObject.Items[0].email_verified,
                                    app_matadata: {
                                        "perferMFA": userObject.Items[0].perferMFA
                                    }
                                });
                            }
                        })
                    }
                    else {
                        callback(new Error("Invalid username/password"));
                    }
                });
            }
        });
    });
}