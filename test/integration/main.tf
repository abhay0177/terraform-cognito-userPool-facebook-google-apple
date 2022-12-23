provider "aws" {
  region = "us-east-1"
}

module "cognito" {
  source = "../.."
  tags = {
    application = "test-app"
  }
  pool_name          = "test"
  client_name        = "test"
  domain             = "test-12-435-645-com"
  callback_urls      = ["https://localhost:3000"]
  logout_urls        = ["https://localhost:3000"]
  #facebook_client_id = "test"
  #facebook_secret_id = "test"
  #facebook_scopes    = "email"
  #google_client_id   = "test"
  #google_secret_id   = "test"
  #google_scopes      = "email"
  #apple_client_id    = "test"
  #apple_team_id      = "test"
  #apple_key_id       = "test"
  #apple_private_key  = "test"
  #apple_scopes       = "email"
}
