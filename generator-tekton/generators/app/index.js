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
      const options = JSON.parse(JSON.stringify(fileContents));
      this.options = options;
    }
  }

  writing() {
    const copyOpts = {
      globOptions: {
        ignore: []
      }
    };

    const options = JSON.parse(this.options);
    options.cloudProvider !== undefined && options.cloudProvider !== "minikube";

    this.log(options);

    try {
      switch (options.cloudProvider) {
        case "aws":
          this.log("AWS Generator");
          this._fileHelper(fileListtekton, options, copyOpts);
          break;
        case "azure":
          this.log("Azure Generator");
          this._fileHelper(fileListtekton, options, copyOpts);
          break;
        case "minikube":
          this.log("minikube Generator");
          this._fileHelper(fileListtekton, options, copyOpts);
          break;
        default:
          console.log(
            `Sorry, ${options.cloudProvider} cloud is not supported.`
          );
      }
    } catch (error) {
      this.log(error);
    }
  }

  _fileHelper(fileList, opts, copyOpts) {
    fileList.forEach(file => {
      this.fs.copyTpl(
        this.templatePath(file),
        this.destinationPath(`tekton-cicd/${file}`),
        opts,
        copyOpts
      );
    });
  }

  install() {
    this.log("Tekton files Generation completed...");
  }
};
