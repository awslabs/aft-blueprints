# Frequently Asked Questions

### What is AFT Blueprints and how can I leverage it for my organization?

AFT Blueprints provides a collection of pre-defined architectural patterns for [AWS Control Tower](https://docs.aws.amazon.com/controltower/latest/userguide/what-is-control-tower.html) landing zones using [Account Factory for Terraform](https://docs.aws.amazon.com/controltower/latest/userguide/aft-overview.html) (AFT). You can either copy pattern content into your own AFT repositories as a starting point, or use them as reference guides to build custom patterns tailored to your organization's needs.

### What prerequisites must be in place before implementing AFT Blueprints?

You need an AWS account with [AWS Organizations](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_introduction.html) with [all features](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_org_support-all-features.html) enabled, [AWS Control Tower](https://docs.aws.amazon.com/controltower/latest/userguide/what-is-control-tower.html), and [AWS IAM Identity Center](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html) set up. Additionally, you need a dedicated AWS account within the same organization to deploy and manage AFT, plus [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) and [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) installed locally.

### What are the options for bootstrapping AFT?

You have three options:

1. Use the [**aft-bootstrap-pipeline**](https://github.com/aws-samples/aft-bootstrap-pipeline). See the [implementation guide](https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/implement-account-factory-for-terraform-aft-by-using-a-bootstrap-pipeline.html).
2. Follow the steps in the [AWS Control Tower Guide workshop](https://catalog.workshops.aws/control-tower/en-US/customization/aft/deploy).
3. Follow the [Deploy AWS Control Tower Account Factory for Terraform (AFT)](https://docs.aws.amazon.com/controltower/latest/userguide/aft-getting-started.html) guide in the AWS Control Tower documentation.

### Which architectural patterns are available in AFT Blueprints?

AFT Blueprints offers three main patterns:

1. [Single Region Basic](./patterns/single-region-basic.md) - A foundational cloud architecture in a single AWS Region
2. [Multi Region Basic](./patterns/multi-region-basic.md) - Extends the basic pattern across multiple AWS Regions
3. [Multi Region Advanced](./patterns/multi-region-advanced.md) - Adds advanced networking features like centralized inspection

Each pattern provides different components and architectures with varying complexity and cost implications.

### Which core accounts are needed for implementing AFT Blueprints?

The required accounts are:

1. Control Tower shared accounts - [Log Archive and Security Tooling](https://docs.aws.amazon.com/controltower/latest/userguide/accounts.html)
2. Network account - For centralized network management and [AWS VPC IP Address Manager](https://docs.aws.amazon.com/whitepapers/latest/ec2-networking-for-telecom/vpc-ip-address-manager-ipam.html) (IPAM)
3. Backup account - For centralized [AWS Backup](https://docs.aws.amazon.com/aws-backup/latest/devguide/whatisbackup.html) management
4. Identity account - For [AWS IAM Identity Center](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html) and [IAM Access Analyzer](https://docs.aws.amazon.com/IAM/latest/UserGuide/what-is-access-analyzer.html)

These accounts serve as centralized hubs for their respective functions within the organization.

### Can I modify the blueprints to meet my organization's specific requirements?

Yes, the patterns are provided as examples and are meant to be modified after cloning the repository. As stated in the [README](https://github.com/awslabs/aft-blueprints/blob/main/README.md): "You are free to customize the provided patterns to meet their specific needs" and "The code in this repository is provided as an example only, and is not intended for production use."

### Can I run the AFT customization terraform code locally?

Yes, you can use the [**aft-local.sh**](https://github.com/awslabs/aft-blueprints/tree/main/assets/aft-local) script available in this repository.
