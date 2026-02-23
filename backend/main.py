import os
from fastapi import FastAPI
from celery.result import AsyncResult
from worker import write_log_celery
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import logging

logging.basicConfig(level=logging.DEBUG)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class NotifyRequest(BaseModel):
    email: str

#BACKEND_PORT = int(os.getenv("BACKEND_PORT", 8000))


@app.post("/notify/")
async def notify_user(payload: NotifyRequest):
    task = write_log_celery.delay(f"Notification sent to {payload.email}")
    return {"message": f"Email will be sent to {payload.email}", "task_id": task.id}

    
@app.get("/task_status/{task_id}/", tags=["Tasks"])
@app.get("/task_status/{task_id:path}", tags=["Tasks"])
async def get_task_status(task_id: str):
    """Endpoint to check the status of the task."""
    task_result = AsyncResult(task_id)  # Get the task result using the task ID
    if task_result.ready():  # If the task is done
        return {"task_id": task_id, "status": "completed", "result": task_result.result}
    elif task_result.failed():  # If the task failed
        return {"task_id": task_id, "status": "failed"}
    else:  # If the task is still in progress
        return {"task_id": task_id, "status": "in progress"}




@app.get("/health")
def health():
    return {"status": "ok"}

