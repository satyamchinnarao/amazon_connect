# Amazon Connect Test Case Creation

This project automates the creation of Amazon Connect test cases using Terraform and the AWS CLI. It allows you to define and deploy voice call test cases with custom flow scripts.

## Overview

The automation creates Amazon Connect test cases by:
- Using Terraform to manage infrastructure as code
- Executing a bash script via Terraform's `local-exec` provisioner
- Validating inputs and creating test cases via AWS CLI
- Supporting custom flow scripts in JSON format

## Prerequisites

- **Terraform** >= 1.0
- **AWS CLI** - Properly configured with credentials
- **Bash** - For executing the creation script
- **jq** - For JSON validation
- **AWS Permissions** - Required permissions to create Amazon Connect test cases

## Project Structure

```
Create/
├── create-test-case.sh          # Bash script to create test case via AWS CLI
├── main.tf                       # Terraform configuration
├── terraform.tfvars.example      # Example variable values
├── README.md                     # This file
└── test-flow-scripts/
    └── greeting-test.json        # Example test flow script
```

## Configuration

### Variables

The following variables can be configured in `terraform.tfvars` or passed via command line:

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_instance_id` | Amazon Connect instance ID (UUID format) | (Required - no default) |
| `test_case_name` | Name of the test case | `Example Voice Test Case via CLI` |
| `test_case_description` | Description of the test case | `A test case created via the AWS CLI` |
| `content_file_path` | Path to test flow script (must start with `file://`) | `file://test-flow-scripts/greeting-test.json` |
| `aws_region` | AWS region for the test case | `us-east-1` |
| `flow_id` | Flow ID for entry point parameters (UUID format) | (Required - no default) |

### Creating a terraform.tfvars file

Copy the example file and customize it:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
aws_instance_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"  # Your Amazon Connect instance ID
test_case_name = "My Test Case"
test_case_description = "Description of my test case"
content_file_path = "file://test-flow-scripts/greeting-test.json"
aws_region = "us-east-1"
flow_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"  # Your flow ID
```

## Usage

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Review the Plan

```bash
terraform plan
```

### 3. Apply the Configuration

```bash
terraform apply
```

### 4. Verify the Output

After successful creation, Terraform will output the test case information:

```
test_case_creation_info = {
  instance_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  name = "Example Voice Test Case via CLI"
  region = "us-east-1"
}
```

## Validation

The `create-test-case.sh` script performs the following validations:

- ✓ All required environment variables are set
- ✓ Instance ID is in valid UUID format
- ✓ Flow ID is in valid UUID format
- ✓ Content file path starts with `file://`
- ✓ Content file exists
- ✓ Content file is valid JSON

## Test Flow Scripts

Test flow scripts are stored in the `test-flow-scripts/` directory and must be valid JSON files following the Amazon Connect flow format.

### Example Flow Script Structure

```json
{
  "Version": "2019-10-30",
  "Metadata": {
    "entryPointPosition": { "x": 40, "y": 40 },
    "ActionMetadata": { ... }
  },
  "Actions": [ ... ]
}
```

## Troubleshooting

### Error: "Required environment variable not set"
Ensure all required variables are defined in your `terraform.tfvars` file.

### Error: "INSTANCE_ID must be a valid UUID format"
Verify that your instance ID follows the UUID format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

### Error: "Content file is not valid JSON"
Validate your flow script JSON using:
```bash
jq empty test-flow-scripts/your-file.json
```

### Error: AWS CLI authentication failed
Configure AWS CLI credentials:
```bash
aws configure
```

## Tags

All test cases are automatically tagged with:
- `ManagedBy=Terraform`

## Clean Up

To remove the resources (note: this won't delete the test case from Amazon Connect):

```bash
terraform destroy
```

## License

This project is for internal use within the Amazon Connect testing infrastructure.