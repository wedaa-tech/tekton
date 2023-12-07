<h3>Tekton Pipeline</h3>
<h3>Prerequisites:</h3>
<ol> 
<h4>Have a kubernetes cluster up and running and install kubectl</h4>
</ol>
<h4>To run the files through a script,</h4>
<ol>
  To run the files through a script, use the
  
  ```pipeline-script.sh```
   file.Executing this script will install the Tekton CLI, Tekton Pipelines, Tekton DashBoard, the required task, and yml files needed to run the pipeline.
</ol> 
<h4>To run the files manually, first install few prerequisites</h4>
<h3>Prerequisites:</h3>
<ol>

   <li>Install Tekton Pipelines using</li>
     kubectl apply --filename \ 
        https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
   <li>Install Tekton Triggers using</li>
     kubectl apply --filename \
        https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
     kubectl apply --filename \
        https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
   <li>Install tekton Dashboard</li> 
     kubectl apply --filename \
        https://storage.googleapis.com/tekton-releases/dashboard/latest/release-full.yaml
   <li>Install Tekton CLI, tkn on your machine</h3>
To install tkn, follow <a href="https://tekton.dev/docs/cli/">https://tekton.dev/docs/cli/ </a> </li>
</ol>
<h3>Create the namespace :</h3><br>

```kubectl apply -f pipeline-yml-files/00-namespace.yml```


<h3>Install required tasks from Tekton Hub:</h3>

<br>install git clone task using<br>

```kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.9/git-clone.yaml -n <namespace name>```
or
```tkn hub install task git-clone -n <namespace name>```

<br>For more information, go through https://hub.tekton.dev/tekton/task/git-clone</br>

<%_ if (buildStrategy == "Dockerfile") { _%><br>
install kaniko task using<br>

```kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/kaniko/0.6/kaniko.yaml -n <namespace name>```
or
```tkn hub install task kaniko -n <namespace name>```



For more information on kaniko, visit https://hub.tekton.dev/tekton/task/kaniko</br>
<%_ } _%>

<%_ if (buildStrategy == "jib-maven(for java)") { _%><br>

install jib-maven task using<br>

```kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/jib-maven/0.5/jib-maven.yaml -n <namespace name> ```
or
```tkn hub install task jib-maven -n <namespace name> ```

For more information on kaniko, visit https://hub.tekton.dev/tekton/task/jib-maven</br>
<%_ } _%>


<h3>Run the yml files needed to run the pipeline.</h3>



<li>Create the secret for ssh key and docker registry using the following command:</li>

     kubectl apply -f pipeline-yml-files/01-secrets.yml -n <namespace name>
 
   
<li>Create the admin user, role, and rolebinding using the following command:</li>

     kubectl apply -f pipeline-yml-files/02-rbac.yml -n <namespace name> 
   
<li>create  the pipeline using the following command:</li>

    kubectl apply -f pipeline-yml-files/03-pipeline.yml -n <namespace name> 


<%_ if (k8sEnvironment == "minikube") { _%><br>
<li>Create the pipelinerun using the following command:</li>

     kubectl create -f pipeline-yml-files/04-pipelinerun.yml -n <namespace name> 
<%_ } else { _%> <br>
<li>Create the eventlistener using the following command:</li>

     kubectl apply -f pipeline-yml-files/04-event-listener.yml -n <namespace name>

And eventlistener will run on port 8080 and 9000

<li>create the  Triggers using the following command:</li>

     kubectl apply -f pipeline-yml-files/05-triggers.yml -n <namespace name>

<%_ } _%>

<h4>To activate triggers, </h4>
<ul>
     <li>Run the command
      " kubectl get svc -n (namespace name) " 
    to obtain the External IP and port configure this in Git hub Web hooks (or) Use a Domain  name.</li>
    
</ul>

<h5>Access Tekton Dashboard</h5>
The Tekton Dashboard is not exposed outside the cluster by default, but we can access it by port-forwarding to the tekton-dashboard Service on port 9097
    
     kubectl port-forward -n tekton-pipelines service/tekton-dashboard 9097:9097
     
You can now open the Dashboard in your browser at <a href="http://localhost:9097">http://localhost:9097</a>
</ul><br>

<h3>For more information on Tekton, visit <a href="https://tekton.dev/docs/">https://tekton.dev/docs/</a></h3>
<h3>For more information on Tekton Hub, visit <a href="https://hub.tekton.dev/">https://hub.tekton.dev/</a>