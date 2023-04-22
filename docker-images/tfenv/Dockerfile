FROM amazonlinux

# #!/bin/bash
# set -x

### packages
# extra packages
RUN yum update -y && yum install -q -y shadow-utils python-pip python3-pip golang unzip
RUN yum install gnupg2 unzip --allowerasing -y
RUN useradd ec2-user

#amazon-linux-extras install docker python3
# install boto3 in userdata
RUN pip3 install boto3 && pip3 install --upgrade --user awscli
RUN which aws || true
RUN curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o '/home/ec2-user/awscliv2.zip'
RUN unzip /home/ec2-user/awscliv2.zip -d /home/ec2-user
RUN /home/ec2-user/aws/install

# Install tf version manager and tf versions
RUN git clone https://github.com/tfutils/tfenv.git /usr/local/share/tfenv
# to enable hash sum verification with gpg
RUN echo 'trust-tfenv: yes' > /usr/local/share/tfenv/use-gpgv
RUN ln -s /usr/local/share/tfenv/bin/* /usr/local/bin

# Install Terraform  
WORKDIR /home/ec2-user
COPY execute-tf.sh  /home/ec2-user/execute-tf.sh
RUN chmod a+x  /home/ec2-user/execute-tf.sh
RUN ls /usr/local/share/tfenv/
RUN chmod -R a+rwx /usr/local/share/tfenv/

# dir for plugins 
RUN mkdir -p /home/ec2-user/terraform-plugins/linux_amd64/ 

# terraform aws plugin
ENV plugin_name="terraform-provider-aws"
ENV plugin_version="2.36.0"
ENV plugin_url="https://releases.hashicorp.com/${plugin_name}/${plugin_version}/${plugin_name}_${plugin_version}_linux_amd64.zip"
RUN curl -Ls $plugin_url -o /tmp/${plugin_name}.zip && unzip /tmp/${plugin_name}.zip -d /home/ec2-user/terraform-plugins/linux_amd64/

# terraform archive plugin
ENV plugin_name="terraform-provider-archive"
ENV plugin_version="1.2.2"
ENV plugin_url="https://releases.hashicorp.com/${plugin_name}/${plugin_version}/${plugin_name}_${plugin_version}_linux_amd64.zip"
RUN curl -Ls $plugin_url -o /tmp/${plugin_name}.zip && unzip /tmp/${plugin_name}.zip -d /home/ec2-user/terraform-plugins/linux_amd64/

# terraform external plugin
ENV plugin_name="terraform-provider-external"
ENV plugin_version="1.1.2"
ENV plugin_url="https://releases.hashicorp.com/${plugin_name}/${plugin_version}/${plugin_name}_${plugin_version}_linux_amd64.zip"
RUN curl -Ls $plugin_url -o /tmp/${plugin_name}.zip && unzip /tmp/${plugin_name}.zip -d /home/ec2-user/terraform-plugins/linux_amd64/

# terraform template plugin
ENV plugin_name="terraform-provider-template"
ENV plugin_version="2.1.2"
ENV plugin_url="https://releases.hashicorp.com/${plugin_name}/${plugin_version}/${plugin_name}_${plugin_version}_linux_amd64.zip"
RUN curl -Ls $plugin_url -o /tmp/${plugin_name}.zip && unzip /tmp/${plugin_name}.zip -d /home/ec2-user/terraform-plugins/linux_amd64/

# terraform tls plugin
ENV plugin_name="terraform-provider-tls"
ENV plugin_version="2.0.1"
ENV plugin_url="https://releases.hashicorp.com/${plugin_name}/${plugin_version}/${plugin_name}_${plugin_version}_linux_amd64.zip"
RUN curl -Ls $plugin_url -o /tmp/${plugin_name}.zip && unzip /tmp/${plugin_name}.zip -d /home/ec2-user/terraform-plugins/linux_amd64/

# terraform plugins
RUN chown -R ec2-user:ec2-user /home/ec2-user/terraform-plugins
RUN find /home/ec2-user/terraform-plugins -type f | xargs ls -l

#.terraform.d/plugins
ENV plugin_cache_dir="/home/ec2-user/terraform-plugins"
RUN mkdir -p /home/ec2-user/.terraform.d/plugins/
RUN cp -pr $plugin_cache_dir/linux_amd64/ /home/ec2-user/.terraform.d/plugins/
RUN chown -R ec2-user:ec2-user /home/ec2-user/.terraform.d/

# amazon-ecr-credential-helper
# RUN go get -u github.com/awslabs/amazon-ecr-credential-helper/ecr-login/cli/docker-credential-ecr-login
# RUN cp -v ~/go/bin/docker-credential-ecr-login /usr/bin/

USER ec2-user

ENV GIT_REPO="git repo goes here"
ENV GIT_REVISION="git revision here"
ENV GIT_USERNAME="git username goes here"
ENV GIT_PAT="git personal access token goes here"
ENV REPO_PATH="repo path goes here"
ENV TF_VERSION="latest"
ENV TF_COMMAND="tf plan"

ENTRYPOINT source /home/ec2-user/execute-tf.sh
