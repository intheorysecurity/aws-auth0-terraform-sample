terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "0.30.2"
    }
  }
}

resource "auth0_resource_server" "my_resource_server" {
  name        = "Auth0 JWT API"
  identifier  = "https://auth0-jwt-authorizer"
  signing_alg = "RS256"

  scopes {
    value       = "read:users"
    description = "Read Users"
  }

  scopes {
    value       = "create:users"
    description = "Create Users"
  }

  scopes {
    value       = "delete:users"
    description = "Delete Users"
  }

  scopes {
    value       = "validate:users"
    description = "Validate Users"
  }

  allow_offline_access                            = false
  token_lifetime                                  = 86400
  skip_consent_for_verifiable_first_party_clients = true
}

resource "auth0_client" "my_client" {
  name        = "Application - API Test"
  description = "Test Applications for custom database demo"
  app_type    = "non_interactive"
  grant_types = ["client_credentials"]
}

resource "auth0_client_grant" "my_client_grant" {
  client_id = auth0_client.my_client.id
  audience  = auth0_resource_server.my_resource_server.identifier
  scope     = ["create:users", "read:users", "delete:users", "validate:users"]
}

//Auth0 Custom Database
resource "auth0_connection" "my_connection" {
  name     = "Example-Connection"
  strategy = "auth0"
  options {
    password_policy = "good"
    password_history {
      enable = true
      size   = 3
    }
    enabled_database_customization = "true"
    custom_scripts = {
      create          = templatefile("${path.module}/methods/create.js", { auth0_domain = "${var.auth0_domain}", awsAPIGatewayURL = "${var.awsAPIGatewayURL}" })
      verify          = templatefile("${path.module}/methods/verify.js", { auth0_domain = "${var.auth0_domain}", awsAPIGatewayURL = "${var.awsAPIGatewayURL}" })
      get_user        = templatefile("${path.module}/methods/getUser.js", { auth0_domain = "${var.auth0_domain}", awsAPIGatewayURL = "${var.awsAPIGatewayURL}" })
      login           = templatefile("${path.module}/methods/login.js", { auth0_domain = "${var.auth0_domain}", awsAPIGatewayURL = "${var.awsAPIGatewayURL}" })
      delete          = templatefile("${path.module}/methods/delete.js", { auth0_domain = "${var.auth0_domain}", awsAPIGatewayURL = "${var.awsAPIGatewayURL}" })
      change_password = templatefile("${path.module}/methods/changePassword.js", { auth0_domain = "${var.auth0_domain}", awsAPIGatewayURL = "${var.awsAPIGatewayURL}" })
    }
    configuration = {
      "client_id"     = auth0_client.my_client.client_id
      "client_secret" = auth0_client.my_client.client_secret
    }
  }
}

output "auth0_application_client_id" {
  value = auth0_client.my_client.client_id
}

output "auth0_application_client_secret" {
  value = auth0_client.my_client.client_secret
}