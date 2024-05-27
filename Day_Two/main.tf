# define variables
variable "region" {}
variable "Environment" {}
variable "Owner" {}
variable "bucket_name" {}
variable "iam_user" {

}

# define provider
provider "aws" {
  region = var.region
}

# create s3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    "Name" : "logs_bucket"
    "Environment" : var.Environment
    "Owner" : var.Owner
  }

}

# create s3 bucket versioning
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }

}

# create s3 bucket ownership control
resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }

}

# create directory in s3 bucket
resource "aws_s3_object" "bucket_directory" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "logs/"

  tags = {
    "Name" : "logs_directory"
    "Environment" : var.Environment
    "Owner" : var.Owner
  }
}

# get iam user
data "aws_iam_user" "iam_user" {
  user_name = var.iam_user

}

# create policy
data "aws_iam_policy_document" "allow_access_iam_user" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["${data.aws_iam_user.iam_user.arn}"] // need iam user arn
    }
    actions = [
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}/logs/*"
    ]
  }

}

# create bucket policy
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.allow_access_iam_user.json

}
