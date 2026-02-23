# Task Notifier Project – My Assignment Journey


---

## Objective

Design and deploy a cloud-native, containerized, microservices-based **web application where users can trigger notifications and track their tasks in real-time** using DevOps best practices.

DevOps focuses on automation, scalability, reliability, and rapid delivery. This project demonstrates the full DevOps lifecycle: development → containerization → infrastructure automation → cloud deployment → monitoring → debugging.

**Components:**

- Frontend (UI)

- Backend API (FastAPI)

- Worker Service (Async processing)

 **Logical Architecture: User → ALB → Frontend → Backend → Worker → Status API → Frontend**

 
**Architecture Diagram:**


<img width="900" height="600" alt="Architecture (2)" src="https://github.com/user-attachments/assets/55f277cd-217b-4766-9286-9d091030ee17" />


---


## Technology Stack

**Local:** Git, Docker, Docker Compose, Python

**Cloud:** AWS ECS (Fargate), ECR, ALB, VPC, Subnets, IAM, CloudWatch

**IaC:** Terraform

Infrastructure as Code (IaC) enables reproducibility, version control, and automated provisioning of infrastructure.

---


## Project Structure 


- **Frontend:** HTML for the user interface ----------------------------------> frontend/ → UI
  
- **Backend:** FastAPI, Celery and Redis for handling task requests ----------> backend/  → FastAPI + worker logic (Celery)
  
- **Containerization:** Docker, to keep everything isolated and reproducible--> docker-compose.yml → local orchestration
  
- **Cloud Deployment:** AWS ECS with ALB to route traffic --------------------> terraform/ → cloud infrastructure 
   
- **Infrastructure as Code:** Terraform to manage everything systematically --> terraform/ → Provisioning
  

This Microservices architecture enables Containerized services, Event-driven task processing, Load-balanced cloud deployment



<img width="370" height="280" alt="image" src="https://github.com/user-attachments/assets/0398840b-090b-4e4e-afce-1051f75e0569" /> 


---

## Local Environment deployment without Docker Containerization

1) Start Redis.

2) From project root: `cd backend && python -m venv venv`, activate venv, `pip install -r ../requirements.txt`

3) Terminal 1: `cd backend && celery -A worker worker --loglevel=info`

4) Terminal 2: `cd backend && uvicorn main:app --reload --port 8000`

5) Serve frontend: simply open index.html in browser.


Output:


<img width="1000" height="600" alt="Screenshot 2026-02-18 011927" src="https://github.com/user-attachments/assets/1edf9a18-6375-4c03-8ebd-70eb3f735c4e" />


---


## Local Environment deployment with Docker Containerization

Local environment deployment using Docker and Docker Compose enables consistent, isolated, and reproducible multi-service application execution across environments.

**Docker + Docker Compose = consistent local multi-service deployment.**

Backend → Python + FastAPI container

Frontend → HTTP Static server container

Worker → Background processing container

`docker-compose up --build`



Outputs:

<img width="500" height="600" alt="Screenshot 2026-02-23 003628" src="https://github.com/user-attachments/assets/408d6222-e8ae-4ee9-864e-af832dfe3bc4" /> <img width="400" height="400" alt="Screenshot 2026-02-18 124120" src="https://github.com/user-attachments/assets/92b4fdbf-dcbc-4e07-9ba7-4bec7b549d42" />


---


## Application Flow

- User enters email in UI → The user gives input to start the process.

- Frontend calls API → The app sends the request to the server.

- Backend creates task → The server creates a job to be done.

- Worker processes task → Another service does the actual work in the background.

- Status stored → The system saves the result safely.

- Frontend polls status → The app keeps checking for updates to show the user.

---
  
`main.py` using **FastAPI**, which handled endpoints:  

- `/notify` → to trigger notifications  
- `/taskstatus/{task_id}` → to check the status of a task  
- `/health` → to allow health checks  

To process tasks asynchronously, we have this `worker.py` using Python’s `asyncio`.  


---

## AWS Cloud Architecture

**Services Used:**

ECR → Image registry → Stores and manages Docker images securely for deployment.

ECS Fargate → Container runtime → Runs containers without managing servers.

ALB → Traffic routing → Directs user traffic to the correct service.

VPC → Network isolation → Keeps the application network secure and separated.

IAM → Access control → Manages permissions and service access securely.

CloudWatch → Logging → Collects logs for monitoring and debugging.


---


### ECR Image Management

**Steps: Build → Tag → Push → Deploy**

`docker build -t frontend:latest ./frontend`

`docker build -t backend-merged:latest ./backend` 

`aws ecr create-repository --repository-name frontend`

`aws ecr create-repository --repository-name backend`

`aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 758604744414.dkr.ecr.ap-south-1.amazonaws.com`

`docker tag frontend-merged:latest 758604744414.dkr.ecr.ap-south-1.amazonaws.com/frontend:latest`

`docker push 758604744414.dkr.ecr.ap-south-1.amazonaws.com/frontend:latest`





<img width="500" height="300" alt="Screenshot (9)" src="https://github.com/user-attachments/assets/7f113183-d992-486a-b018-3b87202f83a2" /> <img width="500" height="300" alt="Screenshot (11)" src="https://github.com/user-attachments/assets/2683bfb1-ccbf-42d0-953c-c2d05f1bfa86" />


---


## Terraform Deployment

**Terraform ensures consistent, repeatable, and version-controlled infrastructure deployment.**

VPC, Subnets, IGW, Routes → Create the private network and internet connectivity for the application.

Security Groups → Control inbound and outbound network access securely.

ECS Cluster → Provides the compute environment for running containers.

Task Definitions → Define how each container runs and behaves.

ECS Services → Keep containers running and maintain desired state.

ALB → Distributes traffic across services reliably.

Target Groups → Connect load balancer traffic to ECS services.

Listener Rules → Route requests based on URL paths.


`terraform init`
  
`terraform plan`

`terraform apply`

`terraform output`





<img width="700" height="500" alt="Screenshot (7)" src="https://github.com/user-attachments/assets/75c0b8d9-39b3-43b1-97d8-a6ee5dc707d4" />

---


## ALB Routing Rules

`/` → Frontend

`/api/*` → Backend

`/notify/*` → Backend

`/taskstatus/*` → Backend

`/health` → Backend


## ECS Design

**Services:**

ECS Services Orchestrates and maintains healthy, scalable container workloads.

frontend-service

backend-service

celery-service

<img width="700" height="500" alt="Screenshot (18)" src="https://github.com/user-attachments/assets/e1941e86-4f87-4e75-b374-6d36fc22feb6" />


**Networking:**

ALB in public subnet

ECS in private subnets


<img width="700" height="500" alt="Screenshot 2026-02-21 000609" src="https://github.com/user-attachments/assets/c5595935-5f34-45ed-bb57-ae55b4494e07" />


---


## CI/CD Pipeline (Planned Implementation)

CI/CD enables automated build, test, image creation, and deployment pipelines for continuous delivery of the application.

Source Control (GitHub) → Centralized version control for code management.

CI Pipeline → Automatically builds and tests code on every commit.

Docker Build Stage → Creates container images from source code.

Image Registry (ECR) → Stores versioned container images.

CD Pipeline → Automatically deploys new images to ECS services.

Terraform Automation → Applies infrastructure changes through pipeline.

Deployment Strategy → Supports rolling or blue-green deployments.


---


## CloudWatch Logs:

Observability is critical in distributed systems for reliability and root cause analysis.

/ecs/frontend

/ecs/backend

/ecs/celery

<img width="700" height="500" alt="Screenshot 2026-02-19 144041" src="https://github.com/user-attachments/assets/040b5af1-cc94-42e9-a049-fe9208ec4fec" />



## Errors & Debugging

**Issues:**

Following are the error i have faced during the cloud deployment:

501 errors

504 timeouts

Health check failures

ALB routing errors

Target group health issues

<img width="500" height="300" alt="Screenshot 2026-02-22 200923" src="https://github.com/user-attachments/assets/10354c89-50ce-4833-a0b5-905976358a12" />
<img width="500" height="300" alt="Screenshot 2026-02-21 180926" src="https://github.com/user-attachments/assets/cf72e20a-2531-465d-be22-452bb3597e1e" />
<img width="500" height="300" alt="Screenshot 2026-02-22 201230" src="https://github.com/user-attachments/assets/289dddb8-402b-4d82-9579-56a4e76c466b" />
<img width="500" height="300" alt="Screenshot 2026-02-19 040937" src="https://github.com/user-attachments/assets/44f47512-8261-49ed-93f0-774683119893" />



**Debugging Tools:**

CloudWatch, ECS Events, ALB health checks, and Terraform state collectively enable full-stack observability, service-level diagnostics, infrastructure validation, and rapid root-cause analysis across the application and cloud resources.

CloudWatch

ECS events

ALB health checks

Terraform state


<img width="500" height="300" alt="Screenshot (24)" src="https://github.com/user-attachments/assets/fd855ec8-aaae-464c-9401-cf96bb11877e" />
<img width="500" height="300" alt="Screenshot (27)" src="https://github.com/user-attachments/assets/36296f61-fc7e-4d9f-8039-6f97d979cb17" />
<img width="500" height="300" alt="Screenshot (26)" src="https://github.com/user-attachments/assets/511080a6-4e1a-4047-b2f2-d7d9bd6fc620" />
<img width="500" height="300" alt="Screenshot (28)" src="https://github.com/user-attachments/assets/07302e9a-f6ce-4af2-9d3c-bcb95a7fe568" />



---


## Conclusion

The Task Notifier project successfully demonstrates a multi-tier web application deployed on the cloud. End-to-end workflow achieved.
User triggers a task → Backend processes it → Frontend shows real-time status.

**Final Outputs:**

<img width="500" height="300" alt="Screenshot (29)" src="https://github.com/user-attachments/assets/70f33543-f326-4703-ad60-26350ac4464d" />
<img width="500" height="300" alt="Screenshot (30)" src="https://github.com/user-attachments/assets/decc9a2a-0908-41ca-a684-06ab17063bbf" />


**This project was not just coding - it was learning the full DevOps journey, from local containers to cloud deployment, monitoring, and troubleshooting.**
