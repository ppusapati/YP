# ─────────────────────────────────────────────────────────────────────────────
# CDN
#
# In front of two things with opposite caching needs:
#
#   /tiles/*  — map tiles from the tile service. A tile for a field and a date
#               never changes once computed, so it is cached for a year. This
#               is most of the traffic on the platform and almost all of the
#               benefit: without a CDN every pan of the map is a request that
#               reaches the cluster from a phone on a rural connection.
#
#   everything else — the web app's static assets, cached by the hash in their
#               filename, with the HTML itself not cached at all so a deploy
#               takes effect.
#
# The API is deliberately NOT behind this. Caching a ConnectRPC response would
# mean serving one tenant's data to another the moment a cache key is wrong,
# and a cache key that includes the Authorization header caches nothing while
# costing a lookup.
# ─────────────────────────────────────────────────────────────────────────────

locals {
  cdn_enabled = var.cdn_domain != ""
}

resource "aws_s3_bucket" "static" {
  count = local.cdn_enabled ? 1 : 0

  bucket = "${local.name}-static-${random_id.bucket_suffix.hex}"
  tags   = { Name = "${local.name}-static" }
}

resource "aws_s3_bucket_public_access_block" "static" {
  count = local.cdn_enabled ? 1 : 0

  bucket = aws_s3_bucket.static[0].id

  # Public through CloudFront's origin access control, never directly. A bucket
  # that is publicly readable is also publicly enumerable, and the cost of a
  # bucket serving files without the CDN in front of it is billed at origin
  # egress rates.
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "static" {
  count = local.cdn_enabled ? 1 : 0

  bucket = aws_s3_bucket.static[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_cloudfront_origin_access_control" "static" {
  count = local.cdn_enabled ? 1 : 0

  name                              = "${local.name}-static"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_acm_certificate" "cdn" {
  count    = local.cdn_enabled && var.acm_certificate_arn == "" ? 1 : 0
  provider = aws.us_east_1

  domain_name       = var.cdn_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  certificate_arn = var.acm_certificate_arn != "" ? var.acm_certificate_arn : (
    local.cdn_enabled ? aws_acm_certificate.cdn[0].arn : ""
  )
}

resource "aws_cloudfront_cache_policy" "tiles" {
  count = local.cdn_enabled ? 1 : 0

  name        = "${local.name}-tiles"
  default_ttl = 31536000
  max_ttl     = 31536000
  min_ttl     = 86400

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_gzip   = true
    enable_accept_encoding_brotli = true

    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      # No headers in the cache key. A tile is a tile: adding Accept-Language
      # or User-Agent would split the cache by browser for an image that does
      # not vary by either.
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_cache_policy" "assets" {
  count = local.cdn_enabled ? 1 : 0

  name        = "${local.name}-assets"
  default_ttl = 86400
  max_ttl     = 31536000
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_gzip   = true
    enable_accept_encoding_brotli = true

    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_distribution" "main" {
  count = local.cdn_enabled ? 1 : 0

  enabled             = true
  is_ipv6_enabled     = true
  comment             = local.name
  default_root_object = "index.html"
  aliases             = [var.cdn_domain]

  # North America and Europe cost more and serve nobody here. PriceClass_200
  # includes India and the rest of Asia, which is where the farms are.
  price_class = "PriceClass_200"

  origin {
    origin_id                = "static"
    domain_name              = aws_s3_bucket.static[0].bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.static[0].id
  }

  origin {
    origin_id   = "tiles"
    domain_name = var.cdn_domain != "" ? "origin.${var.cdn_domain}" : "example.invalid"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
      # A cold tile is computed from the raster, which is not a fast request.
      origin_read_timeout = 60
    }
  }

  default_cache_behavior {
    target_origin_id       = "static"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    cache_policy_id        = aws_cloudfront_cache_policy.assets[0].id
  }

  ordered_cache_behavior {
    path_pattern           = "/tiles/*"
    target_origin_id       = "tiles"
    viewer_protocol_policy = "https-only"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    cache_policy_id        = aws_cloudfront_cache_policy.tiles[0].id
  }

  ordered_cache_behavior {
    # index.html is not cached. Caching it means a deploy that has finished
    # everywhere still serves the previous app to anyone with a warm edge —
    # and the assets it references have been replaced.
    path_pattern           = "/index.html"
    target_origin_id       = "static"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = local.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # A single-page app serves its router from index.html, so an unknown path is
  # a route rather than a missing file. Without this, deep-linking to
  # /fields/01ABC returns S3's 403.
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  tags = { Name = local.name }
}

# CloudFront reaches the bucket through the origin access control and nothing
# else does.
resource "aws_s3_bucket_policy" "static" {
  count = local.cdn_enabled ? 1 : 0

  bucket = aws_s3_bucket.static[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "cloudfront.amazonaws.com" }
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.static[0].arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = aws_cloudfront_distribution.main[0].arn
        }
      }
    }]
  })
}
