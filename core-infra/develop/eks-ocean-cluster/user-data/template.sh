#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh ${cluster_name}

set -ex
exec > >(tee /var/log/userdata.log|logger -t userdata ) 2>&1

echo ========== os packages ==========
yum -q -y install aws-cli bash-completion bc htop iftop jq lsof sysstat unzip
which amazon-ssm-agent || yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

echo ========== kubectl ==========
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
which kubectl
kubectl version --short --client
aws eks update-kubeconfig --name ${cluster_name} --region eu-west-1
echo 'export KUBECONFIG=/root/.kube/config' >> ~/.bashrc

echo ========== cheatsheet autocompletion ==========
echo 'source <(kubectl completion bash)' >> ~/.bashrc
echo 'alias k=kubectl' >> ~/.bashrc
echo 'complete -F __start_kubectl k' >> ~/.bashrc

echo ========== creating role assumption script ==========
cat > /home/assume-eks-programmatic-role.sh <<- "EOF"
#!/bin/bash
CREDS=$(aws sts assume-role --role-arn ${role_arn_to_assume} --role-session-name "ssm-$(date +%s)")
KEYID=`echo $CREDS | jq -r '.Credentials.AccessKeyId'`
SECRETKEY=`echo $CREDS | jq -r '.Credentials.SecretAccessKey'`
TOKEN=`echo $CREDS | jq -r '.Credentials.SessionToken'`
echo "Setting following temporary AWS credentials"
echo "KEYID = " $KEYID
echo "SECRETKEY = " $SECRETKEY
echo "TOKEN = " $TOKEN
unset AWS_PROFILE
export AWS_ACCESS_KEY_ID=$KEYID
export AWS_SECRET_ACCESS_KEY=$SECRETKEY
export AWS_SESSION_TOKEN=$TOKEN
aws sts get-caller-identity
EOF
chmod a+x /home/assume-eks-programmatic-role.sh

echo ========== checkup ==========
pwd
ls -alth
cat /var/log/userdata.log
