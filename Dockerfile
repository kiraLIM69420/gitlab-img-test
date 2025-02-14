# Start with Alpine as base image
FROM alpine

# ARG for versions
ARG TERRAFORM_VERSION=1.9.1
ARG TERRAGRUNT_VERSION=0.73.0
ARG HELM_VERSION=3.17.0
ARG DOCKER_VERSION=24.0.7

ENV PATH="/usr/local/bin:${PATH}"

# Use HTTP repositories for package installation
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.21/main" > /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/v3.21/community" >> /etc/apk/repositories

# Update CA certificates and install base packages
RUN apk update \
    && apk add --no-cache ca-certificates \
    && update-ca-certificates \
    && apk add --no-cache \
    bash \
    curl \
    git \
    gnupg \
    iputils \
    jq \
    openssh-client \
    python3 \
    py3-pip \
    tar \
    unzip \
    wget \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    python3-dev \          
    linux-headers \
    mandoc            

# Install Terraform
RUN wget --no-check-certificate https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install Terragrunt
RUN wget --no-check-certificate https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 && \
    mv terragrunt_linux_amd64 /usr/local/bin/terragrunt && \
    chmod +x /usr/local/bin/terragrunt

# Install Helm
RUN wget --no-check-certificate https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    tar -zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    rm -rf linux-amd64 helm-v${HELM_VERSION}-linux-amd64.tar.gz

# Install AWS CLI
RUN apk add --no-cache aws-cli 

# Install Azeure-cli
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir azure-cli 

# Install Docker CLI
RUN wget --no-check-certificate https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz && \
    tar xzvf docker-${DOCKER_VERSION}.tgz && \
    mv docker/docker /usr/local/bin/ && \
    rm -rf docker docker-${DOCKER_VERSION}.tgz

# Verify installations
RUN terraform --version && \
    terragrunt --version && \
    helm version && \
    aws --version && \
    az --version && \
    docker --version
