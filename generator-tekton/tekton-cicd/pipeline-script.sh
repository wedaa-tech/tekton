# /bin/bash

echo "Enter your GitHub User Name:"
read  GITHUB_USER_NAME

echo "Enter your GitHub Personal Access Token (PAT):"
read  TOKEN  

echo "Enter your Image URI:"
read  IMAGE_URI

echo "Enter Your Encoded Docker Config File:"
read DOCKER_CONFIG

echo "Enter Your Volume ID:"
read  VOLUME_ID






# Variables
TOKEN="your_github_pat"   # Replace with your actual GitHub PAT
ORG="your_org_name"   # Optional: specify if you're creating under an organization; leave blank for personal account

# Array of repositories to create with name and description
# Add each repository name and description as elements
REPOS=(
  "trggrt:go"
  "trggrt:spring"
  "trggrt:python"
  "trggrt:react"
  "trggrt:angular"
)

# GitHub API endpoint
API_URL="https://api.github.com"

# Loop through each repository in the array
for repo_info in "${REPOS[@]}"; do
  # Split each entry into repo name and description
  IFS=":" read -r REPO_NAME DESCRIPTION <<< "$repo_info"
  
  # JSON payload
  PAYLOAD=$(jq -n \
    --arg name "$REPO_NAME" \
    --arg description "$DESCRIPTION" \
    --arg private "true" \
    '{name: $name, description: $description, private: ($private == "true")}')

  # Curl command to create the repository
  curl -X POST \
    -H "Authorization: token $TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    -d "$PAYLOAD" \
    "$API_URL/orgs/$ORG/repos"  # For org account
    # "$API_URL/user/repos"       # Uncomment for personal account
  
  echo "Repository '$REPO_NAME' created with description: $DESCRIPTION"
done
##############################################################################################################################

echo ""
echo "Installing tekton cli."
linktothepackage="tektoncd-cli-0.33.0_Linux-64bit.deb"
curl -LO https://github.com/tektoncd/cli/releases/download/v0.33.0/${linktothepackage}
sudo dpkg -i ./${linktothepackage}
echo ""

echo ""
echo "\033[1mPrerequisite:\033[0m"
echo " 1. Make sure that your cluster is up and running and installed kubectl and k8s dashboard"
echo " 2. Make sure that you have installed tekton cli."
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
namespace="ferferfe"
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


