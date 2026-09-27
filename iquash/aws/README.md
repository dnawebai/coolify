# AWS host for iQuash Coolify + OCR

This Terraform stack provisions a persistent AWS EC2 host for the iQuash document stack.

## Design

- Ubuntu 24.04 LTS from Canonical's AWS SSM AMI parameter
- Default region: `ca-central-1`
- Default instance: `t3.xlarge` (4 vCPU / 16 GiB)
- 120 GiB encrypted gp3 root volume
- Elastic IP
- Public inbound ports: **80/443 only**
- **No public SSH**
- Administration through AWS Systems Manager Session Manager
- cloud-init clones `dnawebai/coolify` and runs the Coolify installer
- The existing `iquash/docker-compose.ocr.yml` then runs PaddleOCR + Docling

## Apply

Provide an existing VPC and a public subnet:

```bash
terraform init
terraform apply \
  -var='vpc_id=vpc-...' \
  -var='subnet_id=subnet-...'
```

The outputs return the instance ID, Elastic IP, an SSM shell command, and an SSM port-forward command for the Coolify dashboard on local port 8000.

After provisioning, point:

- `ocr.iquash.com`
- `docling.iquash.com`

to the Elastic IP and configure the matching services in Coolify.

Do not store AWS access keys, OCR API keys, or other secrets in this repository.
