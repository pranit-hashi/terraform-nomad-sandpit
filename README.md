# Terraform Nomad Sandpit

A comprehensive Terraform project for deploying a multi-region HashiCorp Nomad Enterprise cluster on AWS with federation support.

## Overview

This repository provides Infrastructure as Code (IaC) to deploy a complete HashiCorp Nomad Enterprise cluster across two AWS regions (Sydney and Singapore) with the following components:

- **Multi-region VPC infrastructure** with Transit Gateway peering
- **Nomad Enterprise servers** with federation support
- **Nomad clients** with auto-join capability
- **Bastion hosts** for secure SSH access
- **Load balancers** for Nomad HTTP API access
- **Route53 DNS** integration for service discovery

### Architecture

```
Region 1 (ap-southeast-2 - Sydney)          Region 2 (ap-southeast-1 - Singapore)
├── VPC (10.200.0.0/16)                     ├── VPC (10.210.0.0/16)
├── 3 Public Subnets                        ├── 3 Public Subnets
├── 3 Private Subnets                       ├── 3 Private Subnets
├── Bastion Host                            ├── Bastion Host
├── Nomad Server (1x)                       ├── Nomad Server (1x)
├── Nomad Clients (4x)                      ├── Nomad Clients (4x)
└── Application Load Balancer               └── Application Load Balancer
                    └──────── Transit Gateway Peering ────────┘
```

## Prerequisites

Before you begin, ensure you have the following installed and configured:

### Required Tools

1. **Terraform** (>= 1.0)
   ```bash
   brew install terraform
   ```

2. **Packer** (>= 1.14.3) - for building custom AMIs
   ```bash
   brew install packer
   ```

3. **AWS CLI** (>= 2.0)
   ```bash
   brew install awscli
   aws configure
   ```

4. **Git**
   ```bash
   brew install git
   ```

### AWS Requirements

- AWS Account with appropriate permissions
- AWS credentials configured (`~/.aws/credentials` or environment variables)
- Access to create resources in `ap-southeast-2` (Sydney) and `ap-southeast-1` (Singapore)
- Route53 hosted zone (if using DNS features)

### Required Permissions

Your AWS IAM user/role needs permissions for:
- EC2 (instances, VPCs, subnets, security groups, key pairs)
- Transit Gateway
- Route53 (if using DNS)
- IAM (for instance profiles)
- Application Load Balancer

### HashiCorp Nomad Enterprise License

You'll need a valid Nomad Enterprise license. Set it in `variables.tf` or pass it as a variable during deployment.

## Project Structure

```
terraform-nomad-sandpit/
├── main.tf                          # Root module orchestration
├── variables.tf                     # Input variables
├── providers.tf                     # AWS provider configuration
├── outputs.tf                       # Output values
├── 01-prerequisites/                # Infrastructure prerequisites
│   └── aws/                         # AWS infrastructure
│       ├── vpc.tf                   # VPC configuration
│       ├── ec2.tf                   # Bastion host
│       ├── security.tf              # Security groups
│       ├── keypair.tf               # SSH key pairs
│       ├── tgw.tf                   # Transit Gateway
│       └── region-peering/          # Cross-region peering
├── 02-solution/                     # Nomad deployment
│   └── ec2/
│       ├── nomad-servers/           # Nomad server configuration
│       │   ├── ec2.tf
│       │   ├── lb.tf                # Load balancer
│       │   ├── dns.tf               # Route53 DNS
│       │   ├── security.tf
│       │   └── templates/           # Nomad config templates
│       └── nomad-clients/           # Nomad client configuration
│           ├── ec2.tf
│           ├── iam.tf               # IAM roles for auto-join
│           ├── security.tf
│           └── templates/           # Nomad config templates
└── examples/
    └── amis/
        └── nomad/                   # Packer templates for AMIs
            ├── nomad-ent.pkr.hcl    # Server AMI
            ├── nomad-client-ent.pkr.hcl  # Client AMI
            └── scripts/             # Installation scripts
```

## Getting Started

### Step 1: Clone the Repository

```bash
git clone https://github.com/phan-t/terraform-nomad-sandpit.git
cd terraform-nomad-sandpit
```

### Step 2: Build Custom AMIs

Before deploying the infrastructure, you need to build custom AMIs with Nomad pre-installed.

#### Build Nomad Server AMI

```bash
cd examples/amis/nomad

# Build for Sydney region
packer build -var 'aws_region=ap-southeast-2' nomad-ent.pkr.hcl

# Build for Singapore region
packer build -var 'aws_region=ap-southeast-1' nomad-ent.pkr.hcl

cd ../../..
```

#### Build Nomad Client AMI (Optional - if using separate client AMI)

```bash
cd examples/amis/nomad

# Build for Sydney region
packer build -var 'aws_region=ap-southeast-2' nomad-client-ent.pkr.hcl

# Build for Singapore region
packer build -var 'aws_region=ap-southeast-1' nomad-client-ent.pkr.hcl

cd ../../..
```

**Note:** The AMI build process will:
- Use Ubuntu 20.04 as the base image
- Install Nomad Enterprise (version 1.11.0+ent by default)
- Configure necessary dependencies
- Tag the AMI with `application: nomad`

### Step 3: Configure Variables

Edit `variables.tf` or create a `terraform.tfvars` file with your specific values:

```hcl
# terraform.tfvars
deployment_name = "sandpit"

aws_region_1 = "ap-southeast-2"  # Sydney
aws_region_2 = "ap-southeast-1"  # Singapore

aws_route53_sandbox_prefix = "your-name"  # Your Route53 prefix

nomad_ent_license = "your-nomad-enterprise-license-key"
```

### Step 4: Initialize Terraform

```bash
terraform init
```

This will:
- Download required provider plugins (AWS ~> 6.21.0)
- Initialize the backend
- Download required modules

### Step 5: Plan the Deployment

```bash
terraform plan
```

Review the planned changes. The deployment will create approximately:
- 2 VPCs (one per region)
- 6 subnets per region (3 public, 3 private)
- 2 NAT Gateways
- 2 Internet Gateways
- 2 Transit Gateways with peering
- 2 Bastion hosts
- 2 Nomad servers
- 8 Nomad clients (4 per region)
- 2 Application Load Balancers
- Multiple security groups
- IAM roles and instance profiles
- Route53 DNS records

### Step 6: Deploy the Infrastructure

```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

**Deployment time:** Approximately 15-20 minutes.

### Step 7: Retrieve Outputs

After successful deployment, Terraform will display important outputs:

```bash
terraform output
```

Expected outputs:
- `deployment_id` - Unique deployment identifier
- `aws_bastion_public_fqdn_region_1` - Bastion host for Sydney
- `aws_bastion_public_fqdn_region_2` - Bastion host for Singapore
- `nomad-http-api-public-dns-region-1` - Nomad UI for Sydney
- `nomad-http-api-public-dns-region-2` - Nomad UI for Singapore

## Accessing the Nomad Cluster

### Access Nomad UI

Open your browser and navigate to the Nomad HTTP API endpoints:

```bash
# Region 1 (Sydney)
open $(terraform output -raw nomad-http-api-public-dns-region-1)

# Region 2 (Singapore)
open $(terraform output -raw nomad-http-api-public-dns-region-2)
```

### SSH Access via Bastion

To SSH into instances, use the bastion host as a jump server:

```bash
# Get the bastion hostname
BASTION_HOST=$(terraform output -raw aws_bastion_public_fqdn_region_1)

# Get the private key (saved during deployment)
DEPLOYMENT_ID=$(terraform output -raw deployment_id)

# SSH to a Nomad server (replace with actual private IP)
ssh -J ubuntu@$BASTION_HOST ubuntu@<nomad-server-private-ip>
```

### Using Nomad CLI

Install the Nomad CLI locally:

```bash
brew install nomad
```

Set the Nomad address:

```bash
export NOMAD_ADDR=$(terraform output -raw nomad-http-api-public-dns-region-1)
```

Verify the cluster:

```bash
# Check server members
nomad server members

# Check client nodes
nomad node status

# Check cluster region
nomad server members -verbose
```

## Nomad Federation

This deployment configures Nomad federation between the two regions, allowing:
- Cross-region job placement
- Unified namespace across regions
- Automatic failover capabilities

The federation is configured through the `nomad_federation_peer_address` variable, which connects Region 2 to Region 1.

To verify federation:

```bash
# From Region 1
export NOMAD_ADDR=$(terraform output -raw nomad-http-api-public-dns-region-1)
nomad server members -verbose

# You should see servers from both regions
```

## Running Your First Job

Create a simple job file `example.nomad`:

```hcl
job "example" {
  datacenters = ["dc1"]
  type = "service"

  group "web" {
    count = 3

    task "server" {
      driver = "docker"

      config {
        image = "nginx:latest"
        ports = ["http"]
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }

    network {
      port "http" {
        static = 80
      }
    }
  }
}
```

Run the job:

```bash
nomad job run example.nomad
nomad job status example
```

## Configuration Details

### Network Configuration

- **Region 1 VPC CIDR:** 10.200.0.0/16
- **Region 2 VPC CIDR:** 10.210.0.0/16
- **Private Subnets:** Calculated automatically per AZ
- **Public Subnets:** Calculated automatically per AZ

### Instance Types

- **Nomad Servers:** t2.small (1 vCPU, 2GB RAM)
- **Nomad Clients:** t2.large (2 vCPU, 8GB RAM)
- **Bastion Hosts:** t2.micro

### Security Groups

- Nomad servers: Ports 4646 (HTTP), 4647 (RPC), 4648 (Serf)
- Nomad clients: Dynamic port range for task allocation
- Bastion: Port 22 (SSH) from allowed IPs
- Load balancer: Port 4646 (HTTP API)

### High Availability

- NAT Gateway: Single NAT per region (cost optimization)
- Nomad Servers: Single server per region (can be scaled)
- Nomad Clients: 4 clients per region for redundancy

## Customization

### Scaling Nomad Clients

To change the number of Nomad clients, edit `02-solution/ec2/nomad-clients/ec2.tf`:

```hcl
resource "aws_instance" "nomad-client" {
  count = 6  # Change from 4 to desired number
  # ...
}
```

### Changing Instance Types

Edit the respective `ec2.tf` files and modify the `instance_type` parameter.

### Adding More Regions

To add additional regions:
1. Create a new provider alias in `providers.tf`
2. Add a new module block in `main.tf` for the infrastructure
3. Add Nomad server and client modules for the new region
4. Configure Transit Gateway peering

## Maintenance

### Updating Nomad Version

1. Update the `nomad_version` variable in Packer templates
2. Rebuild AMIs for both regions
3. Update the AMI IDs in the Terraform configuration
4. Run `terraform apply` to replace instances

### Destroying the Infrastructure

To tear down all resources:

```bash
terraform destroy
```

**Warning:** This will permanently delete all resources, including data stored on instances.

## Troubleshooting

### AMI Not Found Error

If you receive an "AMI not found" error:
1. Verify AMIs were built in the correct regions
2. Check AMI filters in `02-solution/ec2/nomad-servers/ec2.tf` and `nomad-clients/ec2.tf`
3. Ensure AMIs are tagged with `application: nomad`

### Connection Issues

If you cannot access Nomad UI:
1. Verify security group rules allow inbound traffic on port 4646
2. Check that the load balancer is healthy
3. Verify Route53 DNS records are created correctly

### Nomad Agents Not Joining

If Nomad agents don't join the cluster:
1. SSH to the instance via bastion
2. Check Nomad logs: `sudo journalctl -u nomad -f`
3. Verify security groups allow Nomad ports (4646, 4647, 4648)
4. Check IAM instance profile for client auto-join

### Transit Gateway Peering Issues

If cross-region connectivity fails:
1. Verify Transit Gateway attachments are in "available" state
2. Check route tables include routes to the peer VPC CIDR
3. Verify security groups allow traffic from peer region CIDR

## Cost Optimization

Current configuration is designed for sandpit/testing:
- Single NAT Gateway per region (~$32/month per region)
- Small instance types
- No reserved instances

For production:
- Enable multi-AZ NAT Gateways for high availability
- Use larger instance types with reserved instances
- Consider spot instances for Nomad clients
- Implement auto-scaling groups

## Security Considerations

This is a sandpit environment. For production deployments:

- [ ] Enable encryption at rest for EBS volumes
- [ ] Enable encryption in transit with TLS
- [ ] Implement ACLs for Nomad
- [ ] Restrict security group source IPs
- [ ] Enable VPC Flow Logs
- [ ] Implement AWS GuardDuty
- [ ] Use AWS Secrets Manager for license storage
- [ ] Enable MFA for SSH access
- [ ] Implement bastion host session logging
- [ ] Use AWS Systems Manager Session Manager instead of SSH

## Contributing

Contributions are welcome! Please follow these guidelines:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is provided as-is for educational and demonstration purposes.

## Support

For issues and questions:
- Open an issue in the GitHub repository
- Refer to [HashiCorp Nomad documentation](https://www.nomadproject.io/docs)
- Check [Terraform AWS Provider documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## Additional Resources

- [Nomad Documentation](https://www.nomadproject.io/docs)
- [Nomad Learn Tutorials](https://learn.hashicorp.com/nomad)
- [Terraform AWS Modules](https://registry.terraform.io/namespaces/terraform-aws-modules)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

## Version History

- **Initial Release** - Multi-region Nomad Enterprise deployment with federation support

---

**Author:** Pranit Raje  
**Last Updated:** November 26, 2025