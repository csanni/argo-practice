from fastapi import FastAPI
import os

app = FastAPI()

@app.get("/")
def read_root():
    version = os.getenv("VERSION", "v1.0.0")
    return {"Hello": "World", "Version": version, "Message": "GitOps with ArgoCD is working!"}

@app.get("/health")
def health_check():
    return {"status": "ok"}
