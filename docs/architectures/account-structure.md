# AWS Organizations OU and Account Structure

![AWS Organizations diagram](../static/aws-org-account-structure.jpg)

## Overview

This document provides a comprehensive technical description of the AWS Organizations Organizational Unit (OU) and account structure designed for enterprise-scale AWS Control Tower deployments with Account Factory for Terraform (AFT) integration.

## Architecture Components

### Root Organization Structure

The architecture is built on AWS Organizations with a hierarchical structure rooted at the **AWS Management Account**. The organization implements a multi-OU design pattern that segregates accounts based on their functional purpose, security requirements, and operational characteristics.

### Organizational Unit Hierarchy

#### Core Foundational OUs

**Security OU**
- **Purpose**: Houses security-focused accounts that provide centralized security services
- **Key Accounts**:
  - `aws-audit`: Centralized audit and compliance account for AWS CloudTrail, AWS Config, and security monitoring
  - `aws-log-archive`: Centralized logging repository for organization-wide log aggregation and retention

**AFT OU**
- **Purpose**: Contains Account Factory for Terraform management infrastructure
- **Key Accounts**:
  - `aws-aft-management`: AFT control plane account managing account provisioning and customizations

**Infrastructure OU**
- **Purpose**: Provides shared infrastructure services across the organization
- **Key Accounts**:
  - `aws-network`: Centralized networking hub for Transit Gateway, Direct Connect, and VPC management
  - `aws-identity`: Identity and access management services including AWS SSO/Identity Center
  - `aws-backup`: Centralized backup and disaster recovery services
  - `aws-operations`: Operational tooling and monitoring infrastructure
  - `aws-shared-services`: Shared application services and common utilities
  - `aws-monitoring`: Centralized monitoring, alerting, and observability platform

#### Workload OUs

**Workloads OU**
- **Purpose**: Primary container for application workload accounts
- **Structure**: Implements a three-tier environment model:
  - **Production OU**: Production workload accounts (`aws-app-001-prod`, `aws-app-00n-prod`)
  - **Development OU**: Development and testing accounts (`aws-app-001-dev`, `aws-app-00n-dev`)
  - **Staging OU**: Pre-production staging accounts (`aws-app-001-stg`, `aws-app-00n-stg`)

#### Specialized OUs

**Sandbox OU**
- **Purpose**: Isolated environment for experimentation and learning
- **Characteristics**: Relaxed governance controls, temporary resource provisioning

**Policy Staging OU**
- **Purpose**: Testing ground for Service Control Policies (SCPs) before organization-wide deployment
- **Function**: Validates policy impacts in controlled environment

**Individual Business Users OU**
- **Purpose**: Personal development accounts for individual contributors
- **Use Case**: Developer sandbox environments with limited resource quotas

**Suspended OU**
- **Purpose**: Container for decommissioned or temporarily disabled accounts
- **Security**: Restrictive SCPs preventing resource creation and access

**Exceptions OU**
- **Purpose**: Accounts requiring non-standard governance or compliance exemptions
- **Management**: Special approval processes and enhanced monitoring

**Deployments OU**
- **Purpose**: CI/CD pipeline accounts and deployment automation infrastructure
- **Integration**: Cross-account deployment roles and pipeline orchestration

**Transactional OU**
- **Purpose**: Accounts for transactional workloads requiring specific compliance or performance characteristics
- **Examples**: Payment processing, high-frequency trading systems

**Business Continuity OU**
- **Purpose**: Disaster recovery and business continuity infrastructure
- **Components**: Backup regions, failover systems, and recovery testing environments

## Technical Implementation Details

### Account Naming Convention

The architecture implements a standardized naming convention:
- **Format**: `aws-<service>-<identifier>-<environment>`
- **Examples**: 
  - `aws-app-001-prod` (Application 001 Production)
  - `aws-app-001-dev` (Application 001 Development)
  - `aws-app-001-stg` (Application 001 Staging)

### Service Control Policies (SCPs)

Each OU implements tailored SCPs based on:
- **Security requirements**: Data classification and access controls
- **Compliance needs**: Industry-specific regulations (SOX, PCI-DSS, HIPAA)
- **Operational constraints**: Resource limits, region restrictions, service permissions

### Cross-Account Integration

The structure enables:
- **Centralized logging**: All accounts forward logs to `aws-log-archive`
- **Unified monitoring**: Metrics aggregation in `aws-monitoring`
- **Shared networking**: Transit Gateway connectivity through `aws-network`
- **Identity federation**: Centralized access management via `aws-identity`

### AFT Integration Points

The AFT OU integrates with:
- **Account provisioning**: Automated account creation and baseline configuration
- **Customization deployment**: Terraform-based account customizations
- **Compliance enforcement**: Automated policy and configuration drift detection

## Security and Governance

### Defense in Depth

- **OU-level controls**: SCPs providing guardrails at organizational boundaries
- **Account-level isolation**: Individual account boundaries for workload separation
- **Resource-level permissions**: IAM policies and resource-based policies

### Compliance Framework

- **Audit trail**: Centralized CloudTrail in `aws-audit` account
- **Configuration monitoring**: AWS Config rules across all accounts
- **Access logging**: Comprehensive access patterns and privilege usage tracking

### Network Security

- **Centralized egress**: Internet gateway and NAT gateway management
- **Inspection points**: Traffic filtering and deep packet inspection
- **Segmentation**: Network-level isolation between environments and workloads

This organizational structure provides a scalable, secure, and compliant foundation for enterprise AWS deployments, enabling both centralized governance and distributed workload management through the AFT framework.
