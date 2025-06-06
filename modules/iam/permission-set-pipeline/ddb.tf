# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

resource "aws_dynamodb_table" "tf_backend" {
  name         = "${var.solution_name}-tf-backend"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.cmk.arn
  }

  tags = {
    "Name" = "${var.solution_name}-tf-backend"
  }
}
