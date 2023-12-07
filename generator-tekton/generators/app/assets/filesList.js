const fileListjibpipeline = [
  "jib/pipeline/00-namespace.yml",
  "jib/pipeline/01-secrets.yml",
  "jib/pipeline/02-rbac.yml",
  "jib/pipeline/03-pipeline.yml",
  "jib/pipeline/04-pipelinerun.yml",
  "README.md",
  "pipeline-script.sh"
];

const fileListjibtriggers = [
  "jib/triggers/00-namespace.yml",
  "jib/triggers/01-secrets.yml",
  "jib/triggers/02-rbac.yml",
  "jib/triggers/03-pipeline.yml",
  "jib/triggers/04-event-listener.yml",
  "jib/triggers/05-triggers.yml",
  "README.md",
  "pipeline-script.sh"
];

const fileListkanikopipeline = [
  "kaniko/pipeline/00-namespace.yml",
  "kaniko/pipeline/01-secrets.yml",
  "kaniko/pipeline/02-rbac.yml",
  "kaniko/pipeline/03-pipeline.yml",
  "kaniko/pipeline/04-pipelinerun.yml",
  "README.md",
  "pipeline-script.sh"
];

const fileListkanikotriggers = [
  "kaniko/triggers/00-namespace.yml",
  "kaniko/triggers/01-secrets.yml",
  "kaniko/triggers/02-rbac.yml",
  "kaniko/triggers/03-pipeline.yml",
  "kaniko/triggers/04-event-listener.yml",
  "kaniko/triggers/05-triggers.yml",
  "README.md",
  "pipeline-script.sh"
];

module.exports = {
  fileListjibpipeline,
  fileListjibtriggers,
  fileListkanikopipeline,
  fileListkanikotriggers
};
