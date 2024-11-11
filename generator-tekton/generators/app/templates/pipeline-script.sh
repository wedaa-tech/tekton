# /bin/bash

#!/bin/bash

# Variables
TOKEN="your_github_pat"   # Replace with your actual GitHub PAT
ORG="your_org_name"   # Optional: specify if you're creating under an organization; leave blank for personal account

# Array of repositories to create with name and description
# Add each repository name and description as elements
REPOS=(
  "<%= ComponentName %>:go"
  "<%= ComponentName %>:spring"
  "<%= ComponentName %>:python"
  "<%= ComponentName %>:react"
  "<%= ComponentName %>:angular"
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
namespace="<%= namespaceName %>"
tkn hub install task git-clone -n ${namespace}
<%_ if (buildStrategy == "Dockerfile") { _%>
tkn hub install task kaniko  -n ${namespace}
<%_ } _%>
<%_ if (buildStrategy == "jib-maven(for java)") { _%>
tkn hub install task jib-maven -n ${namespace}
<%_ } _%>
<%_ if (SonarQube == "yes") { _%>
tkn hub install task sonarqube-scanner -n ${namespace}
<%_ } _%>
echo ""

sleep 30

echo ""
kubectl apply -f pipeline-yml-files/01-secrets.yml
kubectl apply -f pipeline-yml-files/02-rbac.yml
kubectl apply -f pipeline-yml-files/03-pipeline.yml
<%_ if (k8sEnvironment == "minikube") { _%>
kubectl create -f pipeline-yml-files/04-pipelinerun.yml
<%_ } else { _%>
kubectl apply -f pipeline-yml-files/04-event-listener.yml
kubectl apply -f pipeline-yml-files/05-triggers.yml
<%_ } _%>
echo ""

echo ""
echo "Access tekton dashboard in web http://localhost:9097"
echo ""

kubectl port-forward -n tekton-pipelines service/tekton-dashboard 9097:9097


