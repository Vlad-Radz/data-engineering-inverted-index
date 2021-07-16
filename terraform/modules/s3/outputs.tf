output "bucket_scripts_name" {
  value = "${aws_s3_bucket.bucket_scripts.id}"
}

output "bucket_logs_name" {
  value = "${aws_s3_bucket.bucket_logs.id}"
}