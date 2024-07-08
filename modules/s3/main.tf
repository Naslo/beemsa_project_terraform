resource "aws_s3_bucket" "codepipeline_bucket" {
    bucket = var.codepipeline_bucket_name
    force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket_pab" {
    bucket = aws_s3_bucket.codepipeline_bucket.bucket

    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "cicd_bucket_policy" {
    bucket = aws_s3_bucket.codepipeline_bucket.bucket
    depends_on = [ aws_s3_bucket_public_access_block.codepipeline_bucket_pab ]
    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Principal = "*",
                Action = [
                    "s3:GetObject",
                    "s3:ListBucket"
                ],
                Resource = [
                    "${aws_s3_bucket.codepipeline_bucket.arn}",
                    "${aws_s3_bucket.codepipeline_bucket.arn}/*"
                ]
            }
        ]
    })
}