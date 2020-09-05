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
    Name       = "Allow_ssh_jenkins"
    Created_by = "Terraform"
  }

}

resource "aws_instance" "ba_jenkins" {
  ami                    = "ami-0cebb45b34604efb8"
  instance_type          = "t3.micro"
  key_name               = "Demo"
  vpc_security_group_ids = ["${aws_security_group.proj_sg.id}"]
  root_block_device {
    delete_on_termination = "true"
    volume_size           = "20"
    volume_type           = "gp2"
  }
  tags = {
    Name       = "Jenkins"
    Created_by = "Terraform"

  }

  provisioner "file" {
    source      = "jenkins.sh"
    destination = "/tmp/jenkins.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "chmod +x /tmp/jenkins.sh",
      "/tmp/jenkins.sh",
    ]
  }

  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("demo.pem")
  }
}

resource "aws_eip" "jenkins" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.ba_jenkins.id
  allocation_id = aws_eip.jenkins.id
}


resource "aws_instance" "ba_ansible" {
  ami                    = "ami-0cebb45b34604efb8"
  instance_type          = "t3.micro"
  key_name               = "Demo"
  vpc_security_group_ids = ["${aws_security_group.proj_sg.id}"]
  root_block_device {
    delete_on_termination = "true"
    volume_size           = "20"
    volume_type           = "gp2"
  }
  tags = {
    Name       = "Ansible"
    Created_by = "Terraform"
  }

  provisioner "file" {
    source      = "ansible.sh"
    destination = "/tmp/ansible.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "chmod +x /tmp/ansible.sh",
      "/tmp/ansible.sh",
    ]
  }

  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("demo.pem")
  }
}



output "Jenkins_private_ip" {
  value       = aws_instance.ba_jenkins.private_ip
  description = "The Private ip for Jenkins server"
}


output "Jenkins_Public_ip" {
  value       = aws_instance.ba_jenkins.public_ip
  description = "The Public ip for Jenkins server"
}

output "Jenkins_URL" {
  value       = "http://${aws_eip.jenkins.public_ip}:8080"
  description = "The Public ip for Jenkins server"
}

output "Ansible_Priv_ip" {
  value       = aws_instance.ba_ansible.private_ip
  description = "The Private ip for Ansible server"
}
