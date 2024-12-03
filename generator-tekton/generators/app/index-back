const Generator = require("yeoman-generator");
const path = require("path");
const fs = require("fs");
const { fileListtekton } = require("./assets/filesList");

module.exports = class extends Generator {
  constructor(args, opts) {
    super(args, opts);

    // Load JSON file if passed as an option
    if (opts.file) {
      const filePath = path.resolve(opts.file);
      const fileContents = fs.readFileSync(filePath, "utf8");
      const options = JSON.parse(fileContents); // Ensure proper parsing of JSON
      this.options = options;
    }
  }

  writing() {
    const copyOpts = {
      globOptions: {
        ignore: []
      }
    };

    const options = this.options; // Use the options loaded from the file

    this.log("Options being used:", options); // Debug log to verify options

    try {
      // Generate shared directories like "account"
      this._generateSharedDirectories(options, copyOpts);

      // Generate files for each component
      options.componentName.forEach(component => {
        this._generateComponentSpecificFiles(component, options, copyOpts);
      });

      // Generate other shared files (if applicable)
      this._generateSharedFiles(fileListtekton, options, copyOpts);
    } catch (error) {
      this.log("Error during file generation:", error);
    }
  }

  _generateSharedDirectories(options, copyOpts) {
    // Generate shared "account" directory
    this.fs.copyTpl(
      this.templatePath("account/"),
      this.destinationPath("tekton-cicd/account/"),
      options, // Pass full options to templates
      copyOpts
    );
  }

  _generateComponentSpecificFiles(component, options, copyOpts) {
    const componentOptions = { ...options, componentName: component }; // Customize options for each component

    // Generate component-specific pipeline files
    this.fs.copyTpl(
      this.templatePath("pipelines/push-pipeline.yml"),
      this.destinationPath(
        `tekton-cicd/pipelines/${component}-push-pipeline.yml`
      ),
      componentOptions,
      copyOpts
    );

    // Generate component-specific pipelinerun files
    this.fs.copyTpl(
      this.templatePath("pipelineruns/push-pipelinerun.yml"),
      this.destinationPath(
        `tekton-cicd/pipelineruns/${component}-push-pipelinerun.yml`
      ),
      componentOptions,
      copyOpts
    );

    // Generate component-specific triggers files
    this.fs.copyTpl(
      this.templatePath("triggers/triggers.yml"),
      this.destinationPath(`tekton-cicd/triggers/${component}-triggers.yml`),
      componentOptions,
      copyOpts
    );

    // Generate component-specific test-cases-task files
    this.fs.copyTpl(
      this.templatePath("task/test-cases-task.yml"),
      this.destinationPath(`tekton-cicd/task/${component}-test-cases-task.yml`),
      componentOptions,
      copyOpts
    );
  }

  _generateSharedFiles(fileList, options, copyOpts) {
    fileList.forEach(file => {
      // Exclude files generated per component
      if (
        !file.startsWith("pipelines/") &&
        !file.startsWith("pipelineruns/") &&
        !file.startsWith("triggers/") &&
        !file.startsWith("task/test-cases-task.yml")
      ) {
        this.fs.copyTpl(
          this.templatePath(file),
          this.destinationPath(`tekton-cicd/${file}`),
          options,
          copyOpts
        );
      }
    });
  }

  install() {
    this.log("Tekton files generation completed...");
  }
};
