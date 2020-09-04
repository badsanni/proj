provider "aws" {
    region = "us-east-1"
}

resource "aws_security_group" "proj_sg" {
  name        = "proj_ansible_jenkins"
  description = "Allow ssh and http ports"
 

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow_jenkins"
  }

}

resource "aws_instance" "ba_jenkins" {
  ami = "ami-0cebb45b34604efb8"
  instance_type = "t3.micro"
  key_name   = "Demo"
  vpc_security_group_ids = ["${aws_security_group.proj_sg.id}"]
root_block_device {
   delete_on_termination = "true"
   volume_size = "20"
   volume_type = "gp2"
   }
  tags = {
    Name = "Jenkins"
    Created_by = "Terraform"
  }
}

resource "aws_instance" "ba_ansible" {
  ami = "ami-0cebb45b34604efb8"
  instance_type = "t3.micro"
  key_name   = "Demo"
  vpc_security_group_ids = ["${aws_security_group.proj_sg.id}"]
root_block_device {
   delete_on_termination = "true"
   volume_size = "20"
   volume_type = "gp2"
   }
  tags = {
    Name = "Ansible"
    Created_by = "Terraform"
  }
}

resource "aws_eip" "jenkins" {
    vpc      = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.ba_jenkins.id
  allocation_id = aws_eip.jenkins.id

   }




output "Jenkins_private_ip" {
  value = aws_instance.ba_jenkins.private_ip
}


output "Jenkins_Public_ip" {
  value = aws_instance.ba_jenkins.public_ip
}

output "Ansible_Priv_ip" {
  value = aws_instance.ba_ansible.private_ip
}
