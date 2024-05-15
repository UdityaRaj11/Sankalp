import weaviate
import os
import json

from langchain_community.document_loaders import PyPDFLoader
from langchain_google_genai import GoogleGenerativeAIEmbeddings
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import Chroma
from typing import List, Optional


from vertexai.language_models import TextEmbeddingInput, TextEmbeddingModel

GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY")
WEAVIATE_KEY = os.environ.get("WEAVIATE_API_KEY")
WEAVIATE_URL = os.environ.get("WEAVIATE_URL")


client = weaviate.Client(
    url=WEAVIATE_URL,
    auth_client_secret=weaviate.auth.AuthApiKey(api_key=WEAVIATE_KEY), 
)

print('is_ready:', client.is_ready())

def embed_text(
    docs,
) -> List[List[float]]:
    """Embeds texts with a pre-trained, foundational model."""
    model = GoogleGenerativeAIEmbeddings(model="models/embedding-001",google_api_key=GOOGLE_API_KEY)
    text_splitter = RecursiveCharacterTextSplitter(chunk_size=10000, chunk_overlap=1000)
    context = "\n\n".join(str(p) for p in docs)
    texts = text_splitter.split_text(context)
    embeddings = model.embed_documents(texts, batch_size=1000)
    return embeddings

# Create a new class
class_obj = {"class": "Doc", "vectorizer": "none"}
client.schema.create_class(class_obj)

print("Loading PDF")
pdf_loader = PyPDFLoader("Harrison.pdf")
pages = pdf_loader.load_and_split()
print(pages[3].page_content)


client.batch.configure(batch_size=len(pages))

with client.batch as batch:
    for i, doc in enumerate(pages):
        properties = {"source_text": doc}
        vector = embed_text(doc.page_content)
        batch.add_data_object(properties, "Doc", vector=vector)

query = "Give me some content about medicine."
query_vector = embed_text(query)

result = client.query.get("Doc", ["source_text"]).with_near_vector({
    "vector": query_vector,
    "certainty": 0.7
}).with_limit(2).with_additional(['certainty', 'distance']).do()

print(json.dumps(result, indent=4))

