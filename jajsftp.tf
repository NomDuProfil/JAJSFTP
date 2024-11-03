/*

# Author information

Name: NomDuProfil
Website: valou.io

# Module information

This module will creates an EC2 instance running SFTP with S3.

# Variables

| Name            | Type         | Description                                                                                                               |
|-----------------|--------------|---------------------------------------------------------------------------------------------------------------------------|
| name            | string       | Name of the project                                                                                                       |
| admin_whitelist | list(string) | IP address that can access the SFTP                                                                                       |
| admin_username  | string       | SFTP username                                                                                                             |
| admin_email     | string       | Email admin (to receive all the information)                                                                              |

# Example

module "jajsftp" {
  source = "./modules/jajsftp"
  name   = "JAJSFTP"
  admin_whitelist = [
    "12.12.12.12"
  ]
  admin_username = "admin"
  admin_email    = "jajemail@jajdomain.com"
}

*/
