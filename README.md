<center> <h1>TEKTON</h1> </center>
Tekton is an open-source cloud native CI/CD (Continuous Integration and Continuous Delivery/Deployment) solution.
<br><br>
<b>Functionalities:</b>
<ul>
    <li>Cloud Native</li>
    <li>Continuous Delivery</li>
    <li>Kubernetes</li>
    <li>Tekton is a Kubernetes-native open-source framework for creating Continuous Delivery systems</li>
    <li>Standardization</li>
    <li>Built-in best practices</li>
    <li>Maximum flexibility</li><br>
</ul>
#####Tekton basic building blocks
<ul>
<li>Step = Container(basic part)</li>
<li>Task = pods(sequence of steps)</li>
<li>Pipeline(Sequence of Tasks)</li>
</ul>
<center><img src=/images/Pipeline.png></center>

#### <b>Tekton Triggers:</b>
You can use Tekton Triggers to modify the behavior of your CI/CD Pipelines depending on external events.
<ul>
<li>Trigger Binding(Custom resource that extracts relevant Information from event payload) </li>

<li>Trigger Template(Custom resource that provides blueprint for creating tekton resource such as tast run, pipeline etc) </li>

<li>EventListener(connects trigger binding with template) </li>
</ul>
<center><img src=/images/Trigger_template.png></center>

<b>Steps to follow:</b>
<ol>
    <li>
        Setup local kubernetes cluster
        <ul type="disc">
            <li>There are several tools to run a local Kubernetes cluster on your computer. </li>
            <li>The Tekton documentation often includes instructions for either minikube or kind.</li>
            <li>Follow the official documentation of minikube or kind to setup in local<br>
            <a href="https://minikube.sigs.k8s.io/docs/start">https://minikube.sigs.k8s.io/docs/start/</a><br>
            <a href="https://kind.sigs.k8s.io/docs/user/quick-start/">https://kind.sigs.k8s.io/docs/user/quick-start/</a>
        </ul>
    </li>
    <li>
        Install Tekton Pipelines
        <ul type="disc">
            <li>Install kubectl and a kubernetes cluster should be running with the version ≥ 1.24. </li>
            <li>For installing latest official release, <br>
            kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml</li>
            <li>For installing Nightly release, <br>
            kubectl apply --filename https://storage.googleapis.com/tekton-releases-nightly/pipeline/latest/release.yaml</li>
            <li>For installing specific release, <br>
            kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/previous/<version_number>/release.yaml</li>
            <li>For installing Untagged release, <br>
            kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.notags.yaml</li>
            <li>For Monitoring the Installation, <br>
            kubectl get pods --namespace tekton-pipelines --watch</li>
        </ul>
    </li>
    <li>
        Install and set up Tekton Triggers <br>
        Install Tekton pipelines and be in the same cluster.
        <ul type="disc">
            <li>For installing latest official release, <br>
            kubectl apply --filename \
            https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml <br>
            kubectl apply --filename \
            https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml</li>
            <li>For installing Nightly release, <br>
            kubectl apply --filename \
            https://storage.googleapis.com/tekton-releases-nightly/triggers/latest/release.yaml <br>
            kubectl apply --filename \
            https://storage.googleapis.com/tekton-releases-nightly/triggers/latest/interceptors.yaml</li>
            <li>For installing specific release, <br>
            kubectl apply --filename \
            https://storage.googleapis.com/tekton-releases/triggers/previous/VERSION_NUMBER/release.yaml <br>
            kubectl apply --filename \
            https://storage.googleapis.com/tekton-releases/triggers/previous/VERSION_NUMBER/interceptors.yaml</li>
            <li>For installing Untagged release, <br>
            kubectl apply --filename \
            https://storage.googleapis.com/tekton-releases/triggers/latest/release.notags.yaml <br>
            kubectl apply --filename \
            https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.notags.yaml</li>
            <li>For Monitoring the Installation, <br>
            kubectl get pods --namespace tekton-pipelines --watch</li>
        </ul>
    </li>
</ol>