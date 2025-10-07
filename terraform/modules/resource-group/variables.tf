variable "name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the resource group"
  type        = string
  default     = "East US"
}

variable "tags" {
  description = "Tags to apply to the resource group"
  type        = map(string)
  default     = {}
}