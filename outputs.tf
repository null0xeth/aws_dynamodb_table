output "output" {
  description = "Map with dynamodb table information"
  value = zipmap(
    [
      "arn",
      "id",
      "stream_arn",
      "stream_label"
    ],
    [
      element(aws_dynamodb_table.new[*], 0).arn,
      element(aws_dynamodb_table.new[*], 0).id,
      element(aws_dynamodb_table.new[*], 0).stream_arn,
      element(aws_dynamodb_table.new[*], 0).stream_label,
    ]
  )
}
