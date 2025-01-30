# Terraform Labs

This repository contains my personal Terraform projects and infrastructure automation labs. It serves as a hands-on environment for exploring Terraform best practices, cloud automation, and infrastructure as code (IaC).

---

## **Project Structure**
Each directory in this repository represents a separate Terraform lab or module.

### **1. AWS Infrastructure**
Terraform configurations for provisioning AWS cloud resources.

📁 **`aws/vpc`**  
- Deploys a Virtual Private Cloud (VPC) with subnets, route tables, and NAT gateways.

📁 **`aws/ec2`**  
- Launches EC2 instances with security groups, IAM roles, and autoscaling.

---

## **Requirements**
To use these Terraform configurations, ensure you have the following installed:

- [Terraform](https://developer.hashicorp.com/terraform/downloads) (latest version)
- AWS CLI (`aws configure` for authentication)
- An AWS account with necessary IAM permissions

---

## **Usage**
1. Clone the repository:
   ```bash
   git clone https://github.com/keziei/terraform-projects.git
   cd terraform-projects
