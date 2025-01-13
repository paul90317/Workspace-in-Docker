# Workspace in Docker
sets up a virtual workspace with Docker-in-Docker (DinD), SSH access, Docker Compose, Kind, and kubectl. This setup is useful for running and managing containers within a container, especially in CI/CD pipelines or as a development environment.

## build and run
* build local
    ```bash
    docker build -t wind .
    docker run -d -p 22:22 -v workspace:/workspace --name workspace wind
    ```
* pull from remote
    ```bash
    docker run -d -p 22:22 -v workspace:/workspace --name workspace paul90317/wind:latest
    ```
* add key to login
    ```bash
    # add new public key to authorized_keys
    docker exec workspace authk add <you public key>

    # list all added keys
    docker exec workspace authk ls
    ```