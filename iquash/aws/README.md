# AWS host for iQuash Coolify + OCR

This stack provisions the complete AWS network and EC2 host for the iQuash document stack.

It creates its own VPC, public subnet, Internet Gateway, route table, security group, Ubuntu 24.04 instance, SSM instance role, encrypted gp3 disk and Elastic IP.

Default region is `ca-central-1`. Default compute is `t3.xlarge` (4 vCPU / 16 GiB) with 120 GiB encrypted gp3.

Public inbound access is limited to ports 80 and 443. There is no public SSH rule; administration uses AWS Systems Manager Session Manager.

The instance bootstrap clones `dnawebai/coolify` and runs the Coolify installer. The OCR stack is already defined in `iquash/docker-compose.ocr.yml`.

## One-time AWS bootstrap

Deploy `bootstrap-github-oidc.yml` once in the AWS account. Its output is the GitHub IAM role ARN. Store that ARN in the repository secret:

`AWS_IQUASH_TERRAFORM_ROLE_ARN`

No long-lived AWS access key is required.

Then run the **AWS Coolify Terraform** GitHub workflow with `plan` first and `apply` when ready.

After apply, use the Elastic IP for:

- `ocr.iquash.com`
- `docling.iquash.com`
