# ===========================================
# RAG Prompt Injection Prototype - AWS Infrastructure
# Provisions Amazon Bedrock access and OpenSearch
# Serverless vector database via Terraform IaC.
# ===========================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "RAG-Prompt-Injection-Research"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# --- 1. IAM Policy for Amazon Bedrock Access ---
# Grants permissions to invoke foundation models (Llama 3, Titan Embeddings).
resource "aws_iam_policy" "bedrock_invoke" {
  name        = "${var.project_prefix}-bedrock-policy"
  description = "Allows invocation of Bedrock foundation models for prompt injection testing."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowBedrockInvocation"
        Action   = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
        Effect   = "Allow"
        Resource = "arn:aws:bedrock:${var.aws_region}::foundation-model/*"
      }
    ]
  })
}

# --- 2. OpenSearch Serverless Prerequisites ---
# AWS mandates encryption and network policies BEFORE creating a collection.

# Prerequisite A: Encryption Policy
resource "aws_opensearchserverless_security_policy" "encryption" {
  name = "${var.project_prefix}-encryption"
  type = "encryption"
  policy = jsonencode({
    Rules = [
      {
        Resource     = ["collection/${var.collection_name}"]
        ResourceType = "collection"
      }
    ]
    AWSOwnedKey = true
  })
}

# Prerequisite B: Network Policy
# Allows public access for local development. In production, restrict to VPC endpoints.
resource "aws_opensearchserverless_security_policy" "network" {
  name = "${var.project_prefix}-network"
  type = "network"
  policy = jsonencode([
    {
      Description = "Public access for prototype testing"
      Rules = [
        {
          ResourceType = "collection"
          Resource     = ["collection/${var.collection_name}"]
        },
        {
          ResourceType = "dashboard"
          Resource     = ["collection/${var.collection_name}"]
        }
      ]
      AllowFromPublic = true
    }
  ])
}

# --- 3. OpenSearch Serverless Collection (Vector Database) ---
resource "aws_opensearchserverless_collection" "vector_db" {
  name = var.collection_name
  type = "VECTORSEARCH"

  depends_on = [
    aws_opensearchserverless_security_policy.encryption,
    aws_opensearchserverless_security_policy.network
  ]
}
