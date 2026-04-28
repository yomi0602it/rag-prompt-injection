import os
import boto3
from langchain_aws import BedrockEmbeddings, ChatBedrock
from langchain_community.vectorstores import OpenSearchVectorSearch
from langchain.chains import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_core.prompts import ChatPromptTemplate

def build_vulnerable_pipeline():
    """
    Constructs a RAG pipeline without defensive prompt engineering or filtering.
    """
    # 1. Initialize AWS Clients
    bedrock_client = boto3.client(service_name='bedrock-runtime', region='us-east-1')

    # 2. Setup Models
    embeddings = BedrockEmbeddings(model_id="amazon.titan-embed-text-v2:0", client=bedrock_client)
    llm = ChatBedrock(model_id="meta.llama3-8b-instruct-v1:0", client=bedrock_client)

    # 3. Connect to Vector Store (Mock Endpoint for Presentation)
    vector_store = OpenSearchVectorSearch(
        opensearch_url="https://mock-opensearch-endpoint.amazonaws.com",
        index_name="rag-baseline-index",
        embedding_function=embeddings
    )
    retriever = vector_store.as_retriever(search_kwargs={"k": 3})

    # 4. The Vulnerable Prompt
    # Notice the lack of explicit boundaries or warnings about malicious context.
    prompt = ChatPromptTemplate.from_messages([
        ("system", "You are an assistant. Answer the user's question using the following context:\n{context}"),
        ("human", "{input}"),
    ])

    # 5. Assemble the Chain
    document_chain = create_stuff_documents_chain(llm, prompt)
    rag_chain = create_retrieval_chain(retriever, document_chain)

    return rag_chain

if __name__ == "__main__":
    print("Vulnerable RAG Pipeline Initialized.")
    print("Awaiting queries to demonstrate context contamination...")
    # Implementation stops here for the structural showcase.