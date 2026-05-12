# 🐧 Complete Step-by-Step Production Linux Setup Guide (Ubuntu 24.04 LTS)

This reference guide outlines the exhaustive, battle-tested terminal instructions to provision fresh **Ubuntu 24.04 LTS** instances from scratch into secure **Master CI/CD Orchestration Nodes** and isolated **Worker Nodes**.

---

## 🏗️ Phase 1: Master Node Complete Provisioning

Run these commands directly inside your Master server SSH terminal.

### 1. Update System Repositories & Base Dependencies
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git software-properties-common apt-transport-https ca-certificates gnupg lsb-release
```

### 2. Install High-Performance Java 21 (JDK 21)
Jenkins and our microservice build stages require Java 21 execution runtimes.
```bash
# Install native OpenJDK 21 packages available in Ubuntu 24.04 repositories
sudo apt install -y openjdk-21-jdk

# Verify installation paths and active version metadata
java -version
```

### 3. Install Apache Maven
Used by Jenkins pipeline build triggers to resolve Spring Boot project artifacts.
```bash
sudo apt install -y maven

# Validate build environment variables and path bindings
mvn -version
```

### 4. Install Official Docker Engine
Installs pristine Docker binaries preventing reliance on outdated host packagers.
```bash
# Add Docker official GPG cryptographic key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Setup stable apt tracking repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update index files and install execution engines
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable daemon persistent startups
sudo systemctl enable --now docker
```

### 5. Install Official Jenkins CI Server
```bash
# Download official repository GPG authentication keys
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# Append stable release package indices
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Synchronize index packages and instantiate Jenkins service files
sudo apt update
sudo apt install -y jenkins

# Enable auto-start mechanics and start controller
sudo systemctl enable --now jenkins

# Display initial administrator unlock password token required by web wizards
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### 6. Install Ansible Automation Controller
```bash
# Ensure standard repository software packages track PPA extensions
sudo apt-add-repository --yes --update ppa:ansible/ansible

# Install pristine controller execution tools
sudo apt install -y ansible

# Verify controller engine operational statuses
ansible --version
```

### 7. Grant System Executions & Container Permissions
To allow the Jenkins service account to execute Docker build instructions dynamically without forcing interactive `sudo` passwords:
```bash
# Append jenkins user scope into host docker execution group
sudo usermod -aG docker jenkins

# Restart service agents reflecting updated execution capabilities
sudo systemctl restart jenkins
```

---

## 🔒 Phase 2: Secure Communication & SSH Key Authentication

Jenkins master orchestrates actions by calling Ansible locally, which communicates securely with the Worker Node over SSH. We configure passwordless SSH authentication.

### 1. Generate Master Node Keys
Execute as the Jenkins system user to establish identity scopes.
```bash
# Switch execution context into jenkins interactive terminal
sudo su - jenkins

# Generate RSA cryptographic pairs without empty passphrase interactive interrupts
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# Output generated public key strings
cat ~/.ssh/id_rsa.pub
```

### 2. Trust Master Keys on Target Worker Node
Log into your target Worker Node instance, and append the master's public string.
```bash
# Ensure local SSH directories operate correct isolation limits
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Open authorized keys list and append copied public key contents
nano ~/.ssh/authorized_keys

# Set stringent read-only permission arrays preventing file tampering
chmod 600 ~/.ssh/authorized_keys
```

### 3. Verify Seamless SSH Connectivity
Return to Master node console operating as the `jenkins` user account:
```bash
# Initiate handshake bypassing standard prompts
ssh -o StrictHostKeyChecking=no ubuntu@<worker-node-ip>

# Exit remote session once prompt returns success validation
exit
```

---

## 🌐 Phase 3: Worker Node Minimal Production Config

Target execution servers only require lightweight execution wrappers.

### 1. Install Docker Engine
Follow Master Node Docker instructions (Step 4 above) directly on your clean Worker server.

### 2. Configure Custom Docker Networks
The database and microservice layers communicate internally using internal Docker DNS to prevent public exposure.
```bash
# Provision application isolated bridge overlay
sudo docker network create devops_network

# Audit active overlay states
sudo docker network ls
```

---
*Your server infrastructure is now 100% compliant with professional enterprise DevOps CI/CD architectures.*
