const fileListtekton = [
  "account/00-namespace.yml",
  "account/01-secrets.yml",
  "account/02-rbac.yml",
  "account/03-storageclass.yml",
  "account/04-pvc.yml",
  "account/05-pv.yml",
  "account/06-event-listener.yml",
  "task/test-cases-task.yml",
  "task/send-status-to-github-task.yml",
  "task/github-clone-repo-task.yml",
  "task/get-commit-sha-task.yml",
  "task/docker-buid-push-task.yml",
  "task/deploy-task.yml",
  "pipelines/push-pipeline.yml",
  "pipelines/pr-test-cases-pipeline.yml",
  "pipelineruns/push-pipelinerun.yml",
  "pipelineruns/pr-test-cases-pipelinerun.yml",
  "triggers/triggers.yml",
  "README.md",
  "pipeline-script.sh"
];

module.exports = {
  fileListtekton
};
