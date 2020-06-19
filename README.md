## DOCKER IMAGE THAT CONTAINS JENKINS JOB BUILDER (JJB)

- This creates a docker image from specific jenkins version (2.235.1 - LTS)
- This will install ansible to do a precheck on yml files base on JJB
- This will install jenkins job builder to generate the appropiate jobs
- This will install Maven version 3.6.3
- This will install Docker engine

Commands:
* To create the image: `docker build -t <image_tag> .`

* To start the container: `docker run -p 8110:8080 -v $(pwd):/tmp <image_tag>`
    
    The above command will mounts your local (current directory) files into the /tmp folder inside the container. Any change in your localhost will refelect in the container (helpful when updating yml file jobs)

Login using the following credentials:
* Username: `jenkins`
* Passoword: `jenkins`

Execution commands:
* Test the jobs: `jenkins-jobs test -r globals:jobs >/dev/null`
* Update jobs: `jenkins-jobs update -r globals:jobs/idam/am`
* Delete all job: `jenkins-jobs delete-all`