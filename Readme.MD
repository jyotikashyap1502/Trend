# Brain Task Project

## Prerequisites

Before starting, ensure the following tools are installed on your system:

- **AWS CLI:** v2.31+ (`aws --version`)
- **Docker:** v20.10+ (`docker --version`)
- **Terraform:** v1.6+ (`terraform --version`)
- **kubectl:** v1.28+ (`kubectl version --client`)
- **eksctl:** v0.180+ (`eksctl version`)
- **Node.js:** v18+ (`node --version`)
- **npm:** v9+ (`npm --version`)

If any tool is missing, refer to the installation guides in the official documentation or see Step 1.1 of the deployment guide below.



## Running the Project

Follow these steps to run the project locally:

1. Navigate to the project directory:

```bash
cd path/to/trend 
```

2. Install the `serve` package globally:

```bash
sudo npm install -g serve
```

3. Verify the installation:

```bash
serve -v
```

4. Serve the production build:

```bash
serve -s dist
```

The project should now be running locally, and you can access it in your browser.

## after creating Docker File

# Build Docker image
docker build -t trend-app:latest .

# Run the container
docker run -d -p 3000:80 trend-app:latest

# go to the browser and test it.
test the project on localhost

----------------
Step 1.2: Configure AWS Credentials
If this is your first time using AWS CLI, configure your credentials:
# Configure AWS CLI (use your AWS credentials)
aws configure
# AWS Access Key ID: YOUR_ACCESS_KEY
# AWS Secret Access Key: YOUR_SECRET_KEY
# Default region name: ap-south-1  (or your preferred region)
# Default output format: json

If AWS CLI is already configured, verify your setup with:

# Verify current AWS identity and configuration
aws sts get-caller-identity
aws configure list
✅ Example Output:
{
    "UserId": "AIDAEXAMPLEUSERID",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/your-username"
}
✅ Note:
Make sure the region is set to ap-south-1 for this project to ensure all AWS resources are created in the correct region.

Step 1.3: Clone the Repository
# Clone the project
git clone https://github.com/Vennilavan12/Trend.git
cd Trend

Step 1.4: Create Configuration Files

.env.example 
.gitignore
.dockerignore

Step 1.5: Create Project Structure

mkdir -p terraform
mkdir -p kubernetes
mkdir -p jenkins
mkdir -p .github/workflows

# Phase 2: Docker
Step 2.1:Create Dockerfile
Step 2.2: Build and Test Docker Image Locally

# Build the Docker image
docker build -t trend-app:latest .

# Run the container locally
docker run -d -p 3000:3000 --name trend-app-test trend-app:latest

# Check if container is running
docker ps

# Test the application
curl http://localhost:3000
# Or open in browser: http://localhost:3000

# Check container logs
docker logs trend-app-test

# Stop and remove test container
docker stop trend-app-test
docker rm trend-app-test

# Phase 3: Terraform Infrastructure

Step 3.1: Create Terraform Configuration
terraform/main.tf

# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

Step 3.3: Deploy Infrastructure
cd terraform

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Preview changes
terraform plan

# Apply configuration (this will create resources)
terraform apply

# Type 'yes' when prompted

# Save outputs
terraform output > ../terraform-outputs.txt //⚠️ Important: Note down the Jenkins public IP from the output!

# Phase 4: DockerHub Setup (15 minutes)

Step 4.1: Create DockerHub Repository

Name: trend-app 
Visibility: Public

Step 4.2: Push Image to DockerHub

# Login to DockerHub
docker login
# Enter your DockerHub username and password

# Tag your image
docker tag trend-app:latest YOUR_DOCKERHUB_USERNAME/trend-app:latest

# Push to DockerHub
docker push YOUR_DOCKERHUB_USERNAME/trend-app:latest

# Verify push
docker pull YOUR_DOCKERHUB_USERNAME/trend-app:latest

# Phase 5: Kubernetes (AWS EKS) 
Step 5.1: Create EKS Cluster
# Create EKS cluster 
eksctl create cluster \
  --name trend-cluster \
  --region ap-south-1 \
  --nodegroup-name trend-nodes \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 3 \
  --managed

# Verify cluster
kubectl get nodes

# Update kubeconfig
aws eks update-kubeconfig --name trend-cluster --region ap-south-1

Step 5.2: Create Kubernetes Manifests

create 
kubernetes/deployment.yaml
kubernetes/service.yaml

Step 5.3: Deploy to Kubernetes

cd kubernetes

# Apply deployment
kubectl apply -f deployment.yaml

# Apply service
kubectl apply -f service.yaml

# Check deployment status
kubectl get deployments
kubectl get pods
kubectl get services

# Wait for LoadBalancer to be ready (may take 2-3 minutes)
kubectl get svc trend-app-service -w

# Get the LoadBalancer URL
kubectl get svc trend-app-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'


## Common Issues & Solutions for above step - we have fixed this 

### 1. Exec Format Error (ARM64 vs AMD64)
If deploying from Apple Silicon Mac (M1/M2/M3), always build Docker images for AMD64:
```bash
docker buildx build --platform linux/amd64 -t your-image:tag --push .
```

### 2. LoadBalancer Pending State
If LoadBalancer stuck in `<pending>`:
- Check `kubectl describe svc <service-name>` for errors
- Verify subnet tags for ELB
- Remove unsupported sessionAffinity configurations
- Ensure AWS service limits not exceeded

### 3. ImagePullBackOff
- Verify DockerHub image name is correct in deployment.yaml
- Ensure image is public or ImagePullSecrets configured
- Check DockerHub repository exists

### 4. CrashLoopBackOff
- Check pod logs: `kubectl logs <pod-name>`
- Verify application runs correctly in Docker locally
- Check resource limits and health checks

#save the url loadbalancer-url.txt
echo $LB_URL > ../loadbalancer-url.txt

# Phase 6: Jenkins CI/CD Pipeline 
Step 6.1: Access Jenkins

# Get Jenkins initial password
ssh -i ~/.ssh/id_rsa ubuntu@JENKINS_PUBLIC_IP

sudo cat /var/lib/jenkins/secrets/initialAdminPassword
# Copy this password

# Exit SSH
exit


Visit: http://JENKINS_PUBLIC_IP:8080

Enter the initial admin password
Click "Install suggested plugins"
Create admin user
Save and Continue

Step 6.2: Install Required Plugins

Go to "Manage Jenkins" → "Manage Plugins"
Click "Available" tab
Search and install:

Docker Pipeline
Kubernetes
Git
GitHub Integration
Pipeline


Click "Install without restart"
Check "Restart Jenkins when installation is complete"

Step 6.3: Configure Credentials
DockerHub Credentials:

"Manage Jenkins" → "Credentials" → "System" → "Global credentials"
"Add Credentials"

Kind: Username with password
Username: YOUR_DOCKERHUB_USERNAME
Password: YOUR_DOCKERHUB_PASSWORD
ID: dockerhub-credentials



GitHub Credentials:

Generate GitHub Personal Access Token:

GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
Generate new token with repo and admin:repo_hook scopes


Add to Jenkins:

Kind: Secret text
Secret: YOUR_GITHUB_TOKEN
ID: github-token


AWS Credentials (if not using IAM role):

"Add Credentials"
# commant -if not see Kind: AWS Credentials add plugin of AWS Credentials in jenkins->manage plugin search and add it- then follow bellow

Kind: AWS Credentials
ID: aws-credentials
Access Key ID: YOUR_AWS_ACCESS_KEY
Secret Access Key: YOUR_AWS_SECRET_KEY

# Step 6.4: Configure Kubernetes in Jenkins

# SSH back into Jenkins server
ssh -i ~/.ssh/id_rsa ubuntu@JENKINS_PUBLIC_IP

# Copy kubeconfig
sudo mkdir -p /var/lib/jenkins/.kube
sudo aws eks update-kubeconfig --name trend-cluster --region ap-south-1 --kubeconfig /var/lib/jenkins/.kube/config
sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube

exit


Step 6.6: Create Jenkins Pipeline Job

Jenkins Dashboard → "New Item"
Name: trend-app-pipeline
Type: "Pipeline"
Click "OK"

Configure:

Build Triggers:

Check "GitHub hook trigger for GITScm polling"


Pipeline:

Definition: "Pipeline script from SCM"
SCM: Git
Repository URL: https://github.com/Vennilavan12/Trend.git
Credentials: Select your GitHub token
Branch: */main
Script Path: Jenkinsfile




Click "Save"

Step 6.7: Set Up GitHub Webhook

Go to your GitHub repository
Settings → Webhooks → Add webhook
Payload URL: http://JENKINS_PUBLIC_IP:8080/github-webhook/
Content type: application/json
Disable SSL verification 
Events: "Just the push event"
Click "Add webhook"

Step 6.8: Test the Pipeline
cd /path/to/Trend
git add Jenkinsfile
git commit -m "Add Jenkins pipeline"
git push origin main