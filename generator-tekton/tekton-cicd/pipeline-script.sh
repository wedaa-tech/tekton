#!/bin/bash

echo "Before continuing, please go and fill the values in config.env file and come back here."
read -p "Did you fill the values in config.env? (yes/no): " response

# Check the user's response
if [[ "$response" == "yes" ]]; then
    echo "Great! Proceeding with the script..."
   

# Navigate to the script's directory
cd "$(dirname "$0")"

# Load configuration from env or a config file
source ./config.env || { echo "Error: Missing config.env file."; exit 1; }

# Check command execution status
check_command() {
  if [ $? -ne 0 ]; then
    echo "Error: $1 failed. Exiting."
    exit 1
  fi
}

# Set credentials
# Create a GitHub repository
create_github_repo() {
  local repo_name="$1"
  local response

  response=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Authorization: token $GITHUB_PAT" \
    -d "{\"name\": \"$repo_name\", \"private\": true}" "https://api.github.com/user/repos")

  if [ "$response" -ne 201 ]; then
    echo "Error: Failed to create GitHub repository '$repo_name'. HTTP Code: $response"
    return 1
  fi
  echo "GitHub repository '$repo_name' created successfully."
}

# Initialize Git and push code to GitHub
initialize_git() {
  local dir="$1"
  local repo_name="$2"

  cd "$dir" || return 1
  git init
  git add .
  git commit -m "Initial commit"
  git branch -M main
  git remote add origin "https://$GITHUB_USERNAME:$GITHUB_PAT@github.com/$GITHUB_USERNAME/$repo_name.git"
  git push -u origin main
  cd - >/dev/null || return 1

  echo "Code from $dir pushed to GitHub repository '$repo_name'."
}

# Process directories
process_directories() {
  for dir in ../*; do
    if [ -d "$dir" ]; then
      local repo_name
      repo_name=$(basename "$dir")

      if [[ "$repo_name" == "blueprints" || "$repo_name" == "HOW_TO_RUN.md" || "$repo_name" == *.zip || "$repo_name" == "tekton-cicd" ]]; then
        echo "Skipping $repo_name..."
        continue
      fi

      echo "Processing $repo_name..."
      create_github_repo "$repo_name" || continue
      initialize_git "$dir" "$repo_name"
    fi
  done
}

# Install Tekton components
install_tekton() {
  echo "Installing Tekton CLI..."
  curl -LO "https://github.com/tektoncd/cli/releases/download/v0.33.0/tektoncd-cli-0.33.0_Linux-64bit.deb"
  sudo dpkg -i tektoncd-cli-0.33.0_Linux-64bit.deb
  check_command "Tekton CLI installation"

  echo "Installing Tekton Pipelines..."
  kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
  check_command "Tekton Pipelines installation"

  echo "Installing Tekton Triggers..."
  kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
  check_command "Tekton Triggers installation"
  kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
  check_command "Tekton Interceptors installation"

  echo "Installing Tekton Dashboard..."
  kubectl apply --filename https://storage.googleapis.com/tekton-releases/dashboard/latest/release-full.yaml
  check_command "Tekton Dashboard installation"
  echo "Exposing Tekton Dashboard via NodePort..."
  kubectl -n tekton-pipelines patch svc tekton-dashboard -p '{"spec": {"type": "NodePort"}}'
  check_command "Tekton Dashboard exposure"

  # Get the NodePort and Node IP
  node_port=$(kubectl get svc tekton-dashboard -n tekton-pipelines -o jsonpath='{.spec.ports[0].nodePort}')
  node_ip=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

  echo "Tekton Dashboard is available at http://${node_ip}:${node_port}"
  echo ""
}


# Apply YAML configurations
apply_yaml_configs() {
  for file in account/*.yml; do
    kubectl apply -f "$file"
    check_command "Applying $file"
  done

  for file in task/*.yml; do
    kubectl apply -f "$file"
    check_command "Applying $file"
  done

  for file in pipelines/*.yml; do
    kubectl apply -f "$file"
    check_command "Applying $file"
  done

  for file in pipelineruns/*.yml; do
    kubectl apply -f "$file"
    check_command "Applying $file"
  done

  kubectl apply -f triggers/triggers.yml
  check_command "Applying triggers.yml"
}

# Main function
main() {
  process_directories
  install_tekton
  apply_yaml_configs
  echo "Tekton installation and directory processing complete."
}

main

else
    echo "Please fill the values in config.env and run the script again."
    exit 1
fi
