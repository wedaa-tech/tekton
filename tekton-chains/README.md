<h2>Tekton Chains</h2>
<p>Given the increasing complexity of the CI/CD space, with projects that often have dozens or even hundreds of dependencies, the supply chain has become a common vector of attacks. Tekton Chains is a security-oriented part of the Tekton portfolio to help you mitigate security risks.

Tekton Chains is a tool to generate, store, and sign provenance for artifacts built with Tekton Pipelines. Provenance is metadata containing verifiable information about software artifacts, describing where, when and how something is built.</p>

<h3>How does Tekton Chains work?</h3>
<p>Tekton Chains works by deploying a controller that runs in the background and monitors TaskRuns. While Tekton Pipelines executes your Tasks, Tekton Chains watches the operation, once the operation is successfully completed, the Chains controller generates the provenance for the artifacts produced.

The provenance records the inputs of your Tasks: source repositories, branches, other artifacts; and the outputs: container images, packages, etc. This information is recorded as in-toto metadata and signed. You can store the keys to sign the provenance in a Kubernetes secret or by using a supported key management system: GCP, AWS, Azure, or Vault. You can then upload the provenance to a specified location.</p>
<img src="/images/Tekton-chain.png">

<h4>Provenance:</h4><p>Provenance is the ability to track the origin, creation, and changes to software artifacts as they are built and deployed using Tekton pipelines. This information can be used to ensure the authenticity and integrity of software artifacts, debug and trace problems, and comply with regulations.</p>
<h4>Artifacts</h4><p>Artifacts are the outputs of Tasks and PipelineRuns. Artifacts can be anything from a container image to a text file. Artifacts include information about the inputs that were used to create the artifact, as well as the steps that were taken to create the artifact.
</p>
<ul>
<li>Artifacts are the outputs of Tasks and PipelineRuns.
<li>Provenance is the history of an artifact, including its origin, creation, ownership, and changes over time.
<li>Tekton provides a number of features and tools that can be used to manage and track the provenance of artifacts.
</ul>

<h4>Cosign</h4>Cosign is a tool for container signing, verification, and storage in an OCI registry. It can be used to sign any type of artifact in a registry, including container images, Helm charts, Tekton pipelines, and more.

<h4>jq</h4>jq is a lightweight and flexible command-line JSON processor. It allows users to display a JSON file using standard formatting, or to retrieve certain records or attribute-value pairs from it. It features a powerful set of filters and functions that can manipulate, analyze and transform JSON data.<br><br>
<ul>
<li>Cosign and jq are two tools that can be used to improve the security of Tekton supply chains.
<li>Cosign and jq can be used together to improve the security of Tekton supply chains in a number of ways, including:
<ul>
<li><b>Signing Tekton artifacts:</b> Cosign can be used to sign Tekton artifacts, such as TaskRuns and PipelineRuns. This can help to ensure the authenticity and integrity of the artifacts.
<li><b>Verifying Tekton artifacts:</b> Cosign can be used to verify the signatures of Tekton artifacts. This can help to ensure that the artifacts have not been tampered with.
<li><b>Storing provenance attestations:</b> Cosign can be used to store provenance attestations for Tekton artifacts. Provenance attestations are signed statements that attest to the authenticity and integrity of an artifact.
<li><b>Analyzing provenance data:</b> Jq can be used to analyze provenance data. This can help to identify and fix any security vulnerabilities in the Tekton supply chain.