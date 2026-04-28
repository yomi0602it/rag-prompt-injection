# RAG System Prompt Injection Showcase

Evaluating the Impact of Prompt Injection Attacks on Retrieval-Augmented Generation (RAG) Systems

##Overview
This repository contains the architectural blueprint and source code for simulating a Prompt Injection attack against a Retrieval-Augmented Generation (RAG) system. The project demonstrates how Large Language Models (LLMs) can be manipulated when instructed to process adversarial text embedded within retrieved documents.

##Architecture
The system is designed around AWS Managed Services:
* **Inference Engine:** Amazon Bedrock (Meta Llama 3 8B)
* **Embedding Model:** Amazon Titan Text Embeddings
* **Vector Database:** Amazon OpenSearch Serverless
* **Orchestration:** LangChain (Python)

## Directory Structure
* `/data`: Contains both benign corporate documents and the adversarial payloads used to contaminate the vector database.
* `/infrastructure`: Contains the Terraform (`main.tf`) blueprint for provisioning the required AWS IAM policies and OpenSearch collections.
* `/src`: Contains the Python logic for document ingestion and the vulnerable RAG retrieval chain.

## The Vulnerability
This prototype deliberately lacks input filtering and system prompt reinforcement. By querying the system with a prompt designed to retrieve the file in `data/poisoned/`, the LLM will encounter a malicious command that overrides its base instructions, demonstrating a critical context contamination vulnerability.