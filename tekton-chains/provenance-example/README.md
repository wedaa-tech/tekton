<h3>Provenance</h3>
<h4>Prerequisites:</h4>
<ol>
    <li>Have a kubernetes cluster running and install kubectl</li>
    <li>Install Tekton Pipelines using <br>
        kubectl apply --filename \https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
    </li>
    <li>Install jq from <a herf="https://jqlang.github.io/jq/download/">https://jqlang.github.io/jq/download/
    </a></li>
    <li>Install cosign from <a herf="https://jqlang.github.io/jq/download/">https://jqlang.github.io/jq/download/</a></li>
    <li>Install Tekton CLI, tkn on your machine <br>
        To install tkn, follow <a href="https://docs.sigstore.dev/cosign/installation/">https://docs.sigstore.dev/cosign/installation/</a>
    </li>
    <li>
        Install the git-clone and kaniko tasks <br>
        tkn hub install task git-clone <br>
        tkn hub install task kaniko <br>
    </li>
</ol>
<h3>Steps:</h3><ol>
<li>Start the kubernetes container(In this example, we're going to show on minikube).<br>
```minikube start && minikube dashboard``` <br>
minikube dashboard is a ui representation of kubernetes.</li>
<li>Install Tekton Chains:<br>
```kubectl apply --filename \https://storage.googleapis.com/tekton-releases/chains/latest/release.yaml```
<br>Monitor the installation using ```kubectl get po -n tekton-chains -w```
</li>
<li>Configure Tekton Chains to store the provenance metadata locally:<br>
```kubectl patch configmap chains-config -n tekton-chains \-p='{"data":{"artifacts.oci.storage": "", "artifacts.taskrun.format":"in-toto", "artifacts.taskrun.storage": "tekton"}}'```</li>
<li>Generate a key pair to sign the artifact provenance: <br>
```cosign generate-key-pair k8s://tekton-chains/signing-secrets```
</li>
<li>Run the pipeline <br>
To run the pipeline, docker-credentials is passed as a secret
```kubectl apply -f docker-credentials.yml```
  Now the docker-credentials is set. It uses the docker account to push the image into the registry

Now run the pipeline using ```kubectl apply -f pipeline.yml```
  This creates the pipeline

Now create pipelinerun using ```kubectl create -f pipelinerun.yaml```

Check the logs by ```tkn pipeline logs``` </li>
</ol>

<h3>Retrieve and verify the artifact provenance </h3>
Tekton Chains silently monitored the execution of the PipelineRun. It recorded and signed the provenance metadata, information about the container that the PipelineRun built and pushed.

<ol>
<li>Get the PipelineRun UID: <br>
```export PR_UID=$(tkn pr describe --last -o  jsonpath='{.metadata.uid}')```
</li>
<li>Fetch the metadata and store it in a JSON file: <br>
```tkn pr describe --last \-o jsonpath="{.metadata.annotations.chains\.tekton\.dev/signature-pipelinerun-$PR_UID}" \
| base64 -d > metadata.json```
</li>
<li>View the provenance: <br>
```cat metadata.json | jq -r '.payload' | base64 -d | jq .```
</li>
<li>To verify that the metadata hasn’t been tampered with, check the signature with cosing:<br>
```cosign verify-blob-attestation --insecure-ignore-tlog \
--key k8s://tekton-chains/signing-secrets --signature metadata.json \
--type slsaprovenance --check-claims=false /dev/null
```
</li></ol>
A json file is displayed which contains all the inputs from the pipeline