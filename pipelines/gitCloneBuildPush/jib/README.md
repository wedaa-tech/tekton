<h3><center>Clone, Build and push a Git Repository using jib-maven</center></h3>
Jib is an open-source Java containerization tool created by Google. It simplifies the process of building Docker containers for Java applications. Jib is particularly popular among Java developers because it streamlines the containerization workflow and integrates well with various build tools and environments.

Jib builds and pushes a image without Dockerfile configured in the application
<h4>Prerequisites:</h4>
<ol>
    <li>Have a kubernetes cluster running and install kubectl</li>
    <li>Install Tekton Pipelines using <br>
        kubectl apply --filename \https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
    </li>
    <li>Install Tekton CLI, tkn on your machine <br>
        To install tkn, follow <a href="https://tekton.dev/docs/cli/">https://tekton.dev/docs/cli/</a>
    </li>
    <li>
        Install the git-clone and kaniko tasks <br>
        tkn hub install task git-clone <br>
        tkn hub install task jib-maven <br>
        <ul type="disc">
            <li>git-clone is the task from tekton-hub for cloning the git repositories. <br>
            For more information, go through <a href="https://hub.tekton.dev/tekton/task/git-clone">https://hub.tekton.dev/tekton/task/git-clone</a> </li>
            <li>This Task builds Java/Kotlin/Groovy/Scala source into a container image using Google's Jib tool.<br>
            Jib works with Maven and Gradle projects. <br>
            For more information on kaniko, visit <a href="https://hub.tekton.dev/tekton/task/jib-maven">https://hub.tekton.dev/tekton/task/jib-maven</a> </li>
        </ul>
    </li>
</ol>
<h5>Create the Pipeline which contains the clone, build and push a git repository</h5>
Start the kubernetes container(In this example, we're going to show on minikube).
```minikube start && minikube dashboard```
minikube dashboard is a ui representation of kubernetes.

<h4>Install Tekton Pipelines</h4>

```kubectl apply --filename \https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml```

Install git-clone from tekton hub using
```tkn hub install task git-clone```
The git-clone Task will clone a repo from the provided url into the output Workspace. By default the repo will be cloned into the root of your Workspace. You can clone into a subdirectory by setting this Task's subdirectory param. This Task also supports sparse checkouts. To perform a sparse checkout, pass a list of comma separated directory patterns to this Task's sparseCheckoutDirectories param.

Install jib-maven from tekton hub using
```kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/jib-maven/0.5/raw```

Write the create a pipeline and add tasks
The example pipeline will look like:<br>
```
//pipeline.yml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: springboot
spec:
  description: | 
    This pipeline clones a git repo and builds a Spring Boot
  params:
  - name: repo-url
    type: string
  - name: image-reference
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
  - name: jib-maven
    taskRef:
      name: jib-maven
    runAfter: ["fetch-source"]
    workspaces:
    - name: source
      workspace: shared-data
    params:
    - name: IMAGE
      value: <docker-registry-name>/springapplication
    - name: DIRECTORY
      value: ./springapp
    - name: MAVEN_IMAGE
      value: lokeshkarakala/custom-dev-image
```
The pipelinerun code for the following will be:
```
//pipelinerun.yaml
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  generateName: springboot-run-
spec:
  serviceAccountName: build-bot
  pipelineRef:
    name: springboot

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
    value: https://github.com/lokesh-cmi/SpringApplication.git
  - name: image-reference
    value: <docker-registry-name>/springapplication:latest
```
The following code is used to clone(using git-clone from Tekton Hub) and build-push( using Kaniko from Tekton Hub).
<br>Remember kaniko is used only when there is a Dockerfile written in the application<br>
From the code, it is observed that the registry is used for creating an image for the repository.
This can be achieved by providing docker credentials in kubernetes secret. 
But Jib has a problem taking docker-credentials directly.
Hence we use a ServiceAccount and pass the secret directly taking from local user system
Hence we write a serviceaccount.yml 
```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: build-bot
secrets:
  - name: regcred
```
To run the pipeline, docker-credentials is passed as a secret through serviceAccount
First apply the secret using ```kubectl create secret generic regcred \--from-file=.dockerconfigjson=/home/lokeshkarakala/.docker/config.json \--type=kubernetes.io/dockerconfigjson```
Now apply the serviceAccount
```kubectl apply -f serviceaccount.yml```
  Now the docker-credentials is set. It uses the docker account to push the image into the registry

Now run the pipeline using ```kubectl apply -f pipeline.yml```
  This creates the pipeline

Now create pipelinerun using ```kubectl create -f pipelinerun.yaml```

Check the logs by ```tkn pipeline logs```

In jib, the maven version is not upto date,
Hence we created a new custom image which has latest ubuntu, jdk, maven and curl in the image ```lokeshkarakala/custom-dev-image```