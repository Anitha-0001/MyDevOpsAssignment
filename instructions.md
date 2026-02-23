## 🧩 Task Notifier – Local Containerized Setup Guide

This guide helps developers run the Task Notifier project locally using Docker containers. It sets up the full system (frontend + backend + worker) without needing cloud infrastructure.



## 📦 Prerequisites

Make sure the following tools are installed on your system:

1. Git

2. Docker

3. Docker Compose

4. Python 3.11.x

**Verify:**

git --version
docker --version
docker-compose --version

---

📁 Project Structure

<img width="233" height="374" alt="image" src="https://github.com/user-attachments/assets/1bbd5845-bb6c-4afd-8dbf-c4f9d1ac6f38" />



---

## 🚀 Running the Project Locally (Containerized)

**1️⃣ Clone the repository**

`git clone https://github.com/Anitha-0001/MyDevOpsAssignment.git`

`cd MyDevOpsAssignment`

**2️⃣ Build the containers**

`docker compose build`

**3️⃣ Start the services**

`docker compose up`


**This will start:**

Backend API service

Background worker service

Frontend service

**🌐 Access the Application**

Frontend UI - `http://localhost:3000`

Backend API - `http://localhost:8000`

API Docs (Swagger) - `http://localhost:8000/docs`


---

## 🔁 Application Flow


**Step 1:** Trigger background task

Frontend calls: `POST /notify/`

`Payload example:

{
  "email": "test@example.com"
}
`
Response:
`
{
  "task_id": "85ffad83-e7b6-4d4f-874c-301197bf41f8"
}`

**Step 2: **Poll task status

Frontend automatically polls: `GET /task_status/{task_id}`

Example:

`GET /task_status/85ffad83-e7b6-4d4f-874c-301197bf41f8`

Response:

`{
  "status": "IN_PROGRESS",
  "result": null
}`

Final state:

`{
  "status": "COMPLETED",
  "result": "Email sent successfully"
}`


## 🐳 Docker Services

backend → FastAPI API server

worker → background task processor

frontend → static frontend app

**🛠 Common Commands**

Stop containers: `docker compose down`

Rebuild containers: `docker compose up --build`

Remove everything: `docker system prune -a`

---

## 🧪 Testing APIs Manually

**Using curl:**

Trigger task: `curl -X POST http://localhost:8000/notify/ \
-H "Content-Type: application/json" \
-d '{"email":"test@example.com"}'
`

**Check status:** `curl http://localhost:8000/task_status/85ffad83-e7b6-4d4f-874c-301197bf41f8`

---


## 📌 Notes

1. No cloud services are required for local execution

2. All services run inside Docker

3. Same containers are reused in cloud deployment (ECS/Fargate)

4. Local setup mirrors production architecture



----


## This setup ensures developers can run, test, and debug the full system locally without AWS access.
