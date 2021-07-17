resource "random_string" "bucket_data_name" {
  length           = 40
  special          = false
  upper            = false
}

resource "aws_s3_bucket" "bucket_data" {
  bucket = "${random_string.bucket_data_name.result}"
  acl    = "private"

  tags = {
    Description = "Bucket for storing source data"
  }
}

resource "aws_s3_bucket_object" "data_files" {
  for_each = fileset("../../../data/", "*")
  bucket     = aws_s3_bucket.bucket_data.id
  key = each.value
  source     = "../../../data/${each.value}"
  depends_on = [aws_s3_bucket.bucket_data]
}

# ######################################################

resource "random_string" "bucket_scripts_name" {
  length           = 40
  special          = false
  upper            = false
}

resource "aws_s3_bucket" "bucket_scripts" {
  bucket = "${random_string.bucket_scripts_name.result}"
  acl    = "private"

  tags = {
    Description = "Bucket for storing scripts"
  }
}

resource "aws_s3_bucket_object" "inverted_index_script" {
  bucket = aws_s3_bucket.bucket_scripts.id
  key    = "inverted_index.py"
  acl    = "private"  # or can be "public-read"
  source = "../../../app/app.py"
  depends_on = [aws_s3_bucket.bucket_scripts]
}

# ######################################################

resource "random_string" "bucket_logs_name" {
  length           = 40
  special          = false
  upper            = false
}

resource "aws_s3_bucket" "bucket_logs" {
  bucket = "${random_string.bucket_logs_name.result}"
  acl    = "private"

  tags = {
    Description = "Bucket for storing logs"
  }
}
