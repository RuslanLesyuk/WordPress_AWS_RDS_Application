# Word Press Application on AWS Instance EC2 with AWS RDS 

This application only for test not for production.
### Its working with:
- 4 subnets
- AWS Load Balancer
- AWS RDS
- Docker-Compose v2

## Lets try to Start it :)

## Installation

Requires:
- Terraform
- Ansible

### Terraform
First, install repository addition dependencies:

```sh
sudo apt update
sudo apt install  software-properties-common gnupg2 curl
```

Now import repository GPG key
```sh
curl https://apt.releases.hashicorp.com/gpg | gpg --dearmor > hashicorp.gpg
sudo install -o root -g root -m 644 hashicorp.gpg /etc/apt/trusted.gpg.d/
```

With the key imported now add Hashicorp repository to your Ubuntu system:

```sh
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
```

Now install terraform on your Ubuntu Linux system:

```sh
sudo apt install terraform
```

Check the version of terraform installed on your system

```sh
$ terraform --version
Terraform v1.3.7
on linux_amd64
```

### Ansible

From your control node, run the following command to include the official project’s PPA (personal package archive) in your system’s list of sources:

```sh
sudo apt-add-repository ppa:ansible/ansible
```

Next, refresh your system’s package index so that it is aware of the packages available in the newly included PPA:

```sh
sudo apt update
```

Following this update, you can install the Ansible software with:

```sh
sudo apt install ansible
```

# Clone my github repository

```sh
git clone https://github.com/RuslanLesyuk/WordPress_AWS_RDS_Application.git
cd WordPress_AWS_RDS_Application
```

## Edit Terraform acces key & secret key to AWS

##### You must have an AWS account on `aws.amazon.com`

- Create IAM user on ``aws.amazon.com`` look on: ``https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html``
- When create, save your `access key` and `secret key`
- Open `provider.tf` with `nano` or another editor
- And place your `access key` and `secret key` to ``placeholder`` where `acces_key` is your acces key and `secrret_key` is your `secret key`:

```    
    provider "aws" {
    #access_key = "placeholder"
    #secret_key = "placeholder"
    region = "eu-west-3"
}
```

- Now open `main.tf` and find there resource block:
```sh
resource "aws_key_pair" "master-key" {
  key_name   = "terraform"
  public_key = file("./addons/terraform.pub")
}
```

- You must generate your ssh keys it will be in future for `Ansible` too, so close your editor and make a few commands:
```sh
mkdir addons
cd addons
ssh-keygen
```

- You will see this output:

```sh
Generating public/private rsa key pair.
Enter file in which to save the key (/home/wic/.ssh/id_rsa):
```

- Type any name you want, if you dont type any name you will get two keys with default names`id_rsa` and `id_rsa.pub`
- After you make ssh-keys open `main.tf` one more time
- Find `resource` block like this:
```sh
resource "aws_key_pair" "master-key" {
  key_name   = "terraform"
  public_key = file("./addons/terraform.pub")
}
```
- Rename `terraform.pub` to your new generated ssh-key `example.pub`
- At last make a few commands in `WordPress_AWS_RDS_Application` directory:
```sh
Terraform init
Terraform Plan 
Terraform Apply (when it asked to type "yes", just type fingerprint "yes")
```
### Whait a few minutes your AWS account configure the EC2 Instance and RDS Instance 

# Lets configure Ansible

- Go to the Ansible directory
- Open hosts.ini looks like this:

[myserver]
Ubuntu ansible_host=`your_aws_public_ip` ansible_user=`your_user` ansible_ssh_private_key_file=`path_to_your_ansible_ssh_key`

- Make some changes
- Put into `your_aws_public_ip` your ``public ip`` from AWS Instance you can find it in EC2 services
- Put into `your_user` username `Ubuntu`
- Put into `path_to_your_ansible_ssh_key` the pass we was just created  `/home/your_user_name/WordPress_AWS_RDS_Application/addons/example.pub`
- Close hosts.ini
- And make a command:
```sh
ansible-playbook ansible-playbook.yml
```
This will install Docker and Docker-Compose v2 to your EC2 Instance in AWS !!!

### Now lets connect to your AWS instance via SSH
 
- Use command
```sh
ssh -i /home/your_user_name/.ssh/example.pub ubuntu@your_public_ip_adress_from_aws
press "enter"
```
- Congratulations You are in your AWS VM
- Type a command:
```sh
git clone https://github.com/docker/awesome-compose.git
cd awesome-compose/wordpress-mysql/
```
- Open with `nano` editor `compose.yaml`
- And we will make some changes in this file
- Find there `- WORDPRESS_DB_HOST=`
- Paste there your RDS server end point
- Where to find:

In your AWS Console find Service RDS launch him, then click `Databases` on left top corner, then shose your database `terraform-bla-bla-bla` and in field `Connectivity & security` find first column with name `Endpoint & port` and copy `terraform-bla-bla-bla-bla.ccmbkhuwukdj.eu-west-3.rds.amazonaws.com`

- Paste your just copied `End Point` to your `- WORDPRESS_DB_HOST=`
- Save and close file
- Make a command:
```sh
docker-compose up -d
```
- Wait a few minutes...

#### Use your AWS EC2 Instance `Public_IP` in your browser and install your first ``WordPress`` page

## Good luck hope you made it :)
