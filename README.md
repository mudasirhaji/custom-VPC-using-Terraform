Provision VPC, Security-groups, EC2 Instance, and many more using Terraform

Terraform is an open-source infrastructure as a code software tool that lets us configure our infrastructure using declarative configuration files.
Agenda :
This blog will look at how to use Terraform with AWS to create a custom VPC, Subnets, route tables, Internet Gateway, and an EC2 instance.
Prerequisites:
AWS Account
Terraform Installed on the local machine
AWS CLI (with IAM User already created on AWS)
VS Code

We usually follow these basic steps when setting up a new VPC to deploy EC2 instances.
Create a vpc
Create subnets for different parts of the infrastructure
Attach an internet gateway to the VPC
Create a route table for a public subnet
Create security groups to allow specific traffic
Create ec2 instances on the subnets

1. Create a vpc
First of all, create a directory named VPC, and inside that, we will create a file named VPC_with_EC2.tf file with the below code that will deploy the resources in the 'us-east-1' region:

provider "aws" {
  region = "us-east-1"
}
The above code allows us to define the provider that will help us connect to the correct cloud services.
Now we will set up a new VPC with the cidr block 10.10.0.0/16 and the name "my_VPC". We can reference the VPC locally in the tf file using my_VPC.

// Create VPC
resource "aws_vpc" "my_VPC" {
  cidr_block = "10.10.0.0/16"
}
2. Create subnets
We must specify an IPv4 CIDR block for the subnet from the range of our VPC. We can optionally specify an IPv6 CIDR block for a subnet if there is an IPv6 CIDR block associated with the VPC. For this demo, we will create only one IPV4 public subnet with the below code:
// Create Subnet

resource "aws_subnet" "my_Publicsubnet" {
  vpc_id     = aws_vpc.my_VPC.id
  cidr_block = "10.10.1.0/24"

  tags = {
    Name = "my_Publicsubnet"
  }
}
3. Attach an internet gateway to the VPC
An internet gateway is a horizontally scaled, redundant, and highly available VPC component that allows communication between your VPC and the internet. It supports IPv4 and IPv6 traffic.
Now let's create an internet gateway and attach it to our custom VPC with the below code :
// Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_VPC.id

  tags = {
    Name = "my_igw"
  }
}
4. Create a route table for a public subnet
A route table contains a set of rules, called routes, that determine where network traffic from your subnet or gateway is directed. Now we need a route table to handle routing to our public subnet. Below is the code to create a new route table in our custom VPC:
// Create Route Table
resource "aws_route_table" "my_routetable" {
  vpc_id = aws_vpc.my_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "my_routetable"
  }
}
5. Create route table associations
Provides a resource to create an association between a route table and a subnet or a route table and an internet gateway or virtual private gateway.
Below is the code to associate our public subnet with our route table.
//associate subnet with route table
resource "aws_route_table_association" "my-rt-association" {
  subnet_id      = aws_subnet.my_Publicsubnet.id
  route_table_id = aws_route_table.my_routetable.id
}
6. Create security groups to allow specific traffic
A security group acts as a firewall that controls the traffic allowed to and from the resources in your virtual private cloud (VPC). You can choose the ports and protocols to allow for inbound traffic and for outbound traffic.
Here we need to create a security group that allows ssh traffic on port 22. We'll also allow outgoing traffic on all ports.
// Create Security Group
resource "aws_security_group" "my_SG" {
  name        = "my_SG"
  vpc_id      = aws_vpc.my_VPC.id

  ingress {
    from_port        = 20
    to_port          = 20
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "my_SG"
  }
}
7. Create an EC2 instance
Time to deploy an EC2 instance. Here we will use an existing key pair to access our EC2 Instance via SSH. Also apart from the resource aws_instance we need to mention the subnet id and security group ids that we created earlier so that our EC2 instance is created in our custom VPC rather than in the default VPC.
// Create EC2 Instance

resource "aws_instance" "my_EC2_Instance" {
  ami           = "ami-03c7d01cf4dedc891" # us-east-1
  instance_type = "t2.micro"
  key_name   = "devops"
  subnet_id = aws_subnet.my_Publicsubnet.id
  vpc_security_group_ids = [aws_security_group.my_SG.id]

}
Applying Terraform Init:
Now since our terraform code is ready to apply we need to follow terraform workflow in order to provision our infrastructure in the AWS cloud.
The working directory holding the Terraform configuration files is initialized using the terraform init command. After creating a new Terraform configuration or cloning an existing one from version control, this is the first command that needs to be executed. It is safe to execute this command more than once. This command performs multiple distinct startup processes in order to prepare the current working directory for use with Terraform.

Terraform Validate:
The terraform validate command validates the configuration files in a directory, referring only to the configuration and not accessing any remote services such as remote state, provider APIs, etc.
We can use this command to make sure that our code is without any syntax errors.

Create a Terraform Plan
The terraform plan command generates an execution plan, allowing you to see a preview of the infrastructure modifications that Terraform intends to make. The plan command by itself won't really implement the suggested changes, so before applying them or sharing your changes with your team for wider evaluation, you can use this command to see if the suggested changes line up with your expectations. If Terraform discovers no changes to resources, then the Terraform plan indicates that no changes are required to the real infrastructure.

In the second part of the terraform plan output, you can notice that 7 resources will be deployed on the AWS cloud:
Terraform Apply
The steps suggested in a Terraform plan are carried out using the terraform apply command. It asks for confirmation from the user before making any changes, unless it was explicitly told to skip approval.

To verify our infrastructure has been provisioned we can log in to our AWS account and check the resources which were to be created:

Hence we have successfully created the required resources with the use of Terraform.
Terraform destroy
The terraform destroy command allows us to easily destroy all infrastructure managed by a specific Terraform configuration. While you should avoid destroying resources in a production environment, Terraform is occasionally used to manage ephemeral infrastructure for development reasons, in which case you can use terraform destroy to conveniently wipe away all of those temporary objects after you're done.
Terraform destroy is a command that should be used with caution. It is not something that would be used on a daily basis in the industrial setting.

Hence we have successfully destroyed the resources in one go using terraform destroy command.
Conclusion
In this blog, we learned how to create a custom VPC with its associated security groups, route tables, Internet Gateway, and an EC2 Instance.Also, we learned how to destroy the same infrastructure using terraform destroy command.

Thanks
Mudasir
