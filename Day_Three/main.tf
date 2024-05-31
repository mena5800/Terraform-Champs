# define variables
variable "region" {}
variable "Environment" {}
variable "Owner" {}
variable "S3_name" {}

# define provider
provider "aws" {
  region = var.region
}

# create s3 bucket
resource "aws_s3_bucket" "bucket" {

  bucket        = var.S3_name
  force_destroy = true

  tags = {
    Name        = var.S3_name
    Environment = var.Environment
    Owner       = var.Owner
  }
}

# create s3 objects (folders)
resource "aws_s3_object" "log" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "log/"

  tags = {
    Name        = "log directory"
    Environment = var.Environment
    Owner       = var.Owner
  }

}

resource "aws_s3_object" "outgoing" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "outgoing/"

  tags = {
    Name        = "outgoing directory"
    Environment = var.Environment
    Owner       = var.Owner
  }

}

resource "aws_s3_object" "incomming" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "incomming/"

  tags = {
    Name        = "incomming directory"
    Environment = var.Environment
    Owner       = var.Owner
  }

}

# create s3 bucket lifecycle configuration for each directory inside bucket
resource "aws_s3_bucket_lifecycle_configuration" "name" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    id = "log_rule"

    filter {
      prefix = "log/"
    }

    expiration {
      days = 365
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    transition {
      days          = 180
      storage_class = "DEEP_ARCHIVE"
    }


    status = "Enabled"

  }

  rule {
    id = "outgoing_rule"

    filter {
      and {
        prefix = "outgoing/"
        tags = {
          key = "notDeepArchive"
        }
      }

    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
    status = "Enabled"
  }

  rule {
    id = "incoming_rule"

    filter {
      and {
        prefix                   = "incoming/"
        object_size_greater_than = 1048576    # 1 mb
        object_size_less_than    = 1073741824 # 1 gb
      }
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
    status = "Enabled"
  }
}
