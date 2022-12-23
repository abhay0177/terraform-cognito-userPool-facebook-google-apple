resource "aws_cognito_user_pool" "cognito_user_pool" {
  name = var.pool_name

  schema {
    attribute_data_type      = "String"
    mutable                  = true
    name                     = "email"
    required                 = true
    developer_only_attribute = false
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }

  schema {
    attribute_data_type      = "String"
    mutable                  = true
    name                     = "phone_number"
    required                 = true
    developer_only_attribute = false
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }

  schema {
    attribute_data_type      = "String"
    mutable                  = true
    name                     = "name"
    required                 = true
    developer_only_attribute = false
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }

  password_policy {
    minimum_length                   = "8"
    require_lowercase                = false
    require_numbers                  = false
    require_symbols                  = false
    require_uppercase                = false
    temporary_password_validity_days = 7
  }

  mfa_configuration        = "OFF"
  alias_attributes         = ["email", "phone_number"]
  auto_verified_attributes = ["email"]

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  tags = var.tags
}

resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id
  domain       = var.domain
}

resource "aws_cognito_identity_provider" "facebook" {
  user_pool_id  = aws_cognito_user_pool.cognito_user_pool.id
  provider_name = "Facebook"
  provider_type = "Facebook"

  provider_details = {
    client_id                       =  var.facebook_client_id
    client_secret                   =  var.facebook_secret_id
    authorize_scopes                =  var.facebook_scopes
    "api_version"                   = "v12.0"
    "attributes_url"                = "https://graph.facebook.com/v12.0/me?fields="
    "attributes_url_add_attributes" = "true"
    "authorize_url"                 = "https://www.facebook.com/v12.0/dialog/oauth"
    "token_request_method"          = "GET"
    "token_url"                     = "https://graph.facebook.com/v12.0/oauth/access_token"
  }

  attribute_mapping = {
    "username"     = "id"
    "email"        = "email"
    "name"         = "name"
    "gender"       = "gender"
    "picture"      = "picture"
    "given_name"   = "first_name"
    "phone_number" = "phone_number"
  }
}

resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = aws_cognito_user_pool.cognito_user_pool.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    client_id                       = var.google_client_id
    client_secret                   = var.google_secret_id
    authorize_scopes                = var.google_scopes
    "attributes_url"                = "https://people.googleapis.com/v1/people/me?personFields="
    "attributes_url_add_attributes" = "true"
    "authorize_url"                 = "https://accounts.google.com/o/oauth2/v2/auth"
    "oidc_issuer"                   = "https://accounts.google.com"
    "token_request_method"          = "POST"
    "token_url"                     = "https://www.googleapis.com/oauth2/v4/token"
  }

  attribute_mapping = {
    "username"     = "sub"
    "email"        = "email"
    "name"         = "name"
    "gender"       = "genders"
    "picture"      = "picture"
    "given_name"   = "given_name"
    "phone_number" = "phone_number"
  }
}

resource "aws_cognito_identity_provider" "apple" {
  user_pool_id  = aws_cognito_user_pool.cognito_user_pool.id
  provider_name = "SignInWithApple"
  provider_type = "SignInWithApple"

  provider_details = {
    client_id                        = var.apple_client_id
    team_id                          = var.apple_team_id
    key_id                           = var.apple_key_id
    private_key                      = var.apple_private_key
    authorize_scopes                 = var.apple_scopes
    "attributes_url_add_attributes"  = "true"
    "oidc_issuer"                    = "https://appleid.apple.com"
    "authorize_url"                  = "https://appleid.apple.com/auth/authorize"
    "token_request_method"           = "POST"
    "token_url"                      = "https://appleid.apple.com/auth/token" 
  }

  attribute_mapping = {
    email               = "email"
    preferred_username  = "name"
    username            = "sub"
    name                = "name"
    phone_number        = "phone_number"
  }
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id

  name                   = var.client_name
  refresh_token_validity = 30
  read_attributes        = ["email", "name", "given_name", "phone_number"]
  write_attributes       = ["email", "name", "picture", "phone_number", "given_name"]

  supported_identity_providers = ["Facebook", "Google", "SignInWithApple"]
  callback_urls                = var.callback_urls
  logout_urls                  = var.logout_urls

  depends_on = [aws_cognito_identity_provider.facebook, aws_cognito_identity_provider.google, aws_cognito_identity_provider.apple]

  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes = [
    "aws.cognito.signin.user.admin",
    "email",
    "openid",
    "phone",
    "profile"
  ]
  explicit_auth_flows = [
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}
