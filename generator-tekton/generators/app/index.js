const Generator = require("yeoman-generator");
const path = require("path");
const fs = require("fs");

module.exports = class extends Generator {
  constructor(args, opts) {
    super(args, opts);

    this.options = {};
    this.props = {};

    if (opts.file) {
      const filePath = path.resolve(opts.file);
      const fileContents = fs.readFileSync(filePath, "utf8");
      this.options = JSON.parse(fileContents);
      this.shouldPrompt = false;
    } else {
      this.shouldPrompt = true;
    }
  }

  prompting() {
    if (!this.shouldPrompt) {
      return;
    }

    return this.prompt(require("./assets/prompts")).then(props => {
      this.props = props;
    });
  }

  writing() {
    const { options, props, shouldPrompt } = this;
    let {
      namespaceName,
      pipelineName,
      dockerConfig,
      repoURL,
      repoType,
      branch,
      imageRepositoryURL,
      PathToPomFile,
      deployKey,
      sshConfig,
      DockerfilePath,
      PathtoContext,
      PathtoDockerfile
    } = shouldPrompt ? props : options;

    const {
      buildStrategy: optionsBuildStrategy,
      k8sEnvironment: optionsK8sEnvironment
    } = options;
    const {
      buildStrategy: propsBuildStrategy,
      k8sEnvironment: propsK8sEnvironment
    } = props;

    const buildStrategy = optionsBuildStrategy || propsBuildStrategy;
    const k8sEnvironment = optionsK8sEnvironment || propsK8sEnvironment;

    let templateDirectory;

    if (buildStrategy === "jib-maven(for java)") {
      templateDirectory =
        k8sEnvironment === "minikube" ? "jib/pipeline" : "jib/triggers";
    } else if (buildStrategy === "Dockerfile") {
      templateDirectory =
        k8sEnvironment === "minikube" ? "kaniko/pipeline" : "kaniko/triggers";
    } else {
      this.log("Unsupported build strategy. No files generated.");
      return;
    }

    const templatePaths = [
      { src: templateDirectory, dest: "files/pipeline-yml-files" },
      { src: "README.md", dest: "files/README.md" },
      { src: "pipeline-script.sh", dest: "files/pipeline-script.sh" }
    ];

    templatePaths.forEach(({ src, dest }) => {
      this.fs.copyTpl(this.templatePath(src), this.destinationPath(dest), {
        namespaceName,
        pipelineName,
        dockerConfig,
        repoURL,
        repoType,
        branch,
        imageRepositoryURL,
        deployKey,
        sshConfig,
        buildStrategy,
        PathToPomFile,
        k8sEnvironment,
        PathtoContext,
        DockerfilePath,
        PathtoDockerfile
      });
    });
  }

  _fileHelper(fileList, opts) {
    fileList.forEach(file => {
      this.fs.copyTpl(
        this.templatePath(file),
        this.destinationPath(`pipeline/${file}`),
        opts
      );
    });
  }

  install() {
    this.log("files Generation completed ...");
  }
};
