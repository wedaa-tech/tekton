# generator-tekton 

Yeoman is a generic scaffolding system allowing the creation of any kind of app. It allows for rapidly getting started on new projects and streamlines the maintenance of existing projects.

Yeoman is language agnostic. It can generate projects in any language (Web, Java, Python, C#, etc.)

First, install [Yeoman](http://yeoman.io) using [npm](https://www.npmjs.com/) (we assume you have pre-installed [node.js](https://nodejs.org/)).

```bash
npm install -g yo
```

After cloning the repository, the generator needs to be linked with the system to activate.

Hence link the generator by going into the generator directory and run the following commands. 
```bash
npm i
npm link
```

The yeoman will be linked with the workspace and now generate your new tekton project by:

```bash
yo tekton
```

Now you'll get the prompts and generate the pipeline with the required configurations.
The prompts will be:

<ol>
    <li>Add the namespace name you want to run in your kubernetes cluster</li>
    <li>Enter the name of your pipeline</li>
    <li>Enter the git repository type: private or public
        <ul>
        <li>If the repository is private,<br>
        provide the repository ssh url and base 64 encoded ssh privateKey and ssh_config file</li>
        <li>If the repository is public,<br>
        provide the repository http url</li>
        </ul>
    </li>
    <li>Enter the name of the branch you want to work on</li>
    <li>Enter the build strategy: using Dockerfile or jib-maven
        <ul>
            <li>If your project has a Dockerfile, choose this option. Kaniko is the task used for building and pushing the docker-image. <br>
            Kaniko requires the path to the Dockerfile. If Dockerfile is present in root repository, select root else Directory if it is in separate directory. <br> Hence provide the folder in which Dockerfile is present inside the repository and Path to Dockerfile in the coming two promts
            </li>
            <li>If your project is java-maven and don't have Dockerfile, choose this option</li>
        </ul>
    </li>
    <li>Enter the base64 encoded docker login config-json.<br>Providing docker config.json is the simplest method to loging into any of the docker-registry. The config file can be of any registry suce as azure, aws github packages.<br> Ensure you are providing corect base64 encoded config.json and the account which have necessary permissions</li>
    <li>Provide the complete image repository url name. <br>Make sure you have given correct url as different registry uses different naming constraint.</li>
    <li>Select your cloud environment: azure/aws or minikube if you prefer local environment</li>
</ol>

Once all the promts are done, The tekton resource files will be generated according to the promts given.
Once the kubernetes environment is linked, run the yaml files or run the bash script pipeline-script.sh
<br>The pipeline will be defined with the tasks as per the user promts. If the user need to apply the files manually, he need to install the tektons crds such as tekton-pipelines, tekton-tasks and dashboard. If the user opts for cloud provider, he need to configure the triggers. What tasks to be installed and how to add triggers will be provided in the readme file generated with the project.