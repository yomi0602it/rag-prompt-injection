# ===========================================
# Variables for RAG Prototype Infrastructure
# ===========================================

variable "aws_region" {
  description = "AWS region for deploying Bedrock and OpenSearch resources"
  type        = string
  default     = "us-east-1"
}

variable "collection_name" {
  description = "Name of the OpenSearch Serverless collection"
  type        = string
  default     = "rag-prototype"
}

variable "project_prefix" {
  description = "Prefix applied to all resource names for identification"
  type        = string
  default     = "rag-injection"
}

variable "environment" {
  description = "Deployment environment tag (dev, staging, prod)"
  type        = string
  default     = "dev"
}
