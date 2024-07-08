resource "aws_dynamodb_table" "terraform_lock_table" {
    name = var.terraform_lock_table_name
    hash_key = var.table_hash_key
    billing_mode = "PAY_PER_REQUEST"

    attribute {
        name = var.table_hash_key
        type = "S"
    }
}