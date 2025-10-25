output "bucket_name" {
  description = "Name of the storage bucket"
  value = var.cloud_provider == "aws" ? aws_s3_bucket.main[0].id : (
    var.cloud_provider == "azure" ? azurerm_storage_account.main[0].name : (
      var.cloud_provider == "gcp" ? google_storage_bucket.main[0].name : ""
    )
  )
}

output "bucket_arn" {
  description = "ARN of the bucket (AWS only)"
  value       = var.cloud_provider == "aws" ? aws_s3_bucket.main[0].arn : null
}

output "bucket_url" {
  description = "URL of the bucket"
  value = var.cloud_provider == "aws" ? "s3://${aws_s3_bucket.main[0].id}" : (
    var.cloud_provider == "azure" ? azurerm_storage_account.main[0].primary_blob_endpoint : (
      var.cloud_provider == "gcp" ? "gs://${google_storage_bucket.main[0].name}" : ""
    )
  )
}
