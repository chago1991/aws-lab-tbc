resource "aws_s3_bucket" "web_bucket" {
  bucket = "tbc-lab-s3"

}
resource "aws_s3_bucket_policy" "web_bucket_policy" {
  bucket = aws_s3_bucket.web_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.web_bucket.arn}/*"
      },
    ]
  })
  depends_on = [ aws_s3_bucket.web_bucket ]
}

resource "aws_s3_bucket_ownership_controls" "web_bucket_owner" {
  bucket = aws_s3_bucket.web_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "web_bucket_public_access_block" {
  bucket = aws_s3_bucket.web_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.web_bucket_owner,
    aws_s3_bucket_public_access_block.web_bucket_public_access_block,
  ]

  bucket = aws_s3_bucket.web_bucket.id
  acl    = "public-read"
}

resource "aws_s3_object" "web_image" {
  bucket = aws_s3_bucket.web_bucket.bucket
  key    = "itsworking.jpeg"
  source = "./itsworking.jpeg"
}
