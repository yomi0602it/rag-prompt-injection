# ===========================================
# Outputs from RAG Prototype Infrastructure
# ===========================================

output "opensearch_endpoint" {
  value       = aws_opensearchserverless_collection.vector_db.collection_endpoint
  description = "The endpoint URL to connect the LangChain application to the vector database. Paste this into your .env file."
}

output "opensearch_dashboard_endpoint" {
  value       = aws_opensearchserverless_collection.vector_db.dashboard_endpoint
  description = "The OpenSearch Dashboards URL for visual index inspection."
}

output "bedrock_policy_arn" {
  value       = aws_iam_policy.bedrock_invoke.arn
  description = "ARN of the IAM policy granting Bedrock model invocation permissions."
}
