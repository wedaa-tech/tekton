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

      // Generate other shared files
      this._generateSharedFiles(fileListtekton, options);
    } catch (error) {
      this.log("Error during file generation:", error);
    }
  }

  _generateSharedDirectories(options) {
    this.fs.copyTpl(
      this.templatePath("account/"),
      this.destinationPath("tekton-cicd/account/"),
      options
    );
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
      this.templatePath("pipelineruns/push-pipelinerun.yml"),
      this.destinationPath(
        `tekton-cicd/pipelineruns/${component}-push-pipelinerun.yml`
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
  }

  _generateSharedFiles(fileList, options) {
    const isMinikube = options.cloudProvider === "minikube";

    fileList.forEach(file => {
      if (
        isMinikube &&
        (file.includes("03-storageclass.yml") ||
          file.includes("04-pvc.yml") ||
          file.includes("05-pv.yml"))
      ) {
        this.log(`Skipping ${file} because cloud provider is Minikube`);
        return; // Skip these files
      }

      // Copy only non-skipped files
      this.fs.copyTpl(
        this.templatePath(file),
        this.destinationPath(`tekton-cicd/${file}`),
        options
      );
    });
  }

  install() {
    this.log("Tekton files generation completed...");
  }
};
