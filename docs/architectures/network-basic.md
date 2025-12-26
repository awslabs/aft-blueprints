# Basic Network Architecture

![Basic network diagram](../static/aws-network-architecture-basic.jpg)

## Overview

The Basic Network architecture provides a simplified, cost-effective networking foundation for organizations beginning their AWS journey. This design implements essential networking components with Transit Gateway as the central hub, enabling secure connectivity between workload accounts while maintaining operational simplicity.

## Architecture Components

### Network Account (Central Hub)

**Transit Gateway Configuration**
- **Regional Transit Gateway**: Single Transit Gateway serving as the central connectivity hub
- **CIDR Management**: Centralized IP address space allocation (10.10.0.0/16)
- **Route Table Strategy**: Simplified routing with environment-based segmentation

**Route Table Design**
- **Prod TGW Route Table**: Production workload traffic routing with strict access controls
- **Stage TGW Route Table**: Staging environment traffic isolation
- **Dev TGW Route Table**: Development environment with relaxed routing policies
- **Security TGW Route Table**: Security services and inspection traffic management
- **Shared TGW Route Table**: Common services and shared resource access

**Centralized Egress**
- **Egress VPC**: Dedicated VPC for internet-bound traffic with single NAT Gateway
- **Internet Gateway**: Centralized internet access point for all accounts
- **Cost Optimization**: Single egress point reducing NAT Gateway costs across the organization

### Spoke Account Architecture

**Simplified VPC Design**
- **Production Spoke Account**: Production workloads with high availability and security
- **Stage Spoke Account**: Pre-production testing environment
- **Development Spoke Account**: Development and testing workloads
- **Shared Services Account**: Common services and utilities

**Standard Components per Spoke**
- **Public Subnets**: Internet-facing resources with Application Load Balancer
- **Private Subnets**: Application tier with EC2 instances and containers
- **Data Subnets**: Database tier with RDS instances
- **WAF Integration**: Web Application Firewall for application protection

### Traffic Flow Management

**Inbound Traffic**
- Internet → Internet Gateway → Public Subnets → Application Load Balancer → Private Subnets
- Direct internet access for public-facing resources

**Outbound Traffic**
- Private Subnets → Transit Gateway → Centralized Egress VPC → NAT Gateway → Internet
- Centralized egress for cost optimization and security control

**Internal Traffic**
- Cross-account communication via Transit Gateway route tables
- Environment-specific routing preventing unauthorized access
- Shared services access through dedicated route table

**Private Link Traffic**
- VPC Endpoints for AWS services within each spoke account
- Reduced data transfer costs and improved security posture

## Route Table Configuration

### Production Route Table
- **Destination**: Production VPCs
- **Target**: Propagated routes to production resources
- **Restrictions**: Limited access to development and staging environments

### Staging Route Table
- **Destination**: Staging VPCs
- **Target**: Propagated routes to staging resources
- **Access**: Controlled access to shared services and production (read-only)

### Development Route Table
- **Destination**: Development VPCs
- **Target**: Propagated routes to development resources
- **Flexibility**: Broader access for development and testing activities

### Security Route Table
- **Destination**: All VPCs requiring security inspection
- **Target**: Propagated routes through security services
- **Inspection**: Traffic routed through security appliances when required

### Shared Route Table
- **Destination**: Shared services and common resources
- **Target**: Propagated routes to shared infrastructure
- **Access**: Available to all environments with appropriate controls

## Security Implementation

### Network Segmentation

**Environment Isolation**
- Production, staging, and development traffic separation
- Route table-based access control preventing cross-environment communication
- Security group rules enforcing application-specific access patterns

**Centralized Security Controls**
- Single egress point for internet-bound traffic monitoring
- Centralized logging and monitoring through shared services
- Consistent security policy enforcement across all accounts

### Access Control

**Security Groups**
- Environment-specific security group configurations
- Cross-account security group references for shared services
- Application-tier isolation with database access controls

**Network ACLs**
- Subnet-level traffic filtering for additional security layers
- Compliance requirement enforcement at the network level
- Defense-in-depth security architecture

## Operational Simplicity

### Simplified Management

**Centralized Routing**
- Single Transit Gateway for all inter-account connectivity
- Simplified route table management with clear environment separation
- Reduced operational complexity compared to advanced architectures

**Standardized Deployments**
- Consistent VPC architecture across all spoke accounts
- Standardized security group and NACL configurations
- Simplified troubleshooting and maintenance procedures

### Cost Optimization

**Resource Sharing**
- Single NAT Gateway serving multiple accounts
- Centralized internet gateway reducing per-account costs
- Shared VPC endpoints for common AWS services

**Efficient Routing**
- Direct routing between accounts through Transit Gateway
- Minimized data transfer costs through optimized routing
- Cost-effective architecture for small to medium organizations

## Scalability Considerations

### Growth Path

**Account Expansion**
- Easy addition of new spoke accounts with standardized configurations
- Scalable route table design supporting additional environments
- Consistent security and networking patterns across new accounts

**Service Integration**
- Foundation for adding advanced services (inspection, monitoring)
- Upgrade path to intermediate and advanced network architectures
- Modular design supporting incremental capability additions

### Performance Optimization

**Bandwidth Management**
- Transit Gateway bandwidth allocation per attachment
- Performance monitoring through CloudWatch metrics
- Capacity planning for growing traffic volumes

**Latency Optimization**
- Regional deployment minimizing cross-region traffic
- Direct routing paths between frequently communicating services
- Performance monitoring and optimization recommendations

## Monitoring and Troubleshooting

### Network Visibility

**VPC Flow Logs**
- Flow logs enabled on all VPCs for traffic analysis
- Centralized log aggregation for organization-wide visibility
- Security monitoring and anomaly detection capabilities

**CloudWatch Integration**
- Network performance metrics and monitoring
- Automated alerting for connectivity issues
- Operational dashboards for network health visibility

### Troubleshooting Tools

**Route Analysis**
- Transit Gateway route table analysis tools
- Network path troubleshooting capabilities
- Connectivity testing and validation procedures

**Performance Monitoring**
- Network latency and throughput monitoring
- Capacity utilization tracking and alerting
- Performance optimization recommendations

This basic network architecture provides a solid foundation for organizations starting their AWS journey, offering essential networking capabilities with operational simplicity and cost-effectiveness while maintaining a clear upgrade path to more advanced architectures.
