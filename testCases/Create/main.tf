terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Variables for Amazon Connect test case creation
variable "aws_instance_id" {
  description = "The Amazon Connect instance ID"
  type        = string
}

variable "test_case_name" {
  description = "The name of the test case"
  type        = string
  default     = "Example Voice Test Case via CLI"
}

variable "test_case_description" {
  description = "The description of the test case"
  type        = string
  default     = "A test case created via the AWS CLI"
}

variable "content_file_path" {
  description = "The path to the test case content file"
  type        = string
  default     = "file://test-flow-scripts/greeting-test.json"
}

variable "aws_region" {
  description = "The AWS region where the test case will be created"
  type        = string
  default     = "us-east-1"
}

variable "flow_id" {
  description = "The Flow ID for entry point parameters"
  type        = string
}

# Create Amazon Connect test case using AWS CLI
resource "terraform_data" "connect_test_case" {
  # Trigger recreation when any of these values change
  input = {
    instance_id = var.aws_instance_id
    name        = var.test_case_name
    description = var.test_case_description
    content     = var.content_file_path
    region      = var.aws_region
    flow_id     = var.flow_id
  }

  provisioner "local-exec" {
    command = "bash create-test-case.sh"
    
    environment = {
      INSTANCE_ID        = var.aws_instance_id
      TEST_CASE_NAME     = var.test_case_name
      TEST_CASE_DESCRIPTION = var.test_case_description
      CONTENT_FILE_PATH  = var.content_file_path
      AWS_REGION         = var.aws_region
      FLOW_ID            = var.flow_id
    }
  }
}

# Output the test case creation status
output "test_case_creation_info" {
  description = "Information about the created test case"
  value = {
    instance_id = var.aws_instance_id
    name        = var.test_case_name
    region      = var.aws_region
  }
}
