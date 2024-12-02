# #!/bin/bash

# # Navigate to the script's directory to ensure relative paths work
# cd "$(dirname "$0")"

# # Prompt for GitHub username and PAT token
# read -p "Enter your GitHub username: " GITHUB_USERNAME
# read -p "Enter your GitHub PAT token: " GITHUB_PAT
# echo

# # Define the parent directory containing the subdirectories
# PARENT_DIR="../"

# # Loop through all entries in the parent directory
# for ENTRY in "$PARENT_DIR"/*; do
#     # Check if it's a valid directory and not a file
#     if [ -d "$ENTRY" ]; then
#         DIR_NAME=$(basename "$ENTRY")

#         # Skip specific files or directories
#         if [[ "$DIR_NAME" == "blueprints" || "$DIR_NAME" == "HOW_TO_RUN.md" || "$DIR_NAME" == *.zip ]]; then
#             echo "Skipping $DIR_NAME..."
#             continue
#         fi

#         echo "Processing $DIR_NAME..."

#         # Create the GitHub repository as private
#         REPO_URL="https://api.github.com/user/repos"
#         REPO_NAME=$DIR_NAME
#         RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Authorization: token $GITHUB_PAT" \
#             -d "{\"name\": \"$REPO_NAME\", \"private\": true}" $REPO_URL)

#         if [ "$RESPONSE" -ne 201 ]; then
#             echo "Error: Failed to create private GitHub repository for $DIR_NAME. HTTP Status Code: $RESPONSE"
#             continue
#         fi

#         echo "Private GitHub repository '$REPO_NAME' created successfully."

#         # Initialize Git in the directory
#         cd "$ENTRY"
#         if [ ! -d ".git" ]; then
#             git init
#             echo "Initialized Git repository in $ENTRY"
#         fi

#         # Add all files, commit, and push to GitHub
#         GIT_REPO_URL="https://$GITHUB_USERNAME:$GITHUB_PAT@github.com/$GITHUB_USERNAME/$REPO_NAME.git"
#         git remote add origin "$GIT_REPO_URL" 2>/dev/null || git remote set-url origin "$GIT_REPO_URL"
#         git add .
#         git commit -m "Initial commit"
#         git branch -M main
#         git push -u origin main

#         echo "Code from $ENTRY pushed to private repository '$REPO_NAME' on GitHub."
#         cd - >/dev/null
#     fi
# done

# echo "All directories processed."

######################################################################################################################

#!/bin/bash

# Navigate to the script's directory to ensure relative paths work
cd "$(dirname "$0")"

# Prompt for GitHub username, PAT token, and AWS credentials
read -p "Enter your GitHub username: " GITHUB_USERNAME
read -p "Enter your GitHub PAT token: " GITHUB_PAT
echo
read -p "Enter your AWS Access Key: " AWS_ACCESS_KEY
read -p "Enter your AWS Secret Key: " AWS_SECRET_KEY
read -p "Enter your AWS Region: " AWS_REGION
echo

# Define the parent directory containing the subdirectories
PARENT_DIR="../"

# Set AWS credentials for the current session
export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_KEY"
export AWS_DEFAULT_REGION="$AWS_REGION"

# Loop through all entries in the parent directory
for ENTRY in "$PARENT_DIR"/*; do
    # Check if it's a valid directory and not a file
    if [ -d "$ENTRY" ]; then
        DIR_NAME=$(basename "$ENTRY")

        # Skip specific files or directories
        if [[ "$DIR_NAME" == "blueprints" || "$DIR_NAME" == "HOW_TO_RUN.md" || "$DIR_NAME" == *.zip ]]; then
            echo "Skipping $DIR_NAME..."
            continue
        fi

        echo "Processing $DIR_NAME..."

        # Create the GitHub repository as private
        REPO_URL="https://api.github.com/user/repos"
        REPO_NAME=$DIR_NAME
        RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Authorization: token $GITHUB_PAT" \
            -d "{\"name\": \"$REPO_NAME\", \"private\": true}" $REPO_URL)

        if [ "$RESPONSE" -ne 201 ]; then
            echo "Error: Failed to create private GitHub repository for $DIR_NAME. HTTP Status Code: $RESPONSE"
            continue
        fi

        echo "Private GitHub repository '$REPO_NAME' created successfully."

        # Create the AWS ECR repository
        ECR_REPO_NAME=$DIR_NAME
        ECR_RESPONSE=$(aws ecr create-repository --repository-name "$ECR_REPO_NAME" --region "$AWS_REGION" \
            --query 'repository.repositoryUri' --output text 2>&1)

        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to create ECR repository for $ECR_REPO_NAME. AWS CLI Error: $ECR_RESPONSE"
            continue
        fi

        echo "AWS ECR repository '$ECR_REPO_NAME' created successfully."

        # Initialize Git in the directory
        cd "$ENTRY"
        if [ ! -d ".git" ]; then
            git init
            echo "Initialized Git repository in $ENTRY"
        fi

        # Add all files, commit, and push to GitHub
        GIT_REPO_URL="https://$GITHUB_USERNAME:$GITHUB_PAT@github.com/$GITHUB_USERNAME/$REPO_NAME.git"
        git remote add origin "$GIT_REPO_URL" 2>/dev/null || git remote set-url origin "$GIT_REPO_URL"
        git add .
        git commit -m "Initial commit"
        git branch -M main
        git push -u origin main

        echo "Code from $ENTRY pushed to private repository '$REPO_NAME' on GitHub."
        cd - >/dev/null
    fi
done

echo "All directories processed."
###########################################################################################################

echo ""
echo "\033[1mPrerequisite:\033[0m"
echo " 1. Make sure that your cluster is up and running and installed kubectl and k8s dashboard"
echo " 2. Make sure that you have installed tekton cli."
echo " 3. Create EBS Volume for Tekton CI-CD."
echo ""

echo "Enter your Image URI:"
echo "Image Uri Should be Like This:" 
echo "Name of the ACR Registry.Domain for ACR/Name of the Docker image:latest Ex: ticacr.azurecr.io/azure-go:latest":
read -p IMAGE_URI

echo "Enter Your Encoded Docker Config File:"
read -p DOCKER_CONFIG

echo "Enter Your Volume ID:"
read -p VOLUME_ID

export IMAGE_URI="$IMAGE_URI"
export DOCKER_CONFIG="$DOCKER_CONFIG"
export VOLUME_ID="$VOLUME_ID"

check_command() {
  if [ $? -ne 0 ]; then
    echo "Error: $1 failed. Exiting."
    exit 1
  fi
}

# Install Tekton CLI
echo "Installing Tekton CLI..."
linktothepackage="tektoncd-cli-0.33.0_Linux-64bit.deb"
curl -LO https://github.com/tektoncd/cli/releases/download/v0.33.0/${linktothepackage}
check_command "Download Tekton CLI package"
sudo dpkg -i ./${linktothepackage}
check_command "Install Tekton CLI package"
echo ""

# Prerequisites
echo -e "\033[1mPrerequisite:\033[0m"
echo " 1. Make sure that your cluster is up and running and you have installed kubectl and k8s dashboard"
echo " 2. Make sure that you have installed tekton cli."
echo ""

# Install Tekton Pipelines
echo "Installing Tekton Pipelines..."
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
check_command "Install Tekton Pipelines"
echo ""

# Install Tekton Triggers
echo "Installing Tekton Triggers..."
kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
check_command "Install Tekton Triggers"
kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
check_command "Install Tekton Interceptors"
echo ""

# Install Tekton Dashboard
echo "Installing Tekton Dashboard..."
kubectl apply --filename https://storage.googleapis.com/tekton-releases/dashboard/latest/release-full.yaml
check_command "Install Tekton Dashboard"
echo ""

# Expose Tekton Dashboard via NodePort
echo "Exposing Tekton Dashboard via NodePort..."
kubectl -n tekton-pipelines patch svc tekton-dashboard -p '{"spec": {"type": "NodePort"}}'
check_command "Expose Tekton Dashboard"
echo ""

# Get the NodePort and Node IP
node_port=$(kubectl get svc tekton-dashboard -n tekton-pipelines -o jsonpath='{.spec.ports[0].nodePort}')
node_ip=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

echo "Tekton Dashboard is available at http://${node_ip}:${node_port}"
echo ""

# Install Cluster Autoscaler
echo "Installing Cluster Autoscaler..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
check_command "Install Cluster Autoscaler"
echo ""

# Verify Installation
echo "Verifying installation..."
kubectl get pods --namespace tekton-pipelines
check_command "Verify installation"
echo ""

# Print completion message
echo "Tekton installation is complete."
echo "Run the following command to get the Tekton Dashboard NodePort:"
echo "kubectl get svc -n tekton-pipelines tekton-dashboard"

echo ""
kubectl apply -f account/00-namespace.yml
echo ""

sleep 30

echo ""
kubectl apply -f account/01-secrets.yml
kubectl apply -f account/02-rbac.yml
kubectl apply -f account/03-storageclass.yml
kubectl apply -f account/04-pvc.yml
kubectl apply -f account/05-pv.yml
kubectl apply -f account/06-serviceaccount.yml
echo ""

sleep 30

echo ""
echo "Installing requrired tasks from tekton hub"
echo ""

echo ""
kubectl apply -f task/github-clone-repo-task.yml
kubectl apply -f task/get-commit-sha-task.yml
kubectl apply -f task/test-cases-task.yml
kubectl apply -f task/docker-buid-push-task.yml
kubectl apply -f task/deploy-task.yml
kubectl apply -f task/send-status-to-github-task.yml
echo ""

echo ""
echo "Creating requrired Pipelines"
echo ""

echo ""
kubectl apply -f pipelines/push-pipeline.yml
kubectl apply -f pipelines/pr-test-cases-pipeline.yml
echo ""

echo ""
echo "Creating requrired Pipelineruns"
echo ""

echo ""
kubectl apply -f pipelineruns/pr-test-cases-pipelinerun.yml
kubectl apply -f pipelineruns/push-pipelinerun.yml
echo ""

echo ""
echo "Creating requrired Triggers"
echo ""

echo ""
kubectl apply -f triggers/triggers.yml
echo ""




