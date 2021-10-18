variable "location" {
  description = "location of resources"
  type        = string
  default     = "Brazil South"
}
variable "resource_group" {
  description = "resource_group"
  type        = string
  default     = "rg-terraform"
}

variable "virtual_network" {
  description = "virtual_network"
  type        = string
  default     = "vnet-terraform"
}

variable "subnet" {
  description = "subnet"
  type        = string
  default     = "internal"
}


variable "vm" {
  description = "virtual machine configs"
  type        = map(string)
  default = {
    "name"           = "vm01"
    "vm_size"        = "Standard_B2s"
    "admin_username" = "nabuco"
    "admin_password" = "terraform@123"
  }
}