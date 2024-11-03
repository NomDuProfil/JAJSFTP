# JAJSFTP

## Description

This project aims to create an SFTP server with storage in an S3 bucket within AWS. Although AWS offers this service (https://aws.amazon.com/aws-transfer-family/pricing/), the solution presented here is more cost-effective. It relies on a `t4g.nano` server, which is very inexpensive due to its low power.

Once the server is deployed, all connection information will be sent by email.

## Declaration and Deployment

⚠️ Before you begin, check your `provider.tf` file to ensure that you can store your `tfstate` correctly.

⚠️ **During the installation, an email from Amazon will be sent to confirm the legitimacy of your email address. Until this is validated, the installation will be blocked.**

In the `jajsftp.tf` file, you can declare your configuration as follows:

```terraform
module "jajsftp" {
  source = "./modules/jajsftp"
  name   = "JAJSFTP"
  admin_whitelist = [
    "12.12.12.12"
  ]
  admin_username = "admin"
  admin_email    = "jajemail@jajdomain.com"
}

```

### Some Explanations:

- `name`: This is the name of your project. The resources created will use this name.
- `admin_whitelist`: The list of IP addresses allowed to access the SFTP.
- `admin_username`: The username for logging into the SFTP.
- `admin_email`: The email address to receive login information.

Once the module is configured, you can run Terraform:

```bash
terraform init
terraform plan
terraform apply
```

If you have successfully verified your email identity through Amazon, you should receive the email containing the information within 5 to 10 minutes.

## If You Do Not Want to Use Terraform

You can use this bash script to deploy the server manually by using [install_script.sh.tpl](./modules/jajsftp/install_script.sh.tpl). Just replace the variables as follows:

```bash
ADMIN_USERNAME="your_username"
ADMIN_EMAIL="your_email"
S3_NAME="your_bucket_name"
AWS_REGION="your_region"
```