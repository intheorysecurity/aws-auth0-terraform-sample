function create(user, callback) {
  function isEmail(data) {
    const re =
      /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@(([[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(String(data).toLowerCase());
  }

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

    var uuid = Math.random().toString(36).slice(2);

    const saltRounds = 10;
    bcrypt.genSalt(saltRounds, function (err, salt) {
      if (err) { throw new Error(err); }
      bcrypt.hash(user.password, salt, function (err, hash) {
        if (err) { throw new Error(err); }

        var options2 = {
          method: 'PUT',
          url: '${awsAPIGatewayURL}users',
          headers: { 'content-type': 'application/json', 'Authorization': 'Bearer ' + jsonBody.access_token },
          body: '{"id": "' + uuid + '", "username": "' + user.email + '","password":"' + hash + '"}' //added
        };

        request(options2, function (error, response, body) {
          if (error) {
            //throw new Error(error)
            return callback(Error("Something wrong happened"));
          }
          return callback(null);
        });
      });
    });


  });
}