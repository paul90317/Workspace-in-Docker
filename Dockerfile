FROM ubuntu:latest

# create workspace volumn
VOLUME [ "/workspace" ]

# install docker cli
RUN apt update && apt install -y apt-transport-https ca-certificates curl software-properties-common
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt update && apt install -y docker-ce-cli
RUN echo 'export DOCKER_HOST=tcp://host.docker.internal:2375' >> ~/.bashrc

# install docker compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

# install sshd
RUN apt-get install -y openssh-server && \
    mkdir /var/run/sshd
RUN echo "PermitRootLogin prohibit-password" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
RUN mkdir -p ~/.ssh && \
    chmod 700 ~/.ssh

# install authk
COPY authk.sh /usr/local/bin/authk
RUN chmod +x /usr/local/bin/authk

# install kind
RUN curl -L -O https://go.dev/dl/go1.21.1.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go1.21.1.linux-amd64.tar.gz && \
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc && \
    echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
RUN PATH=$PATH:/usr/local/go/bin go install sigs.k8s.io/kind@v0.26.0

# install kubectl
RUN curl -LO "https://dl.k8s.io/release/v1.27.3/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

EXPOSE 22

WORKDIR /workspace

ENTRYPOINT ["/usr/sbin/sshd", "-D"]