# Terraform provisioning of Stable Diffusion on Spot Instances

This repo contains a Terraform template that will automatically install and execute
[Automatic1111 webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui) using
an AWS spot instance to reduce the cost of the solution.

The cost of spot instances is not constant, but I expect to pay less than $0.30 per
hour. **Please, don't forget to destroy the deployment once you don't need it anymore,
as keeping the instance running for once month will cost around $250.**

## Preparation (Ubuntu 22.04)

* Install terraform

```bash
sudo apt install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com jammy main" -y
sudo apt update 
sudo apt install terraform -y
```

* Install the AWS CLI

```bash
sudo apt update
sudo apt install awscli -y
```

* Configure your AWS credentials

```bash
export AWS_ACCESS_KEY_ID="xxxxxxxxxx"
export AWS_SECRET_ACCESS_KEY="xxxxxxxxxxx"
export AWS_SESSION_TOKEN="xxxxxxxxxxx"
```

## Launching the instance

* Clone the repository

```bash
git clone https://github.com/ciberado/stable-diffusion-webui-terraform-spot
cd stable-diffusion-webui-terraform-spot/src
```

* Initialize the providers

```bash
terraform init
```

* Execute the terraform configuration:

```bash
terraform apply --auto-approve --var region=eu-west-1 --var owner=$USER
```

After a few minutes the infrastructure will be created and you will get the IP
of the instance as an output parameter named `spot_instance_public_ip`, but
downloading and installing Stable Diffusion and Automatic1111 will take 15 or
20 additional minutes. Just keep trying to open that IP address from your
browser until instead of a gateway error you get access to the UI. **Use `http`
and not `https`, as currently there is no TLS configuration in place**.

## Clean up

* Destroy the infrastructure

```bash
terraform destroy --var region=eu-west-1 --var owner=$USER
```

## Troubleshooting

The EC2 instance should be tagged properly (thanks to the use of a `local-provisioner`),
so it should be easy to find it in the AWS console. From there, use *Session Manager* to
connect to the instance.

## TODO

- [ ] Create a service to facilitate stopping the instance instead of destroying the whole infrastructure
- [ ] Add support for TLS
