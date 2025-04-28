
# Deploying a Python Application Using AWS CodeDeploy

This README documents the process of creating and deploying a Python application using **AWS CodeDeploy**. The deployment process involves setting up an EC2 instance, configuring AWS CodeDeploy, and automating the deployment of the Python application.

---

## **Overview**

The deployment process includes:
1. Setting up an EC2 instance to host the Python application.
2. Creating an AWS CodeDeploy application and deployment group.
3. Configuring the Python application repository with CodeDeploy files.
4. Automating the deployment process using CodeDeploy.

---

## **Steps to Create and Deploy the Python Application**

### **1. Setting Up the EC2 Instance**
1. **Launch an EC2 Instance**:
   - Go to the **EC2 Console** and launch an instance.
   - Use an **Amazon Linux 2** or **Ubuntu** AMI.
   - Select an instance type (e.g., `t2.micro`).
   - Attach an IAM role with the following policies:
     - `AmazonEC2RoleforAWSCodeDeploy`
     - `AmazonS3FullAccess` (if needed for dependencies).

2. **Install the CodeDeploy Agent**:
   - SSH into the EC2 instance:
     ```bash
     ssh -i <your-key.pem> ec2-user@<instance-ip>
     ```
   - Install the CodeDeploy agent:
     ```bash
     sudo yum update -y
     sudo yum install ruby -y
     sudo yum install wget -y
     cd /home/ec2-user
     wget https://aws-codedeploy-<region>.s3.<region>.amazonaws.com/latest/install
     chmod +x ./install
     sudo ./install auto
     sudo service codedeploy-agent start
     ```

3. **Verify the CodeDeploy Agent**:
   - Check if the CodeDeploy agent is running:
     ```bash
     sudo service codedeploy-agent status
     ```

---

### **2. Creating the AWS CodeDeploy Application**
1. **Create a CodeDeploy Application**:
   - Go to the **AWS CodeDeploy Console**.
   - Click **Create application**.
   - Provide a name (e.g., `python-app-deployment`).
   - Select **EC2/On-Premises** as the compute platform.

2. **Create a Deployment Group**:
   - Select the application you just created.
   - Click **Create deployment group**.
   - Provide a name (e.g., `python-app-deployment-group`).
   - Select the service role (`AWSCodeDeployRole`).
   - Choose the EC2 instance or Auto Scaling Group.
   - Enable **Agent Auto Healing** if needed.

---

### **3. Configuring the Python Application Repository**
1. **Set Up a CodeCommit Repository**:
   - Go to the **AWS CodeCommit Console** and create a repository (e.g., `python-app-repo`).
   - Clone the repository locally:
     ```bash
     git clone https://git-codecommit.<region>.amazonaws.com/v1/repos/python-app-repo
     cd python-app-repo
     ```

2. **Add the Python Application**:
   - Copy your Python application files into the repository folder.
   - Add a `requirements.txt` file if your app has dependencies.
   - Add a `start.sh` script to start the application.

   Example `start.sh`:
   ```bash
   #!/bin/bash
   cd /home/ec2-user/python-app
   pip3 install -r requirements.txt
   python3 app.py
   ```
## **3. Add CodeDeploy Configuration:**
- Create an appspec.yml file in the repository root:
```yml
#appsec.yml
version: 0.0
os: linux
files:
  - source: /
    destination: /home/ec2-user/python-app
hooks:
  BeforeInstall:
    - location: scripts/install_dependencies.sh
      timeout: 300
      runas: root
  ApplicationStart:
    - location: scripts/start.sh
      timeout: 300
      runas: root
```

- create a script/install_dependemcies.sh
  ```bash
  #!/bin/bash
  yum update -y
  yum install python3 -y
  pip3 install -r /home/ec2-user/python-app/requirements.txt
  ```
### **4. Deploying the Application**
1. Create a Deployment:
 - Go to the AWS CodeDeploy Console.
 - Select the application and deployment group.
 - Click Create deployment.
 - Choose CodeCommit as the source.
 - Select the repository and branch (e.g., main).
 - Click Deploy.
2. Monitor the Deployment:
 - Check the deployment status in the CodeDeploy Console.
- If successful, the application will be deployed to the EC2 instance.
  
### ** Test the Application:**

 - ssh into the instance and verify if the application is running
   ```bash
   ps aux | grep python
   ```
