# CLO835 Assignment 1: Containerized Web Application Deployment on AWS

This project provisions an AWS infrastructure with Terraform, builds and pushes Docker images to Amazon ECR using GitHub Actions, and deploys containers on an EC2 instance.

---

## 📌 Project Structure

```
.
├── app/                # Web application Dockerfile
├── mysql/              # MySQL container Dockerfile
├── terraform/          # Terraform infrastructure config
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── user_data.sh
└── .github/
    └── workflows/
        └── deploy.yml  # GitHub Actions workflow
```

---

## 📌 Prerequisites

* AWS Cloud9 Lab environment (VocLabs)
* AWS CLI v2 installed on EC2 and Cloud9
* Docker installed on EC2
* Terraform installed on Cloud9
* Existing AWS key pair
* Existing IAM Role (e.g., `LabRole`) and Instance Profile (`LabInstanceProfile`) with `AmazonEC2ContainerRegistryReadOnly` permissions

---

## 📌 1️⃣ Infrastructure Deployment with Terraform

### 1. SSH into your Cloud9 environment and clone this repo:

```bash
git clone <your-github-repo-url>
cd clo835_summer_assignment1/terraform
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Apply Terraform configuration

```bash
terraform apply -auto-approve
```

This will:

* Create an EC2 instance
* Create ECR repositories for `clo835-webapp` and `clo835-mysql`
* Create a security group
* Output public IP and SSH command

---

## 📌 2️⃣ Configure GitHub Actions Secrets

Go to your GitHub repository:
**Settings → Secrets and variables → Actions**

Add:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`
* `AWS_SESSION_TOKEN`

*Get these from your Cloud Labs session.*

---

## 📌 3️⃣ Trigger Docker Image Build & Push

Each time you push code to the `main` branch:

```bash
git add .
git commit -m "Deploy workflow and Dockerfiles"
git push origin main
```

GitHub Actions will:

* Build Docker images for `app` and `mysql`
* Push them to ECR

Check images under **AWS Console → ECR**

---

## 📌 4️⃣ SSH into EC2 Instance

Use the SSH command from Terraform output:

```bash
ssh -i ~/.ssh/clo835-assignment1-key ec2-user@<EC2_PUBLIC_IP>
```

---

## 📌 5️⃣ Install Docker on EC2

```bash
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
exit
```

Reconnect:

```bash
ssh -i ~/.ssh/clo835-assignment1-key ec2-user@<EC2_PUBLIC_IP>
```

---

## 📌 6️⃣ Attach IAM Role to EC2 Instance

**In AWS Console:**

* EC2 → Instances → Actions → Security → Modify IAM Role
* Attach `LabInstanceProfile`

---

## 📌 7️⃣ Verify AWS CLI Access

```bash
aws sts get-caller-identity
```

✅ Should return identity info.

---

## 📌 8️⃣ Authenticate Docker with ECR

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 822626594509.dkr.ecr.us-east-1.amazonaws.com
```

---

## 📌 9️⃣ Pull Docker Images from ECR

```bash
docker pull 822626594509.dkr.ecr.us-east-1.amazonaws.com/clo835-webapp:latest
docker pull 822626594509.dkr.ecr.us-east-1.amazonaws.com/clo835-mysql:latest
```

---

## 📌 🔟 Create Docker Network

```bash
docker network create my-app-network
```

---

## 📌 1️⃣1️⃣ Run MySQL Container

```bash
docker run -d --network my-app-network --name mysql-container \
-e MYSQL_ROOT_PASSWORD=password \
-e MYSQL_DATABASE=employees \
-e MYSQL_USER=root \
-e MYSQL_PASSWORD=password \
822626594509.dkr.ecr.us-east-1.amazonaws.com/clo835-mysql:latest
```

---

## 📌 1️⃣2️⃣ Test MySQL Container

```bash
docker run --network my-app-network --rm mysql:latest \
mysql -h mysql-container -u root -ppassword -e "SHOW DATABASES;"
```

---

## 📌 1️⃣3️⃣ Run WebApp Containers

**Blue:**

```bash
docker run -d --network my-app-network --name blue-container \
-p 8081:8080 \
-e DB_HOST=mysql-container \
-e DB_NAME=employees \
-e DB_USER=root \
-e DB_PASSWORD=password \
-e BACKGROUND_COLOR=blue \
822626594509.dkr.ecr.us-east-1.amazonaws.com/clo835-webapp:latest
```

**Pink:**

```bash
docker run -d --network my-app-network --name pink-container \
-p 8082:8080 \
-e DB_HOST=mysql-container \
-e DB_NAME=employees \
-e DB_USER=root \
-e DB_PASSWORD=password \
-e BACKGROUND_COLOR=pink \
822626594509.dkr.ecr.us-east-1.amazonaws.com/clo835-webapp:latest
```

**Lime:**

```bash
docker run -d --network my-app-network --name lime-container \
-p 8083:8080 \
-e DB_HOST=mysql-container \
-e DB_NAME=employees \
-e DB_USER=root \
-e DB_PASSWORD=password \
-e BACKGROUND_COLOR=lime \
822626594509.dkr.ecr.us-east-1.amazonaws.com/clo835-webapp:latest
```

---

## 📌 1️⃣4️⃣ Verify Running Containers

```bash
docker ps
```

---

## 📌 1️⃣5️⃣ Test Application URLs

Open browser:

```
http://<EC2_PUBLIC_IP>:8081
http://<EC2_PUBLIC_IP>:8082
http://<EC2_PUBLIC_IP>:8083
```

✅ You should see your app with blue, pink, and lime backgrounds.

---

## 📌 1️⃣6️⃣ Test Container-to-Container Communication

```bash
docker exec -it blue-container bash
ping pink-container
ping lime-container
ping mysql-container
exit
```

---

## 📌 1️⃣7️⃣ Destroy Infrastructure

To remove all AWS resources:

```bash
cd terraform/
terraform destroy -auto-approve
```

✅ If ECR deletion errors occur:

* Manually delete images in ECR Console
* Or add `force_delete = true` in your Terraform `aws_ecr_repository` resources

---
