#!/bin/bash

# Navigate to the script's directory to ensure relative paths work
cd "$(dirname "$0")"

# Prompt for GitHub username and PAT token
read -p "Enter your GitHub username: " GITHUB_USERNAME
read -p "Enter your GitHub PAT token: " GITHUB_PAT
echo

# Define the parent directory containing the subdirectories
PARENT_DIR="../"

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
read  IMAGE_URI

echo "Enter Your Encoded Docker Config File:"
read DOCKER_CONFIG

echo "Enter Your Volume ID:"
read  VOLUME_ID

echo "Enter Your AWS_ACCESS_KEY_ID:"
read  AWS_ACCESS_KEY_ID

echo "Enter Your AWS_SECRET_ACCESS_KEY:"
read  AWS_SECRET_ACCESS_KEY

echo "Enter Your AWS_REGION:"
read  AWS_REGION


echo ""
echo "Installing tekton cli."
linktothepackage="tektoncd-cli-0.33.0_Linux-64bit.deb"
curl -LO https://github.com/tektoncd/cli/releases/download/v0.33.0/${linktothepackage}
sudo dpkg -i ./${linktothepackage}
echo ""




kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
kubectl apply --filename \
https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl apply --filename \
https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
kubectl apply --filename \
https://storage.googleapis.com/tekton-releases/dashboard/latest/release-full.yaml


echo ""
kubectl apply -f pipeline-yml-files/00-namespace.yml
echo ""

sleep 30

echo ""
echo "Installing requrired tasks from tekton hub"
echo ""

echo ""
namespace="<%= namespaceName %>"
tkn hub install task git-clone -n ${namespace}

tkn hub install task kaniko  -n ${namespace}


tkn hub install task jib-maven -n ${namespace}


tkn hub install task sonarqube-scanner -n ${namespace}

echo ""

sleep 30

echo ""
kubectl apply -f pipeline-yml-files/01-secrets.yml
kubectl apply -f pipeline-yml-files/02-rbac.yml
kubectl apply -f pipeline-yml-files/03-pipeline.yml

kubectl create -f pipeline-yml-files/04-pipelinerun.yml

kubectl apply -f pipeline-yml-files/04-event-listener.yml
kubectl apply -f pipeline-yml-files/05-triggers.yml

echo ""

echo ""
echo "Access tekton dashboard in web http://localhost:9097"
echo ""

kubectl port-forward -n tekton-pipelines service/tekton-dashboard 9097:9097


