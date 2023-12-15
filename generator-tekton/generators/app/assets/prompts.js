let prompts = [
  {
    type: "input",
    name: "namespaceName",
    message: "Enter the namespace name:",
    default: "tekton-namespace"
  },
  {
    type: "input",
    name: "pipelineName",
    message: "Enter the pipeline name:",
    default: "tekton-pipeline"
  },
  {
    type: "list",
    name: "repoType",
    message: "Enter your repository Type:",
    choices: ["private", "public"]
  },
  {
    when: props => props.repoType === "private",
    type: "input",
    name: "repoURL",
    message: "Enter your git repository ssh URL:",
    default: "git@github.com:Nandiniperikala/spring.git"
  },
  {
    when: props => props.repoType === "public",
    type: "input",
    name: "repoURL",
    message: "Enter your git repository https URL:",
    default: "https://github.com/Nandiniperikala/private.git"
  },
  {
    when: props => props.repoType === "private",
    type: "input",
    name: "deployKey",
    message: "Enter your base64-encoded ssh privateKey:",
    default: "gjhygfkujyhglkioh;loi;ewtgreyh"
  },
  {
    when: props => props.repoType === "private",
    type: "input",
    name: "sshConfig",
    message: "Enter your base64-encoded ssh_config file:",
    default: "gjhygfkujyhglkioh;loi;ewtgreyh"
  },
  {
    type: "input",
    name: "branch",
    message: "Enter your branch name:",
    default: "main"
  },
  {
    type: "list",
    name: "buildStrategy",
    message: "Enter your buildstrategy:",
    choices: ["Dockerfile", "jib-maven(for java)"]
  },
  {
    when: props => props.buildStrategy === "Dockerfile",
    type: "list",
    name: "DockerfilePath",
    message: "Enter your DockerfilePath:",
    choices: ["root", "Directory"]
  },
  {
    when: props =>
      props.buildStrategy === "Dockerfile" &&
      props.DockerfilePath === "Directory",
    type: "input",
    name: "PathtoContext",
    message: "Enter your Docker file directory path:",
    default: "go"
  },
  {
    when: props =>
      props.buildStrategy === "Dockerfile" &&
      props.DockerfilePath === "Directory",
    type: "input",
    name: "PathtoDockerfile",
    message: "Enter your Docker file path:",
    default: "go/Dockerfile"
  },
  {
    when: props => props.buildStrategy === "jib-maven(for java)",
    type: "list",
    name: "PathToPomFile",
    message: "Enter your PathToPomFile:",
    choices: ["root", "Directory"]
  },
  {
    when: props =>
      props.buildStrategy === "jib-maven(for java)" &&
      props.PathToPomFile === "Directory",
    type: "input",
    name: "PathToPomFile",
    message: "Enter your Pom.xml directory Path:",
    default: "go/Dockerfile"
  },
  {
    type: "input",
    name: "dockerConfig",
    message: "Enter your base64-encoded docker login config-json:",
    default: "shggjhgjkglhfkjhk"
  },
  {
    type: "input",
    name: "imageRepositoryURL",
    message: "Enter your image repository URL Name:",
    default: "ticacr.azurecr.io/azure-go:latest"
  },
  {
    type: "list",
    name: "SonarQube",
    message: "Include SonarQube for code quality analysis?",
    choices: ["yes", "no"]
  },
  {
    type: "list",
    name: "k8sEnvironment",
    message: "Enter your k8sEnvironment:",
    choices: ["azure", "aws", "minikube"]
  }
];

module.exports = prompts;
