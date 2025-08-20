# Identity Management Solutions

![Permission Set pipeline diagram](../static/aws-ps-pipeline.jpg)

## Overview

The Identity Management architecture provides an automated, event-driven system for managing AWS IAM Identity Center (formerly AWS SSO) permission sets across the organization. This solution integrates AWS Control Tower lifecycle events with a CI/CD pipeline to ensure consistent and scalable identity and access management.

## Architecture Components

### AWS Control Tower Integration

**Control Tower Account**
- **Lifecycle Events**: Automated capture of account creation and update events
- **Event Types**: 
  - `CreateManagedAccount`: New account provisioning events
  - `UpdateManagedAccount`: Account modification events
- **Event Bridge Integration**: Native integration with Amazon EventBridge for event processing

**Event Processing Flow**
1. Control Tower generates lifecycle events for account operations
2. EventBridge captures and routes events to downstream systems
3. Events trigger automated permission set provisioning workflows
4. IAM Identity Center receives delegated administration permissions

### AFT Management Account

**Account Factory for Terraform (AFT)**
- **Event Notification**: SNS topic `aft-notifications` for AFT-specific events
- **Subscription Filter**: JSON-based filtering for relevant Control Tower events
- **Lambda Integration**: `aft-new-account-forward-event` function for event processing
- **Cross-Account Communication**: Secure event forwarding to Identity Management account

**Event Filtering**
```json
{
  "Input": {
    "control_tower_event": {
      "detail": {
        "eventName": [
          "CreateManagedAccount",
          "UpdateManagedAccount"
        ]
      }
    }
  },
  "Status": ["SUCCEEDED"]
}
```

### Identity Management Account

**Event Processing Infrastructure**
- **Custom Event Bus**: `aws-ps-pipeline-PermissionSet-bus` for permission set events
- **Event Bridge Rules**: Automated routing of Control Tower lifecycle events
- **Lambda Functions**: Event processing and pipeline triggering logic
- **Cross-Account IAM Roles**: Secure access to IAM Identity Center operations

**CI/CD Pipeline Components**
- **AWS CodeCommit**: Git repository `aws-ps-pipeline` for permission set definitions
- **AWS CodePipeline**: `aws-ps-pipeline` automated deployment pipeline
- **AWS CodeBuild**: Terraform plan and apply execution environment
- **DynamoDB**: `aws-ps-pipeline-tf-backend` state management and locking

### Permission Set Management

**Infrastructure as Code**
- **Terraform Configuration**: Permission set definitions as code
- **Version Control**: Git-based change management and approval workflows
- **State Management**: Centralized Terraform state in S3 with DynamoDB locking
- **Automated Deployment**: Pipeline-driven permission set provisioning

**IAM Identity Center Integration**
- **Delegated Administration**: Identity Management account as delegated administrator
- **Permission Set Creation**: Automated creation and assignment of permission sets
- **Account Assignment**: Dynamic assignment based on account metadata and policies
- **Group Management**: Integration with identity provider groups and users

## Technical Implementation

### Event-Driven Architecture

**Event Flow Sequence**
1. **Account Creation**: Control Tower creates new managed account
2. **Event Generation**: Control Tower publishes lifecycle event to EventBridge
3. **Event Routing**: EventBridge routes event to AFT management account
4. **Event Processing**: AFT Lambda function processes and forwards event
5. **Pipeline Trigger**: Identity Management account receives event and triggers pipeline
6. **Permission Set Deployment**: CodePipeline executes Terraform to create permission sets
7. **Account Assignment**: Permission sets assigned to appropriate users and groups

**Cross-Account Security**
- **IAM Roles**: Cross-account roles with least-privilege permissions
- **Event Encryption**: Encrypted event payloads for sensitive information
- **Audit Logging**: Complete audit trail of all identity management operations

### CI/CD Pipeline Architecture

**Source Stage**
- **Repository**: AWS CodeCommit repository containing Terraform configurations
- **Branch Strategy**: Main branch for production, feature branches for development
- **Change Management**: Pull request workflow for permission set changes

**Build Stage**
- **CodeBuild Project**: Terraform plan and apply execution environment
- **Environment Variables**: Dynamic configuration based on target account
- **Artifact Management**: Terraform plans and state files as pipeline artifacts

**Deploy Stage**
- **Terraform Apply**: Automated deployment of permission set changes
- **State Management**: Centralized state storage with locking mechanisms
- **Rollback Capabilities**: Automated rollback procedures for failed deployments

### Permission Set Templates

**Standardized Permission Sets**
- **Administrative Access**: Full administrative permissions for account owners
- **Developer Access**: Development-focused permissions with guardrails
- **Read-Only Access**: Audit and monitoring permissions for compliance teams
- **Service-Specific Access**: Tailored permissions for specific AWS services

**Dynamic Assignment Logic**
- **Account Metadata**: Permission assignment based on account tags and attributes
- **Organizational Unit**: OU-based permission set assignment rules
- **User Groups**: Identity provider group mapping to AWS permission sets
- **Conditional Access**: Time-based and location-based access controls

## Security and Compliance

### Access Control

**Least Privilege Principle**
- **Granular Permissions**: Fine-grained IAM policies for specific use cases
- **Time-Limited Access**: Temporary permission elevation for specific tasks
- **Conditional Policies**: Context-aware access controls based on request attributes

**Multi-Factor Authentication**
- **MFA Enforcement**: Required MFA for all administrative operations
- **Device Management**: Centralized MFA device registration and management
- **Risk-Based Authentication**: Adaptive authentication based on risk assessment

### Audit and Compliance

**Comprehensive Logging**
- **CloudTrail Integration**: Complete audit trail of all identity operations
- **Access Logging**: Detailed logging of permission set usage and access patterns
- **Change Tracking**: Version control and approval workflow for all changes

**Compliance Reporting**
- **Access Reviews**: Automated access review and certification processes
- **Compliance Dashboards**: Real-time visibility into access patterns and compliance status
- **Regulatory Alignment**: Support for SOX, PCI-DSS, and other regulatory requirements

## Operational Excellence

### Automation and Efficiency

**Self-Service Capabilities**
- **Permission Request Workflow**: Automated approval workflow for access requests
- **Temporary Access**: Self-service temporary permission elevation
- **Access Catalog**: Standardized catalog of available permission sets and access levels

**Operational Monitoring**
- **Pipeline Health**: Monitoring and alerting for CI/CD pipeline operations
- **Permission Set Usage**: Analytics and reporting on permission set utilization
- **Performance Metrics**: SLA tracking and performance optimization

### Disaster Recovery

**Multi-Region Support**
- **Cross-Region Replication**: Permission set configuration replication across regions
- **Failover Procedures**: Automated failover for identity management operations
- **Backup and Recovery**: Regular backup of permission set configurations and assignments

**Business Continuity**
- **Emergency Access**: Break-glass procedures for emergency access scenarios
- **Offline Access**: Contingency plans for identity provider outages
- **Recovery Testing**: Regular testing of disaster recovery procedures

This identity management architecture provides a scalable, secure, and automated approach to managing access across the AWS organization while maintaining compliance and operational efficiency.
