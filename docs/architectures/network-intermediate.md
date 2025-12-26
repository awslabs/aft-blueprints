# Intermediate Network Architecture

![Intermediate network diagram](../static/aws-network-architecture-intermediate.jpg)

## Overview

The Intermediate Network architecture provides a scalable, multi-account networking foundation using AWS Transit Gateway as the central connectivity hub. This design enables secure communication between workload accounts while maintaining network segmentation and centralized traffic control.

## Architecture Components

### Network Account (Hub)

**Transit Gateway**
- **Purpose**: Central routing hub for inter-VPC and cross-account connectivity
- **Configuration**: Regional Transit Gateway with multiple route tables for traffic segmentation
- **CIDR Management**: Centralized IP address space allocation (10.20.0.0/16)

**Route Table Strategy**
- **Security TGW Route Table**: Controls traffic flow for security services and inspection
- **Prod TGW Route Table**: Production workload traffic routing with strict access controls
- **Stage TGW Route Table**: Staging environment traffic isolation
- **Dev TGW Route Table**: Development environment with relaxed routing policies
- **Shared TGW Route Table**: Common services and shared resource access

**Centralized Egress**
- **Egress VPC**: Dedicated VPC for internet-bound traffic with centralized NAT Gateway
- **Inspection Points**: Optional firewall integration for deep packet inspection
- **Cost Optimization**: Single internet gateway and NAT gateway for multiple accounts

### Spoke Account Architecture

**Multi-Tier VPC Design**
- **Public Subnets**: Internet-facing resources with direct internet gateway access
- **Private Subnets**: Application tier with Transit Gateway connectivity
- **Data Subnets**: Database tier with restricted access patterns

**Cross-Account Connectivity**
- **TGW Attachments**: VPC attachments to Transit Gateway for cross-account communication
- **Route Propagation**: Automated route advertisement between spoke VPCs
- **Security Groups**: Cross-account security group references for granular access control

### Traffic Flow Patterns

**Inbound Traffic**
- Internet → Internet Gateway → Public Subnets → Application Load Balancer → Private Subnets
- VPC Endpoints for AWS services to avoid internet routing

**Outbound Traffic**
- Private Subnets → Transit Gateway → Centralized Egress VPC → NAT Gateway → Internet
- Blackhole routes for restricted traffic patterns

**Internal Traffic**
- Cross-account communication via Transit Gateway route tables
- Environment-specific routing (Prod, Stage, Dev isolation)
- Shared services access through dedicated route table

**Private Link Traffic**
- VPC Endpoints for AWS services within each spoke account
- Centralized endpoint sharing for cost optimization

## Security Implementation

### Network Segmentation

**Environment Isolation**
- Production, Staging, and Development traffic separation
- Dedicated route tables preventing cross-environment communication
- Security group rules enforcing least-privilege access

**Traffic Inspection**
- Centralized egress point for security scanning
- VPC Flow Logs enabled across all VPCs
- Route 53 Resolver for DNS query logging

### Access Control

**Security Groups**
- Cross-account security group references
- Application-specific access patterns
- Database tier isolation with private subnets

**Network ACLs**
- Subnet-level traffic filtering
- Defense-in-depth security controls
- Compliance requirement enforcement

## Shared Services Integration

**Centralized Services Account**
- Shared application services accessible via Transit Gateway
- Common utilities and tools deployment
- Cost-effective resource sharing across environments

**DNS Resolution**
- Route 53 private hosted zones shared across accounts
- Centralized DNS management and resolution
- Hybrid connectivity for on-premises integration

## Scalability and Performance

**Multi-Region Support**
- Regional Transit Gateway deployment
- Cross-region peering for disaster recovery
- Latency optimization through regional resource placement

**Bandwidth Management**
- Transit Gateway bandwidth allocation per attachment
- Traffic engineering through route table manipulation
- Performance monitoring and optimization

## Cost Optimization

**Centralized NAT Gateway**
- Single NAT Gateway serving multiple accounts
- Reduced data processing charges
- Simplified egress traffic management

**VPC Endpoint Strategy**
- Shared VPC endpoints for common AWS services
- Reduced data transfer costs
- Improved security posture

This intermediate network architecture provides a balance between complexity and functionality, offering centralized management while maintaining account-level isolation and security controls.
