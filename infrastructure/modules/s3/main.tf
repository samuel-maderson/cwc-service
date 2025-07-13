resource "aws_s3_bucket" "vehicle_images" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket_public_access_block" "vehicle_images" {
  bucket = aws_s3_bucket.vehicle_images.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "vehicle_images" {
  bucket = aws_s3_bucket.vehicle_images.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.vehicle_images.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.vehicle_images]
}