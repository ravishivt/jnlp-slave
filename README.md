# Custom jnlp-slave for ASE CI/CD.
Jenkins worker for use with Jenkins Kubernetes plugin

Currently contains the following:
   * kubectl
   * docker
   * helm
   * python and python build dependencies
   * nodejs + yarn

To push a new image version:

1. Commit your changes so the image pushed to the docker repo will have a unique tag.
2. `docker login`
3. `make all`