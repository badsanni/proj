#!/bin/bash
#test theis out
sudo yum update -y
sudo yum remove java-1.7.0-openjdk
sudo yum install java-1.8.0 -y
sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
sudo rpm --import  https://pkg.jenkins.io/redhat/jenkins.io.key
sudo yum install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins
exit
 
