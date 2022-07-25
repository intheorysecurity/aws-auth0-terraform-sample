function changePassword(email, newPassword, callback) {
    // This script should change the password stored for the current user in your
    // database. It is executed when the user clicks on the confirmation link
    // after a reset password request.
    // The content and behavior of password confirmation emails can be customized
    // here: https://manage.auth0.com/#/emails
    // The `newPassword` parameter of this function is in plain text. It must be
    // hashed/salted to match whatever is stored in your database.
    //
    // There are three ways that this script can finish:
    // 1. The user's password was updated successfully:
    //     callback(null, true);
    // 2. The user's password was not updated:
    //     callback(null, false);
    // 3. Something went wrong while trying to reach your database:
    //     callback(new Error("my error message"));
    //
    // If an error is returned, it will be passed to the query string of the page
    // where the user is being redirected to after clicking the confirmation link.
    // For example, returning `callback(new Error("error"))` and redirecting to
    // https://example.com would redirect to the following URL:
    //     https://example.com?email=alice%40example.com&message=error&success=false

    var request = require("request");
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

        const saltRounds = 10;
        bcrypt.genSalt(saltRounds, function (err, salt) {
            if (err) { throw new Error(err); }
            bcrypt.hash(newPassword, salt, function (err, hash) {
                if (err) { throw new Error(err); }

                var options2 = {
                    method: 'POST',
                    url: '${awsAPIGatewayURL}changepassword/' + email,
                    headers: { 'content-type': 'application/json', 'Authorization': 'Bearer ' + jsonBody.access_token },
                    body: '{"password": "' + hash + '"}'
                };

                request(options2, function (error, response, body) {
                    if (error) {
                        return callback(null, false);
                    }

                    else {
                        return callback(null, true);
                    }
                });

            });
        });


    });
}
