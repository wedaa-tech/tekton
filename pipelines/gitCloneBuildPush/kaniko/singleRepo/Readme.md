###<center>Clone, Build and push a Git Repository using Tekton</center>
#####Prerequisites:
<ol>
    <li>Have a kubernetes cluster running and install kubectl</li>
    <li>Install Tekton Pipelines using <br>
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
        git-clone is the task from tekton-hub for cloning the git repositories. <br>
        For more information, go through <a href="https://hub.tekton.dev/tekton/task/git-clone">https://hub.tekton.dev/tekton/task/git-clone</a>
        Kaniko is the task for building and pushing images to the required workspace. <br>
        For more information on kaniko, visit <a href="https://hub.tekton.dev/tekton/task/kaniko">https://hub.tekton.dev/tekton/task/kaniko</a>
    </li>
</ol>
