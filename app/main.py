from fastapi import FastAPI
from fastapi.responses import JSONResponse

app = FastAPI(title="Serbian Tutor V2")

@app.get("/health")
async def health():
    return {"status": "ok"}

@app.get("/")
async def root():
    return {"name": "Serbian Tutor V2", "version": "2.0.0"}
