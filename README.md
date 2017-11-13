Jenkins CI with Docker Support
==============================
Docker image of JenkinsCI server 

Quick Start
-----------

```bash
# Create a volume for the Jenkins files
docker volume create jenkins_home
# Expose the HTTP, SSH, and JNLP ports
# Mount the jenkins_home volume and the Docker unix socket
docker run --detach --name jenkins --network devnet --restart=unless-stopped \
  --expose 2022 -p 2022:2022 -p 50000:50000 \
  --mount type=volume,source=jenkins_home,target=/var/jenkins_home \
  --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
  docker.vpn.bronnimann.com/bronnimann/jenkins-docker-ci:latest
```

Building
---------

```bash
docker build -t bronnimann/jenkins-docker-ci:latest .
docker tag bronnimann/jenkins-docker-ci \
  docker.vpn.bronnimann.com/bronnimann/jenkins-docker-ci:latest
docker push docker.vpn.bronnimann.com/bronnimann/jenkins-docker-ci:latest
```