# Organization Policy Management Pipeline
## Overview
You can use authorization policies in AWS Organizations to centrally configure and manage access for principals and resources in your member accounts. Service control policies (SCPs) define the maximum available permissions for the AWS Identity and Access Management (IAM) roles and users in your organization. Resource control policies (RCPs) define the maximum available permissions available for resources in your organization.

This pattern helps you to manage SCPs and RCPs as infrastructure as code (IaC) that you deploy through a continuous integration and continuous deployment (CI/CD) pipeline. By using AWS CloudFormation or Hashicorp Terraform to manage these policies, you can reduce the burden associated with building and maintaining multiple authorization policies.

This pattern includes the following features:
- You create, delete, and update the authorization policies by using manifest files (scp-management.json and rcp-management.json).
- You work with guardrails instead of policies. You define your guardrails and their targets in the manifest files.
- The pipeline, which uses AWS CodeBuild and AWS CodePipeline, merges and optimizes the guardrails in the manifest files. For each statement in the manifest file, the pipeline combines the guardrails into a single SCP or RCP and then applies it to the defined targets.
- AWS Organizations applies the policies to your targets. A target can be an AWS account, an organizational unit (OU), an environment (which is a group of accounts or OUs that you define in the environments.json file), or a group of accounts that share an AWS tag.
- Amazon Bedrock reads the pipeline logs and summarizes all policy changes.
- The pipeline requires a manual approval. The approver can review the executive summary that Amazon Bedrock prepared, which helps them understand the changes.

## Prerequisites and limitations

### Prerequisites
- Multiple AWS accounts that are managed as an organization in AWS Organizations. For more information, see Creating an organization.
- The SCP and RCP features are enabled in AWS Organizations. For more information, see Enabling a policy type.
- Terraform version 1.9.8 or later is installed
- If you are not deploying this solution through a Terraform pipeline, then the Terraform state file must be stored in an Amazon Simple Storage Service (Amazon S3) bucket in the AWS account where you are deploying the policy management pipeline.
- Python version 3.13.3 or later is installed

### Limitations
- You cannot use this pattern to manage SCPs or RCPs that were created outside of this CI/CD pipeline. However, you can recreate existing policies through the pipeline. For more information, see Migrating existing policies to the pipeline in the Additional information section of this pattern.
- The number of accounts, OUs, and policies in each account are subject to the quotas and service limits for AWS Organizations.
- This pattern cannot be used to configure management policies in AWS Organizations, such as backup policies, tag policies, chat applications policies, or declarative policies.

## Architecture
The following diagram shows the workflow of the policy management pipeline and its associated resources.

![Arquitetura](images/scp-mgmt-architecture.png)
The diagram shows the following workflow:
1. A user commits changes to the scp-management.json or rcp-management.json manifest files in the main branch of the remote repository.
2. he change to the main branch initiates the pipeline in AWS CodePipeline.
3. CodePipeline starts the Validate-Plan CodeBuild project. This project uses a Python script in the remote repository to validate policies and the policy manifest files. This CodeBuild project does the following:
- Checks that the SCP and RCP manifest files contain unique statement IDs (Sid).
- Uses the scp-policy-processor/main.py and rcp-policy-processor/main.py Python scripts to concatenate guardrails in the guardrails folder into a single RCP or SCP policy. It combines guardrails that have the same Resource, Action, and Condition.
- Uses AWS Identity and Access Management Access Analyzer to validate the final, optimized policy. If any there are any findings, the pipeline stops.
- Runs the terraform plan command, which creates a Terraform execution plan.
4. (Optional) The Validate-Plan CodeBuild project uses the bedrock-prompt/prompt.py script to send a prompt to Amazon Bedrock. You define the prompt in the bedrock-prompt/prompt.txt file. Amazon Bedrock uses Anthropic Claude Sonnet 3.5 to generate a summary of the proposed changes by analyzing the Terraform and Python logs.
5. CodePipeline uses an Amazon Simple Notification Service (Amazon SNS) topic in order to notify approvers that changes must be reviewed. If Amazon Bedrock generated a change summary, the notification includes this summary.
6. A policy approver approves the action in CodePipeline. If Amazon Bedrock generated a change summary, the approver can review the summary in CodePipeline prior to approving.
7. CodePipeline starts the Apply CodeBuild project. This project uses Terraform to apply the RCP and SCP changes in AWS Organizations.
The IaC template associated with this architecture also deploys the following resources that support the policy management pipeline:
- An Amazon S3 bucket for storing the CodePipeline artifacts and scripts, such as scp-policy-processor/main.py and bedrock-prompt/prompt.py
- An AWS Key Management Service (AWS KMS) key that encrypts the resources created by this solution