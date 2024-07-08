resource "aws_s3_bucket" "terraform_state_bucket" {
    bucket = var.terraform_state_bucket_name
    force_destroy = true
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
    bucket = aws_s3_bucket.terraform_state_bucket.bucket
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket" "codepipeline_bucket" {
    bucket = var.codepipeline_bucket_name
    force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket_pab" {
    bucket = aws_s3_bucket.codepipeline_bucket.bucket

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
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