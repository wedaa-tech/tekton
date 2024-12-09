const Generator = require("yeoman-generator");
const path = require("path");
const fs = require("fs");
const { fileListtekton } = require("./assets/filesList");

module.exports = class extends Generator {
  constructor(args, opts) {
    super(args, opts);

    if (opts.file) {
      const filePath = path.resolve(opts.file);
      const fileContents = fs.readFileSync(filePath, "utf8");
      const options = JSON.parse(fileContents);
      this.options = options;
    }
  }

  writing() {
    const options = this.options;

    this.log("Options being used:", options);

    try {
      // Generate shared directories like "account"
      this._generateSharedDirectories(options);

      // Generate files for each component
      options.componentName.forEach(component => {
        this._generateComponentSpecificFiles(component, options);
      });

      this._generateNonComponentSpecificTasks(options);
      // this._generateSharedFiles(fileList, options);

      // Generate other shared files
    } catch (error) {
      this.log("Error during file generation:", error);
    }
  }

  _generateNonComponentSpecificTasks(options) {
    const nonComponentTasks = [
      "task/send-status-to-github-task.yml",
      "task/github-clone-repo-task.yml",
      "task/get-commit-sha-task.yml",
      "task/docker-buid-push-task.yml",
      "task/deploy-task.yml"
    ];

    nonComponentTasks.forEach(taskFile => {
      this.fs.copyTpl(
        this.templatePath(taskFile),
        this.destinationPath(`tekton-cicd/${taskFile}`),
        options
      );
    });
  }

  _generateSharedDirectories(options) {
    const cloudProvider = options.cloudProvider;
  
    // Check if cloud provider is minikube
    if (cloudProvider === "minikube") {
      // Only copy the files excluding pvc.yml and pv.yml
      const filesToCopy = fs.readdirSync(this.templatePath("account/")).filter(file => {
        // Exclude the unwanted files when cloud provider is minikube
        return !(file === "04-pvc.yml" || file === "05-pv.yml" || file === "03-storageclass.yml");
      });
  
      // Copy filtered files
      filesToCopy.forEach(file => {
        this.fs.copyTpl(
          this.templatePath(`account/${file}`),
          this.destinationPath(`tekton-cicd/account/${file}`),
          options
        );
      });
    } else {
      // For other cloud providers, copy all files
      this.fs.copyTpl(
        this.templatePath("account/"),
        this.destinationPath("tekton-cicd/account/"),
        options
      );
    }
  }
  

  _generateComponentSpecificFiles(component, options) {
    const componentOptions = { ...options, componentName: component };

    this.fs.copyTpl(
      this.templatePath("pipelines/push-pipeline.yml"),
      this.destinationPath(
        `tekton-cicd/pipelines/${component}-push-pipeline.yml`
      ),
      componentOptions
    );

    this.fs.copyTpl(
      this.templatePath("pipelines/pr-test-cases-pipeline.yml"),
      this.destinationPath(
        `tekton-cicd/pipelines/${component}-pr-test-cases-pipeline.yml`
      ),
      componentOptions
    );

    this.fs.copyTpl(
      this.templatePath("pipelineruns/push-pipelinerun.yml"),
      this.destinationPath(
        `tekton-cicd/pipelineruns/${component}-push-pipelinerun.yml`
      ),
      componentOptions
    );

    this.fs.copyTpl(
      this.templatePath("pipelineruns/pr-test-cases-pipelinerun.yml"),
      this.destinationPath(
        `tekton-cicd/pipelineruns/${component}-pr-test-cases-pipelinerun.yml`
      ),
      componentOptions
    );

    this.fs.copyTpl(
      this.templatePath("triggers/triggers.yml"),
      this.destinationPath(`tekton-cicd/triggers/${component}-triggers.yml`),
      componentOptions
    );

    this.fs.copyTpl(
      this.templatePath("task/test-cases-task.yml"),
      this.destinationPath(`tekton-cicd/task/${component}-test-cases-task.yml`),
      componentOptions
    );

    this.fs.copyTpl(
      this.templatePath("task/test-cases-task.yml"),
      this.destinationPath(`tekton-cicd/task/${component}-test-cases-task.yml`),
      componentOptions
    );
  }

  install() {
    this.log("Tekton files generation completed...");
  }
};
