let prompts = [
  {
    type: "input",
    name: "namespaceName",
    message: "Enter the namespace name:",
    default: "tekton-namespace"
  },
  {
    type: "input",
    name: "componentName",
    message: "Enter the component name:",
    default: "tekton-pipeline"
  },
  {
    type: "list",
    name: "githubpatToken",
    message: "Enter your git hub pat token:",
    default: "gresgtrdhdryjhtyhjnt"
  },
  {
    type: "input",
    name: "imageRepositoryURL",
    message: "Enter your image repository URL Name:",
    default: "ticacr.azurecr.io/azure-go:latest"
  },
  {
    type: "input",
    name: "projectName",
    message: "Enter your project name:",
    default: "project1"
  },
  {
    type: "input",
    name: "dockerConfig",
    message: "Enter your base64-encoded docker login config-json:",
    default: "shggjhgjkglhfkjhk"
  },
  {
    type: "input",
    name: "volumeId",
    message: "Enter your volume Id:",
    default: "shggjhgjkglhfkjhk"
  },
  {
    type: "input",
    name: "github org",
    message: "Enter your github org:",
    default: "shggjhgjkglhfkjhk"
  }
];

module.exports = prompts;
