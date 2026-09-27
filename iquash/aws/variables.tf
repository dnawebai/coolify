variable "aws_region" {
  description = "AWS region for the iQuash OCR host."
  type        = string
  default     = "ca-central-1"
}

variable "name" {
  description = "Resource name prefix."
  type        = string
  default     = "iquash-coolify-ocr"
}

variable "instance_type" {
  description = "CPU/RAM for PaddleOCR + Docling. t3.xlarge = 4 vCPU / 16 GiB."
  type        = string
  default     = "t3.xlarge"
}

variable "root_volume_gb" {
  description = "Encrypted gp3 root disk."
  type        = number
  default     = 120
}

variable "vpc_id" {
  description = "Existing VPC ID."
  type        = string
}

variable "subnet_id" {
  description = "Existing public subnet ID with route to an Internet Gateway."
  type        = string
}
