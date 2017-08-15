# Custom jnlp-slave for ASE CI/CD.
Jenkins worker for use with Jenkins Kubernetes plugin

Currently contains the following:
   * kubectl
   * docker
   * helm
   * python and python build dependencies
   * nodejs + yarn

To push a new image version, run:

```
docker login
make all
```