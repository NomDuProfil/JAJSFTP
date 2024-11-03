variable "name" {
  type        = string
  default     = "jajsftp"
  description = "Name for the project"
}

variable "admin_whitelist" {
  type        = list(string)
  description = "IP for admin access"
}

variable "admin_username" {
  type        = string
  description = "Username for admin connexion"
}

variable "admin_email" {
  type        = string
  description = "Email admin (to receive all the information)"
}
