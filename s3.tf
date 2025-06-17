resource "aws_s3_bucket" "raw" {
  bucket_prefix = "raw"
  force_destroy = true
}

resource "aws_s3_bucket" "scan" {
  bucket_prefix = "scan"
  force_destroy = true
}

resource "aws_s3_bucket" "sensitive" {
  bucket_prefix = "sensitive"
  force_destroy = true
}

resource "aws_s3_bucket" "clean" {
  bucket_prefix = "clean"
  force_destroy = true
}

# resource "aws_s3_object" "poke_corpus_csv" {
#   bucket = aws_s3_bucket.pokemon.bucket
#   key    = "poke_corpus.csv"
#   source = "./poke_corpus.csv"
# }

# resource "aws_s3_bucket_notification" "bucket_notification" {
#   bucket = aws_s3_bucket.pokemon.id

#   lambda_function {
#     lambda_function_arn = aws_lambda_function.start_kb_ingestion_jobs.arn
#     events              = ["s3:ObjectCreated:*"]
#     # filter_prefix       = "AWSLogs/"
#     filter_suffix = "poke_corpus.csv"
#   }
#   depends_on = [aws_lambda_permission.allow_bucket]
# }