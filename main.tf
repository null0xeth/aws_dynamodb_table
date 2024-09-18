########### AWS DATA #####################################################################
data "aws_region" "active" {}

########### RANDOM ID #####################################################################
resource "random_pet" "env" {
  count     = var.global.append_random_id ? 1 : 0
  length    = 2
  separator = "_"
}

########### DYNAMO DB #####################################################################
resource "aws_dynamodb_table" "new" {
  count                       = var.table_config.create ? 1 : 0
  name                        = var.global.append_random_id ? "${var.global.name}-${element(random_pet.env[*], 0).id}" : "${var.global.name}"
  billing_mode                = var.global.billing_mode
  deletion_protection_enabled = var.global.deletion_protection_enabled
  read_capacity               = var.global.read_capacity_units
  write_capacity              = var.global.write_capacity_units
  stream_enabled              = var.stream_config.enabled
  stream_view_type            = var.stream_config.view_type
  table_class                 = var.table_config.table_class
  hash_key                    = var.table_config.hash_key
  range_key                   = var.table_config.range_key

  attribute {
    name = var.table_config.attribute_name
    type = var.table_config.attribute_type
  }

  dynamic "replica" {
    for_each = var.global.replication_enabled ? var.replica_config : {}
    content {
      kms_key_arn            = each.value.kms_key_arn
      point_in_time_recovery = each.value.point_in_time_recovery
      region_name            = data.aws_region.active.name
      propagate_tags         = each.value.propagate_tags
    }
  }

  server_side_encryption {
    enabled     = var.global.server_side_encryption_enabled
    kms_key_arn = var.global.kms_key_arn
  }

  dynamic "global_secondary_index" {
    for_each = var.global.global_secondary_index_enabled ? var.global_secondary_index : {}
    content {
      name               = each.value.key
      hash_key           = each.value.hash_key
      range_key          = each.value.range_key
      write_capacity     = each.value.write_capacity
      read_capacity      = each.value.write_capacity
      projection_type    = each.value.projection_type
      non_key_attributes = each.value.non_key_attributes
    }
  }

  ttl {
    attribute_name = var.table_config.ttl_enabled ? var.table_config.ttl_attribute_name : null
    enabled        = var.table_config.ttl_enabled
  }

  tags = {
    for k, v in var.resource_tags : k => v
  }
}

resource "aws_dynamodb_resource_policy" "new" {
  count        = var.global.resource_policy_enabled ? 1 : 0
  resource_arn = element(aws_dynamodb_table.new[*], 0).arn
  policy       = var.global.resource_policy
}
