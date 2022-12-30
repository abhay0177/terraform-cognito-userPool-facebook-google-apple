# terraform-cognito

## Simple Terraform module to configure Cognito User Pools
This is an initial work, for now this module does not accept many configurations and a lot is fixed, but pull requests are welcome.

## Details
- Facebook, Google and Apple configured

### Usage
How to use it can be seen [here](test/integration/main.tf)
https://docs.aws.amazon.com/cognito-user-identity-pools/latest/APIReference/API_CreateIdentityProvider.html

###Important
IF alias_attribute is not working the you can use "username_attributes"
username_attributes = "email, phone_number"
