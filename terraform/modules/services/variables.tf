

variable "resource_group_name" {
  description = "Default resource group name that the network will be created in."
  default     = "phi-rg"
}

variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  default     = "Australia East"
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)

  default = {
    BillTo              = "Infrastructure "
    Platform            = "Prd"
    AppSupportTeam      = "Infrastructure"
    Description         = "Network"
    OperatingHours      = "2400x7"
  }
}

variable "app_plan_name" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  default     = "AppPlanName"
}

variable "app_name" {
    description = "A list of public app names." 
}

variable "app_service_plan_ids" {
     type        = map(string)
    default     = {}
}

variable "subnet_id" {
  description = "The address prefix to use for the subnet."
  default     = ["10.0.1.0/24"]
}

variable "app_kind" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
}

variable "sku" {
  type        = map(string)
}


