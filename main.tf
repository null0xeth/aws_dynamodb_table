########### AWS DATA #####################################################################
data "aws_region" "active" {}

########### RANDOM ID #####################################################################
resource "random_pet" "env" {
  count     = var.global_config.append_random_id ? 1 : 0
  length    = 2
  separator = "_"
}

########### DYNAMO DB #####################################################################
resource "aws_dynamodb_table" "new" {
  count                       = var.dynamodb_table_config.create ? 1 : 0
  name                        = var.global_config.append_random_id ? "${var.dynamodb_global_config.name}-${element(random_pet.env[*], 0).id}" : "${var.dynamodb_global_config.name}"
  billing_mode                = var.dynamodb_global_config.billing_mode
  deletion_protection_enabled = var.dynamodb_global_config.deletion_protection_enabled
  read_capacity               = var.dynamodb_global_config.read_capacity_units
  write_capacity              = var.dynamodb_global_config.write_capacity_units
  stream_enabled              = var.dynamodb_stream_config.enabled
  stream_view_type            = var.dynamodb_stream_config.view_type
  table_class                 = var.dynamodb_table_config.table_class
  hash_key                    = var.dynamodb_table_config.hash_key
  range_key                   = var.dynamodb_table_config.range_key

  attribute {
    name = var.dynamodb_table_config.attribute_name
    type = var.dynamodb_table_config.attribute_type
  }

  dynamic "replica" {
    for_each = var.dynamodb_global_config.replication_enabled ? var.dynamodb_replica_config : {}
    content {
      kms_key_arn            = each.value.kms_key_arn
      point_in_time_recovery = each.value.point_in_time_recovery
      region_name            = data.aws_region.active.name
      propagate_tags         = each.value.propagate_tags
    }
  }

  server_side_encryption {
    enabled     = var.dynamodb_global_config.server_side_encryption_enabled
    kms_key_arn = var.dynamodb_global_config.kms_key_arn
  }

  dynamic "global_secondary_index" {
    for_each = var.dynamodb_global_config.global_secondary_index_enabled ? var.dynamodb_table_global_secondary_index : {}
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
    attribute_name = var.dynamodb_table_config.ttl_enabled ? var.dynamodb_table_config.ttl_attribute_name : null
    enabled        = var.dynamodb_table_config.ttl_enabled
  }

  tags = {
    for k, v in var.resource_tags : k => v
  }
}

resource "aws_dynamodb_resource_policy" "new" {
  count        = var.global_config.resource_policy_enabled ? 1 : 0
  resource_arn = element(aws_dynamodb_table.new[*], 0).arn
  policy       = var.global_config.resource_policy
}
