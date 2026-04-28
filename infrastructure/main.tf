# AWS Infrastructure Specification for RAG Prototype
provider "aws" {
  region = "us-east-1"
}

# IAM Policy for LLM Invocation
resource "aws_iam_policy" "bedrock_invoke" {
  name        = "RAG-Prototype-Bedrock-Policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = ["bedrock:InvokeModel"], Effect = "Allow", Resource = "*" }]
  })
}

# Vector Database (OpenSearch Serverless)
resource "aws_opensearchserverless_collection" "vector_db" {
  name = "rag-vulnerable-db"
  type = "VECTORSEARCH"
}