from flask import Flask, request, jsonify
import os
import whisper
import textwrap
from pathlib import Path as p
from langchain_core.prompts import PromptTemplate
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.chains.question_answering import load_qa_chain
from langchain_community.document_loaders import PyPDFLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import Chroma
from langchain.chains import RetrievalQA
from langchain_google_genai import GoogleGenerativeAIEmbeddings
from IPython.display import Markdown
import google.generativeai as genai

app = Flask(__name__)

global geminiModel
global model
global vector_index

def initialize_ml_model():
    global geminiModel
    global model
    global vector_index
    GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY")
    genai.configure(api_key=GOOGLE_API_KEY)

    geminiModel = ChatGoogleGenerativeAI(model="gemini-pro", google_api_key=GOOGLE_API_KEY, temperature=0.2, convert_system_message_to_human=True)

    model = whisper.load_model("base")

    print("Loading PDF")
    pdf_loader = PyPDFLoader("Harrison.pdf")
    pages = pdf_loader.load_and_split()
    print(pages[3].page_content)
    text_splitter = RecursiveCharacterTextSplitter(chunk_size=10000, chunk_overlap=1000)
    context = "\n\n".join(str(p.page_content) for p in pages)
    texts = text_splitter.split_text(context)
    embeddings = GoogleGenerativeAIEmbeddings(model="models/embedding-001",google_api_key=GOOGLE_API_KEY)
    vector_index = Chroma.from_texts(texts, embeddings).as_retriever(search_kwargs={"k":5})

initialize_ml_model()

def to_markdown(text):
    text = text.replace('*', ' *')
    return Markdown(textwrap.indent(text, '> ', predicate=lambda _: True))

@app.route('/generate_notes', methods=['POST'])
def generate_notes():
    if 'audio' not in request.files:
        return jsonify({'error': 'No audio file provided'})

    audio_file = request.files['audio']
    if audio_file.filename == '':
        return jsonify({'error': 'No selected audio file'})

    # Save the audio file temporarily
    temp_path = 'temp_audio.mp3'
    audio_file.save(temp_path)

    # Generate medical notes
    notes = getNotes(temp_path)

    # Delete the temporary audio file
    os.remove(temp_path)

    return jsonify({'notes': notes})

@app.route('/get_suggestions', methods=['POST'])
def get_suggestions():
    data = request.json
    query = data['query']
    suggestions = getSuggestions(query)
    print(suggestions)
    return jsonify({'suggestions': suggestions})

def getSuggestions(query):
    template = os.environ.get("GET_SUGGESTIONS_TEMPLATE")
    QA_CHAIN_PROMPT = PromptTemplate.from_template(template)
    qa_chain = RetrievalQA.from_chain_type(
        model,
        retriever=vector_index,
        return_source_documents=True,
        chain_type_kwargs={"prompt": QA_CHAIN_PROMPT}
    )
    question = query
    result = qa_chain({"query": question})
    return result["result"]

def getNotes(audio_path):
    result = model.transcribe(audio_path)
    txt = result["text"]
    template = os.environ.get("GET_NOTES_PROMPT") + txt
    response = geminiModel.invoke(template)
    return response.content

if __name__ == '__main__':
    app.run(debug=True)
