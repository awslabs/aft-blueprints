# Manage AWS Organizations policies as code by using AWS CodePipeline and Amazon Bedrock
## Overview
You can use authorization policies in AWS Organizations to centrally configure and manage access for principals and resources in your member accounts. [Service control policies (SCPs)](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html) define the maximum available permissions for the AWS Identity and Access Management (IAM) roles and users in your organization. [Resource control policies (RCPs)](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_rcps.html) define the maximum available permissions available for resources in your organization.

This pattern helps you to manage SCPs and RCPs as infrastructure as code (IaC) that you deploy through a continuous integration and continuous deployment (CI/CD) pipeline. By using AWS CloudFormation or Hashicorp Terraform to manage these policies, you can reduce the burden associated with building and maintaining multiple authorization policies.

This pattern includes the following features:
- You create, delete, and update the authorization policies by using manifest files (scp-management.json and rcp-management.json).
- You work with guardrails instead of policies. You define your guardrails and their targets in the manifest files.
- The pipeline, which uses AWS CodeBuild and AWS CodePipeline, merges and optimizes the guardrails in the manifest files. For each statement in the manifest file, the pipeline combines the guardrails into a single SCP or RCP and then applies it to the defined targets.
- AWS Organizations applies the policies to your targets. A target can be an AWS account, an organizational unit (OU), an environment (which is a group of accounts or OUs that you define in the environments.json file), or a group of accounts that share an [AWS tag](https://docs.aws.amazon.com/whitepapers/latest/tagging-best-practices/what-are-tags.html).
- Amazon Bedrock reads the pipeline logs and summarizes all policy changes.
- The pipeline requires a manual approval. The approver can review the executive summary that Amazon Bedrock prepared, which helps them understand the changes.

![Architecture](https://docs.aws.amazon.com/images/prescriptive-guidance/latest/patterns/images/pattern-img/372a1ace-5b2e-4f93-9f88-b5b0519ded48/images/a2cceb99-2b93-48e0-b072-bc61a572201f.png)

For prerequisites and instructions for using this AWS Prescriptive Guidance pattern, see [Manage AWS Organizations policies as code by using AWS CodePipeline and Amazon Bedrock](https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/manage-organizations-policies-as-code.html).