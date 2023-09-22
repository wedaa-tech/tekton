<h3><center>Clone, Build and push multiple Git Repositories using Tekton</h3>
<h4>Prerequisites:</h4>
<ol>
    <li>Have a kubernetes cluster running and install kubectl</li>
    <li>Install Tekton Pipelines using<br>
        kubectl apply –-filename \ 
        https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
    </li>
    <li>Install Tekton CLI, tkn on your machine <br>
        To install tkn, follow <a href="https://tekton.dev/docs/cli/">https://tekton.dev/docs/cli/</a>
    </li>
    <li>
        Install the git-clone and kaniko tasks <br>
        tkn hub install task git-clone <br>
        tkn hub install task kaniko <br>
        <ul type="disc">
            <li>git-clone is the task from tekton-hub for cloning the git repositories. <br>
            For more information, go through <a href="https://hub.tekton.dev/tekton/task/git-clone">https://hub.tekton.dev/tekton/task/git-clone</a> </li>
            <li>Kaniko is the task for building and pushing images to the required workspace. <br>
            For more information on kaniko, visit <a href="https://hub.tekton.dev/tekton/task/kaniko">https://hub.tekton.dev/tekton/task/kaniko</a> </li>
        </ul>
    </li>
</ol>
<h5>Create the Pipeline which contains the clone, build and push multiple git repositories</h5>
Start the kubernetes container(In this example, we're going to show on minikube).
```minikube start && minikube dashboard```
minikube dashboard is a ui representation of kubernetes.

<h4>Install Tekton Pipelines</h4>

```kubectl apply --filename \https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml```

Install git-clone from tekton hub using
```tkn hub install task git-clone```
The git-clone Task will clone a repo from the provided url into the output Workspace. By default the repo will be cloned into the root of your Workspace. You can clone into a subdirectory by setting this Task's subdirectory param. This Task also supports sparse checkouts. To perform a sparse checkout, pass a list of comma separated directory patterns to this Task's sparseCheckoutDirectories param.

Install kaniko from tekton hub using
```tkn hub install task kaniko```

This Task builds source into a container image using Google's kaniko tool.
kaniko doesn't depend on a Docker daemon and executes each command within a Dockerfile completely in userspace. This enables building container images in environments that can't easily or securely run a Docker daemon, such as a standard Kubernetes cluster.
kaniko is meant to be run as an image, gcr.io/kaniko-project/executor:v1.5.1. This makes it a perfect tool to be part of Tekton. This task can also be used with Tekton Chains to attest and sign the image.
The example pipeline will look like:<br>
```
//pipeline.yml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: clone-build-push
spec:
  description: | 
    This pipeline clones a git repo, builds a Docker image with Kaniko and
    pushes it to a registry
  params:
  - name: repo-url
    type: string
  - name: image-reference
    type: string
  - name: repo-url-1
    type: string
  - name: repo-url-2
    type: string
  - name: repo-url-3
    type: string

  workspaces:
  - name: shared-data
  - name: docker-credentials

  tasks:
  - name: fetch-source
    taskRef:
      name: git-clone
    workspaces:
    - name: output
      workspace: shared-data
    params:
    - name: url
      value: $(params.repo-url)
  - name: fetch-source-1
    runAfter: ["fetch-source"]
    taskRef:
      name: git-clone
    workspaces:
    - name: output
      workspace: shared-data
    params:
    - name: url
      value: $(params.repo-url-1)
    - name: subdirectory
      value: generator-tf-wdi
  - name: fetch-source-2
    runAfter: ["fetch-source","fetch-source-1"]
    taskRef:
      name: git-clone
    workspaces:
    - name: output
      workspace: shared-data
    params:
    - name: url
      value: $(params.repo-url-2)
    - name: subdirectory
      value: generator-jhipster
  - name: fetch-source-3
    runAfter: ["fetch-source","fetch-source-1","fetch-source-2"]
    taskRef:
      name: git-clone
    workspaces:
    - name: output
      workspace: shared-data
    params:
    - name: url
      value: $(params.repo-url-3)
    - name: subdirectory
      value: jhipster-blueprints
  - name: build-push
    runAfter: ["fetch-source","fetch-source-1","fetch-source-2","fetch-source-3"]
    taskRef:
      name: kaniko
    workspaces:
    - name: source
      workspace: shared-data
    - name: dockerconfig
      workspace: docker-credentials
    params:
    - name: IMAGE
      value: $(params.image-reference)
```
The pipelinerun code for the following will be:
```
//pipelinerun.yaml
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  generateName: clone-build-push-run-
spec:
  pipelineRef:
    name: clone-build-push

  podTemplate:
    securityContext:
      fsGroup: 65532
  workspaces:
  - name: shared-data
    volumeClaimTemplate:
      spec:
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: 1Gi
  - name: docker-credentials
    secret:
      secretName: docker-credentials

  params:
  - name: repo-url
    value: https://github.com/tic-oss/wda-server.git
  - name: image-reference
    value: lokeshkarakala/wda-server:latest
  - name: repo-url-1
    value: https://github.com/tic-oss/generator-tf-wdi.git
  - name: repo-url-2
    value: https://github.com/tic-oss/generator-jhipster.git
  - name: repo-url-3
    value: https://github.com/tic-oss/jhipster-blueprints.git
```
The following code is used to clone(using git-clone from Tekton Hub) and build-push( using Kaniko from Tekton Hub).

From the code, it is observed that the registry is used for creating an image for the repository.
This can be achieved by providing docker credentials in kubernetes secret. A file is named docker-credentials.yml and mention the config.json.
```
//docker-credentials.yml
apiVersion: v1
kind: Secret
metadata:
  name: docker-credentials
data:
  config.json: <provide_docker_config.json>
```
<br>config.json can be found using the following command ```nano .docker/config.json```
Remember kaniko is used only when there is a Dockerfile written in the application

```runAfter``` make sure that the task starts only after successful execution of the defined task.
In workspace, only one directory is created and allocated to the first repository created. Therefore subdirectories are added for the respective repositories.

To run the pipeline, docker-credentials is passed as a secret
```kubectl apply -f docker-credentials.yml```
  Now the docker-credentials is set. It uses the docker account to push the image into the registry

Now run the pipeline using ```kubectl apply -f pipeline.yml```
  This creates the pipeline

Now create pipelinerun using ```kubectl create -f pipelinerun.yaml```

Check the logs by ```tkn pipeline logs```