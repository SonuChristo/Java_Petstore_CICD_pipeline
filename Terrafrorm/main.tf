# Create a security group with inbound rules for ports 22, 80, 443, 8080, 9000, and 3000
resource "aws_security_group" "my-sg-jenkins2" {
  name        = "my-sg-jenkins2"
  description = "Security Group for Jenkins"

 ingress = [
    for port in [22, 80, 443, 8080, 9000, 3000] : {
      description      = "TLS from VPC"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Add any additional security group settings here
  
}
resource "tls_private_key" "rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
variable "key_name" {}

# Create an AWS key pair (replace "your-key-name" with your desired key pair name)
resource "aws_key_pair" "key-pair" {
  key_name = var.key_name
  public_key =   tls_private_key.rsa-4096.public_key_openssh
}
resource "local_file" "private_key" {
  content  = tls_private_key.rsa-4096.private_key_pem
  filename = var.key_name
}
# Create an AWS EC2 instance with the specified instance type, security group, and key pair
resource "aws_instance" "web" {
  ami                    = "ami-0b6c2d49148000cd5"  # Replace with your desired AMI
  instance_type          = "t2.large"
  vpc_security_group_ids = [aws_security_group.my-sg-jenkins2.id]
  key_name               = aws_key_pair.key-pair.key_name


tags = {
  Name = "2048-Game"
}
root_block_device {
  volume_size = 30
}
}


