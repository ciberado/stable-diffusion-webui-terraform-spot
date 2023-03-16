module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.prefix}-vpc"
  cidr = "${var.vpc_addr_prefix}.0.0/16"

  azs = ["${var.region}a", "${var.region}b"]

  public_subnets  = ["${var.vpc_addr_prefix}.100.0/24", "${var.vpc_addr_prefix}.101.0/24"]
  private_subnets = ["${var.vpc_addr_prefix}.200.0/24", "${var.vpc_addr_prefix}.201.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = false

  tags = {
    Layer : "network fabric"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "${var.prefix}_app_sg"
  description = "Petclinic security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP from Anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from Anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App port"
    from_port   = 7860
    to_port     = 7860
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
    Layer : "network fabric"
  }
}

// Computing

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] /* Ubuntu */

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "aws_iam_policy_document" "assume_role_ec2" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "app_role" {
  name               = "${var.prefix}_app_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
}

data "aws_iam_policy" "ssm_core_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm_core_policy_attach" {
  role       = aws_iam_role.app_role.name
  policy_arn = data.aws_iam_policy.ssm_core_policy.arn
}

resource "aws_iam_instance_profile" "app_profile" {
  name = "${var.prefix}_app_profile"
  role = aws_iam_role.app_role.name
}

module "app" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  create_spot_instance = true
  spot_type            = "persistent"

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.app_instance_type
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.app_profile.name

  user_data = file("userdata.sh")

  root_block_device = [{
    volume_size = 150
    volume_type = "gp3"
  }]

  volume_tags = {
    Name = "${var.prefix}-${lower(var.owner)}"
  }

  tags = {
    Name = "${var.prefix}-${lower(var.owner)}"
    Layer : "computing"
  }

  spot_wait_for_fulfillment = true
}

resource "null_resource" "tag_instance" {
  depends_on = [
    module.app
  ]  
  
  provisioner "local-exec" {
      command = "aws ec2 create-tags --resources ${module.app.spot_instance_id} --tags Key=Name,Value=${var.prefix}-${lower(var.owner)} --region ${var.region}"
  }
}