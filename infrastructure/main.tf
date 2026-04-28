terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Define the region where Bedrock and OpenSearch are supported
provider "aws" {
  region = "us-east-1"
}

# --- 1. IAM Policy for Amazon Bedrock Access ---
# This policy grants the ability to send queries to the models.
resource "aws_iam_policy" "bedrock_invoke" {
  name        = "RAG-Prototype-Bedrock-Policy"
  description = "Allows invocation of Bedrock foundation models for prompt injection testing."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["bedrock:InvokeModel"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# --- 2. OpenSearch Serverless (Vector Database) ---

# Prerequisite A: Encryption Policy
# AWS requires an explicit encryption policy before generating a serverless collection.
resource "aws_opensearchserverless_security_policy" "encryption" {
  name = "rag-encryption-policy"
  type = "encryption"
  policy = jsonencode({
    Rules = [
      {
        Resource     = ["collection/rag-prototype"]
        ResourceType = "collection"
      }
    ]
    AWSOwnedKey = true
  })
}

# Prerequisite B: Network Policy
# This determines how the endpoint is accessed. For a quick local prototype,
# this allows public access, meaning your local LangChain script can reach it over the internet.
resource "aws_opensearchserverless_security_policy" "network" {
  name = "rag-network-policy"
  type = "network"
  policy = jsonencode([
    {
      Description = "Public access for prototype testing"
      Rules = [
        {
          ResourceType = "collection"
          Resource     = ["collection/rag-prototype"]
        },
        {
          ResourceType = "dashboard"
          Resource     = ["collection/rag-prototype"]
        }
      ]
      AllowFromPublic = true
    }
  ])
}

# The Vector Database Collection
# This is the actual database where document embeddings will be stored.
resource "aws_opensearchserverless_collection" "vector_db" {
  name       = "rag-prototype"
  type       = "VECTORSEARCH"
  depends_on = [
    aws_opensearchserverless_security_policy.encryption,
    aws_opensearchserverless_security_policy.network
  ]
}

# --- 3. Outputs ---
# This prints the endpoint URL to the terminal after deployment,
# which you will paste into your Python script.
output "opensearch_endpoint" {
  value       = aws_opensearchserverless_collection.vector_db.collection_endpoint
  description = "The endpoint URL to connect your LangChain application to the vector database."
}