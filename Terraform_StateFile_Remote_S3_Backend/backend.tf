
# Create S3 bucket , enable versioning & encrypt
resource "aws_s3_bucket" "my_bucket" {
  bucket = "xplrorer-s3-bucket"
}

# resource "aws_s3_bucket_versioning" "versioning_S3" {
#   bucket = aws_s3_bucket.my_bucket.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "S3_Encrypt" {
#   bucket = aws_s3_bucket.my_bucket.id

#   rule {
#     apply_server_side_encryption_by_default {
#             sse_algorithm     = "AES256"
#     }
#   }
# }

# Create Dynamo DB table for terraform state lock
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}

