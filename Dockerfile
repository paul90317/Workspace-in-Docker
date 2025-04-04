FROM ubuntu:latest AS build

# install docker cli
RUN apt update && apt install -y apt-transport-https ca-certificates curl software-properties-common
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt update && apt install -y docker-ce-cli

# install docker compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

# install kind
RUN curl -L -O https://go.dev/dl/go1.21.1.linux-amd64.tar.gz && \
    tar -C / -xzf go1.21.1.linux-amd64.tar.gz
RUN /go/bin/go install sigs.k8s.io/kind@v0.26.0

# install kubectl
RUN curl -LO "https://dl.k8s.io/release/v1.27.3/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Final Stage
FROM ubuntu:latest

# Copy necessary files from the build stage
COPY --from=build /usr/local/bin/ /usr/bin
COPY --from=build /root/go/bin /usr/bin
COPY --from=build /usr/bin/docker /usr/bin

# install authk
COPY authk.sh /usr/bin/authk
COPY user.sh /usr/bin/user
RUN chmod +x /usr/bin/authk /usr/bin/user

# install sshd
RUN apt update && \
    apt-get install -y openssh-server sudo && \
    mkdir /var/run/sshd
RUN echo "PermitRootLogin prohibit-password" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
RUN mkdir -p ~/.ssh && \
    chmod 700 ~/.ssh

EXPOSE 22

# create workspace volume
VOLUME [ "/workspace" ]

ENTRYPOINT ["/usr/sbin/sshd", "-D"]