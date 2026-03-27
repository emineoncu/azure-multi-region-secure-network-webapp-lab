# azure-multi-region-secure-network-webapp-lab
Hands-on Azure infrastructure project demonstrating secure network architecture, ARM template automation, and multi-region high availability deployment.

## Overview
Azure multi-region infrastructure deployment using ARM templates, PowerShell, App Service, Traffic Manager, NSGs, ASGs, Bastion access and failover testing.
## Architecture Diagram

![Architecture]([URL](https://github.com/emineoncu/azure-multi-region-secure-network-webapp-lab/blob/main/architecture))

## Repository Structure

```text
azure-multi-region-secure-network-webapp-lab/
├── README.md
├── architecture/
│   └── azure-network-diagram.png
├── arm-templates/
│   ├── asg/
│   │   ├── ASG.json
│   │   └── ASG.Parameters.json
│   ├── east-asia/
│   │   ├── East_Asia_vNet.json
│   │   ├── East_Asia_vNet.parameters.json
│   │   ├── East_Asia_NSG_Security_Rule.json
│   │   └── East_Asia_NSG_Security_Rule.Parameters.json
│   └── east-us/
│       ├── EUS_vNet.json
│       ├── EUS_vNet.parameters.json
│       ├── East_US_NSG_Security_Rule.json
│       └── East_US_NSG_Security_Rule.Parameters.json
├── powershell/
│   ├── Azure-Webapp.ps1
│   ├── EA-AZURE-VM-CREATE.ps1
│   ├── EA-vNet-NSG.ps1
│   ├── EA-Final.ps1
│   ├── EU-AZURE-VM-CREATE.ps1
│   ├── EU-vNet-NSG.ps1
│   └── EU_Final.ps1
└── screenshots/
```

# Azure Multi-Region Secure Infrastructure and Web Application Lab

This project demonstrates the deployment of a secure multi-region Azure infrastructure using ARM templates and PowerShell automation.

The environment includes network segmentation, application security groups, network security groups, VM deployment, and high availability web application routing.

The architecture simulates a real-world enterprise environment where infrastructure is deployed using Infrastructure-as-Code and secured using layered network controls.

---

# Architecture Overview

The environment contains two Azure regions:

- East US
- East Asia

Each region contains:

- Virtual Network
- Multiple subnets
- Network Security Groups
- Application Security Groups
- Virtual Machines
- Bastion host
- Web server
- MSSQL server

Traffic routing and high availability are handled using Azure Traffic Manager.

---

# Network Design

Each region uses a segmented network model:

DMZ Subnet  
Web Subnet  
Database Subnet  

Example CIDR ranges:

East US VNet  
10.0.0.0/16

East Asia VNet  
172.16.0.0/16

Subnets:

DMZ Subnet  
Web Subnet  
Database Subnet

This design isolates infrastructure tiers and improves security posture.

---

# Security Architecture

Security is enforced using both:

Network Security Groups (NSG)  
Application Security Groups (ASG)

Example rule flow:

Internet → Bastion Host (RDP 3389)

Bastion → Web Server (RDP)

Web Server → MSSQL Server (1433)

Direct access from DMZ to MSSQL is denied.

This enforces a controlled access path through the Bastion host.

---

# Infrastructure as Code

The infrastructure is deployed using ARM templates.

Templates include:

Application Security Groups  
Virtual Networks and Subnets  
Network Security Groups  
Security Rules

Each template uses parameter files to allow reusable deployments across regions.

---

# Automation

Deployment automation is implemented using PowerShell scripts.

Scripts handle:

Resource group creation  
Network deployment  
Security configuration  
VM provisioning  
Web application deployment  

This allows repeatable infrastructure builds.

---

# High Availability

The web application is deployed across multiple regions.

Azure Traffic Manager routes traffic based on priority and health checks.

If the primary region becomes unavailable, traffic automatically routes to the secondary region.

---

# Skills Demonstrated

Azure Networking  
Infrastructure as Code (ARM Templates)  
Network segmentation design  
Application Security Groups  
Network Security Groups  
PowerShell automation  
Multi-region architecture  
High availability routing  
Cloud troubleshooting and validation

---

# Why This Project Matters

This project demonstrates real-world cloud infrastructure skills including secure network design, infrastructure automation, and high availability deployment.

These are core skills used in roles such as:

Cloud Support Engineer  
Technical Support Engineer  
Azure Administrator  
Production Support Engineer  
Cloud Operations Engineer


    

