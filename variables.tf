variable "resource_tags" {
  description = "List of resource tags to be added to all created resources"
  type        = map(string)
  default = {
    Name       = "not-set-yet"
    Managed_by = "terraform"
  }
}

variable "provider_aws" {
  description = "Configuration passed to the Hashicorp/aws provider"
  type = object({
    region = optional(string, "eu-west-1")
  })
  default = {}
}

variable "global" {
  type = object({
    append_random_id = optional(bool, true)
    enable_policy    = optional(bool, false)
    #resource_policy_enabled = optional(bool, false)
    resource_policy = optional(any)
  })
  default = {}
}

variable "config" {
  default = {}
  type = object({
    name                           = optional(string, "terraform-lock")
    billing_mode                   = optional(string, "PROVISIONED")
    deletion_protection_enabled    = optional(bool, false)
    global_secondary_index_enabled = optional(bool, false)
    replication_enabled            = optional(bool, false)
    server_side_encryption_enabled = optional(bool, true)
    kms_key_arn                    = optional(string)
    read_capacity_units            = optional(number, 5)
    write_capacity_units           = optional(number, 5)
  })
}

variable "replica_config" {
  type = map(object({
    kms_key_arn            = optional(string)
    point_in_time_recovery = optional(bool, true)
    propagate_tags         = optional(bool, true)
    region_name            = optional(string)
  }))
  default = null
}

variable "stream_config" {
  default = {}
  type = object({
    enabled   = optional(bool, false)
    view_type = optional(string, "KEYS_ONLY")
  })
}

variable "table_config" {
  default = {}
  type = object({
    attribute_name     = optional(string)
    attribute_type     = optional(string, "S")
    create             = optional(bool, true)
    table_class        = optional(string, "STANDARD")
    ttl_enabled        = optional(bool, false)
    ttl_attribute_name = optional(string, "TimeToExist")
    hash_key           = optional(string, "LockID")
    range_key          = optional(string)
  })
  description = "Name of the DynamoDB table"
}

variable "global_secondary_index" {
  type = map(object({
    name               = optional(string)
    hash_key           = optional(string)
    range_key          = optional(string)
    write_capacity     = optional(number)
    read_capacity      = optional(number)
    projection_type    = optional(string)
    non_key_attributes = optional(list(any))
  }))
  default = null
}

