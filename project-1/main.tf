resource "aws_security_group" "my_security_group" {
  name        = "MySecurityGroup"
  description = "My security group description"
  vpc_id      = aws_vpc.my_vpc.id  # Use the VPC ID created in Task 1

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "MySecurityGroup"
  }
}

resource "aws_instance" "my_instance" {
  ami           = "ami-06aa3f7caf3a30282"  # Ubuntu 20.04 LTS, replace with the latest Ubuntu AMI
  instance_type = "t2.micro"  # Change to your desired instance type
  key_name      = "jenkins"  # Replace with your key pair name

  subnet_id = aws_subnet.public_subnet.id

  vpc_security_group_ids = [aws_security_group.my_security_group.id]  # Use the Security Group ID created above
  

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "echo 'Welcome to CoderView Technologies' | sudo tee /var/www/html/index.html",
      "sudo service nginx restart"
    ]

    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("${path.module}/jenkins.pem")
      host     = self.public_ip
    }
  }
}

