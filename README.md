# RAG System Prompt Injection Vulnerability Showcase

**Evaluating the Impact of Prompt Injection Attacks on Retrieval-Augmented Generation (RAG) Systems**

Mercy University — Topics in Information Security — Spring 2026

Authors: Antwoin Johnson, Yomi Johnson

---

## Overview

This repository contains the architectural blueprint, source code, and adversarial payloads for simulating **Prompt Injection attacks** against a Retrieval-Augmented Generation (RAG) system. The project demonstrates how Large Language Models (LLMs) can be manipulated when they process adversarial text embedded within retrieved documents — without the end user ever typing a malicious prompt.

This is a **presentation-ready showcase repository**. The code is structurally complete and technically accurate but is not intended for live deployment. It serves as a DevSecOps artifact accompanying the academic research paper.

---

## Architecture

The system is designed around **AWS Managed Services**, provisioned via **Terraform (IaC)**:

| Component | Service | Purpose |
|---|---|---|
| Inference Engine | Amazon Bedrock (Meta Llama 3 8B Instruct) | Text generation from retrieved context |
| Embedding Model | Amazon Titan Text Embeddings V2 | Converts documents into vector representations |
| Vector Database | Amazon OpenSearch Serverless | Stores and retrieves document embeddings |
| Orchestration | LangChain (Python) | Bridges retrieval and generation phases |
| Infrastructure | Terraform | Provisions IAM policies, encryption, network, and OpenSearch |

### Data Flow

```
User Query
    │
    ▼
┌──────────────────────┐
│  LangChain Orchestrator  │
│  (src/vulnerable_rag.py) │
└──────────┬───────────┘
           │
    ┌──────┴──────┐
    ▼              ▼
┌────────┐   ┌──────────────────┐
│ Bedrock │   │ OpenSearch        │
│ Embeddings│   │ Vector Search     │
│ (Titan) │   │ (Top-K Retrieval) │
└────────┘   └────────┬─────────┘
                       │
              ┌────────┴────────┐
              │ Retrieved Docs   │
              │ ⚠ MAY CONTAIN   │
              │ INJECTED PAYLOAD │
              └────────┬────────┘
                       │
                       ▼
              ┌────────────────┐
              │ Bedrock LLM     │
              │ (Llama 3 8B)    │
              │ Context Window   │
              │ [System Prompt]  │
              │ [Retrieved Docs] │◄── Injection point
              │ [User Query]     │
              └────────┬───────┘
                       │
                       ▼
              ┌────────────────┐
              │ Generated       │
              │ Response        │
              │ (Compromised)   │
              └────────────────┘
```

---

## Directory Structure

```
rag-prompt-injection/
├── .github/workflows/
│   └── terraform-plan.yml       # CI/CD pipeline for IaC validation
├── data/
│   ├── clean/                   # Benign baseline documents (control)
│   │   ├── hr_policy.txt
│   │   ├── it_acceptable_use.txt
│   │   └── password_policy.txt
│   └── poisoned/                # Adversarial injection payloads (experimental)
│       ├── malicious_payload.txt
│       ├── role_hijack_payload.txt
│       └── data_exfil_payload.txt
├── docs/
│   └── project.pdf              # Academic research paper
├── infrastructure/
│   ├── main.tf                  # Core AWS resource definitions
│   ├── variables.tf             # Parameterized configuration
│   └── outputs.tf               # Terraform output values
├── src/
│   ├── ingest.py                # Document chunking and embedding ingestion
│   ├── vulnerable_rag.py        # Vulnerable LangChain RAG pipeline
│   └── evaluate.py              # Automated scenario testing and metrics
├── .env.example                 # Environment variable template
├── .gitignore                   # Security-focused ignore rules
├── README.md                    # This file
└── requirements.txt             # Python dependencies
```

---

## The Vulnerability

This prototype **deliberately omits** defensive prompt engineering, input filtering, and output sanitization. The system prompt naively instructs the LLM to use retrieved context without boundary enforcement:

```python
# The Vulnerable Prompt — no injection guards
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are an assistant. Answer the user's question using the following context:\n{context}"),
    ("human", "{input}"),
])
```

When the vector database retrieves a poisoned document (e.g., `data/poisoned/malicious_payload.txt`), the LLM encounters conflicting instructions within its context window. Because LLMs process system prompts and retrieved content as a **flattened token sequence**, the model cannot enforce a hard boundary between trusted developer instructions and untrusted retrieved data.

### Attack Vectors Demonstrated

| Payload | Technique | Expected Outcome |
|---|---|---|
| `malicious_payload.txt` | Direct instruction override | Model outputs attacker-controlled string |
| `role_hijack_payload.txt` | Identity/role reassignment | Model adopts an unrestricted persona |
| `data_exfil_payload.txt` | Context leakage via social engineering | Model reveals system prompt or internal data |

---

## Prerequisites

- Python 3.10+
- AWS CLI v2 (configured with valid credentials)
- Terraform >= 1.5
- Git

---

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/yomi0602it/rag-prompt-injection.git
cd rag-prompt-injection

# 2. Create and activate virtual environment
python3 -m venv .venv
source .venv/bin/activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Configure environment variables
cp .env.example .env
# Edit .env with your OpenSearch endpoint (from Terraform output)

# 5. Deploy infrastructure (when ready for live testing)
cd infrastructure
terraform init
terraform apply
cd ..

# 6. Ingest documents
python src/ingest.py

# 7. Run the vulnerable pipeline
python src/vulnerable_rag.py

# 8. Run automated evaluation
python src/evaluate.py

# 9. Tear down infrastructure
cd infrastructure
terraform destroy
```

---

## References

- Greshake et al. (2023). *Not what you've signed up for: Compromising Real-World LLM-Integrated Applications with Indirect Prompt Injection.* arXiv:2302.12173
- Perez & Ribeiro (2022). *Ignore Previous Prompt: Attack Techniques for Language Models.* arXiv:2211.09527
- OWASP (2025). *Top 10 for Large Language Model Applications.* owasp.org/www-project-top-10-for-large-language-model-applications
- NIST (2024). *AI Risk Management Framework (AI RMF 1.0).* nist.gov/artificial-intelligence

---

## License

This project is for academic and educational purposes only. The adversarial payloads are designed for controlled security research and should not be used against production systems without authorization.
