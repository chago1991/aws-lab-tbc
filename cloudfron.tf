resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.web_bucket.bucket_regional_domain_name
    origin_id   = "tbc-lab-s3"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.s3_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Image caching distribution"
  default_root_object = "itsworking.jpeg"

  default_cache_behavior {
    target_origin_id       = "tbc-lab-s3"
    viewer_protocol_policy = "allow-all"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  depends_on = [ aws_s3_bucket.web_bucket, aws_cloudfront_origin_access_identity.s3_identity ]
}

resource "aws_cloudfront_origin_access_identity" "s3_identity" {
  comment = "Access Identity for S3 bucket"
  depends_on = [ aws_s3_bucket.web_bucket ]
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}
