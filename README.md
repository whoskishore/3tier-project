# 🚀 AWS Three-Tier Architecture Project

## 📌 Project Overview

This project demonstrates the design and implementation of a three-tier web application architecture on Amazon Web Services (AWS).

The architecture separates the application into three layers: the Presentation Tier, Application Tier, and Database Tier. It uses Amazon VPC, six subnets, EC2 instances, Application Load Balancers, Target Groups, and Amazon RDS for MariaDB to build a structured and secure cloud environment.

The primary goal is to understand AWS networking, load balancing, application deployment, database integration, and cloud security.

---

## 🏗️ Architecture Overview

The project consists of three tiers:

1. **Presentation Tier:** Hosts the frontend website on an EC2 instance running Apache HTTP Server.
2. **Application Tier:** Hosts the backend application on a separate EC2 instance and handles API requests on TCP port 5000.
3. **Database Tier:** Uses Amazon RDS for MariaDB to store and manage application data.

Users access the frontend through a public-facing Application Load Balancer. The frontend communicates with the backend through a separate Application Load Balancer, which forwards requests to the application server.

The application server connects to the RDS database through the private network.

---

## ☁️ AWS Services Used

| AWS Service | Purpose |
|---|---|
| Amazon VPC | Creates an isolated virtual network |
| Public Subnets | Host internet-facing load balancers |
| Private Subnets | Host application servers and database resources |
| Amazon EC2 | Runs frontend and backend applications |
| Application Load Balancer | Distributes incoming HTTP/HTTPS traffic |
| Target Groups | Route traffic to registered EC2 instances |
| Amazon RDS for MariaDB | Provides a managed relational database |
| Security Groups | Control inbound and outbound traffic |
| Internet Gateway | Enables internet connectivity for public subnets |
| NAT Gateway | Enables outbound internet access from private subnets |
| Amazon Route Tables | Control network traffic routing |
| MySQL Client | Connects to and manages the MariaDB database |

---

## 🌐 1. Amazon VPC Configuration

Create an Amazon VPC with the following configuration.

- VPC CIDR: `10.0.0.0/16`
- Total Subnets: 6
- Public Subnets: 2
- Private Subnets: 4
- Availability Zones: 2

### Subnet Configuration

| Subnet | Type | CIDR Block | Availability Zone |
|---|---|---|---|
| Public Subnet 1 | Public | `10.0.1.0/24` | ap-south-1a |
| Public Subnet 2 | Public | `10.0.2.0/24` | ap-south-1b |
| Private Subnet 1 | Private | `10.0.11.0/24` | ap-south-1a |
| Private Subnet 2 | Private | `10.0.12.0/24` | ap-south-1b |
| Private Subnet 3 | Private | `10.0.21.0/24` | ap-south-1a |
| Private Subnet 4 | Private | `10.0.22.0/24` | ap-south-1b |

### Networking Components

- Attach an Internet Gateway to the VPC.
- Configure public route tables with a route to the Internet Gateway.
- Configure private route tables as required.
- Use a NAT Gateway if private instances require outbound internet access.
- Keep application and database resources in private subnets.

---

## 🖥️ 2. EC2 Instance Configuration

Create two EC2 instances for the web and application tiers.

### Web Server EC2

**Purpose:** Hosts the frontend application.

Configuration:
- Operating System: Amazon Linux
- Web Server: Apache HTTP Server (HTTPD)
- Network: Private subnet recommended when accessed through the frontend ALB
- Incoming application traffic: From the frontend ALB security group
- Administrative access: SSH from a trusted IP or through an approved management method

### Application Server EC2

**Purpose:** Processes backend requests and communicates with the database.

Configuration:
- Operating System: Amazon Linux
- Application Port: TCP 5000
- Network: Private subnet
- Incoming application traffic: From the backend ALB security group
- Database access: To the RDS security group on TCP port 3306

---

## ⚖️ 3. Application Load Balancers

Create two Application Load Balancers to separate frontend and backend traffic.

### Frontend Load Balancer

Purpose:
- Receives incoming user requests.
- Routes HTTP/HTTPS traffic to the frontend web server.
- Provides a single public entry point for the website.

Configuration:
- Scheme: Internet-facing
- Subnets: Two public subnets
- Listener: HTTP port 80 and/or HTTPS port 443
- Target Group: Frontend target group

### Backend Load Balancer

Purpose:
- Receives API requests from the frontend.
- Forwards requests to the backend application server.

Configuration:
- Scheme: Internal
- Subnets: Two private subnets
- Listener: TCP port 5000 using an HTTP listener if the backend serves HTTP
- Target Group: Backend target group

**Note:** An Application Load Balancer uses HTTP/HTTPS listeners for application-layer routing. If your backend uses HTTP on port 5000, configure an HTTP listener on port 5000 and forward traffic to a target group using the appropriate backend port.

---

## 🎯 4. Target Groups

Create two target groups.

### Frontend Target Group

- Target Type: Instances
- Protocol: HTTP
- Port: 80
- Registered Target: Web Server EC2
- Health Check Path: `/`

### Backend Target Group

- Target Type: Instances
- Protocol: HTTP
- Port: 5000
- Registered Target: Application Server EC2
- Health Check Path: `/health` (if implemented by the backend application)

Configure the health check paths to match the endpoints actually provided by your applications.

---

## 🔐 5. Security Groups

Create five security groups to control communication between the tiers.

### Security Group 1: Frontend ALB

| Protocol | Port | Source |
|---|---|---|
| HTTP | 80 | `0.0.0.0/0` |
| HTTPS | 443 | `0.0.0.0/0` |

### Security Group 2: Web Server EC2

| Protocol | Port | Source |
|---|---|---|
| HTTP | 80 | Frontend ALB security group |
| SSH | 22 | Trusted administrator IP |

### Security Group 3: Backend ALB

| Protocol | Port | Source |
|---|---|---|
| HTTP | 5000 | Web Server security group |

### Security Group 4: Application Server EC2

| Protocol | Port | Source |
|---|---|---|
| TCP | 5000 | Backend ALB security group |
| SSH | 22 | Trusted administrator IP or management service |

### Security Group 5: RDS Database

| Protocol | Port | Source |
|---|---|---|
| MySQL/MariaDB | 3306 | Application Server security group |

**Security Best Practices:**
- Avoid opening SSH port 22 to `0.0.0.0/0`.
- Allow application traffic only from the appropriate security groups.
- Keep the database private and inaccessible directly from the internet.
- Use HTTPS for production traffic.

---

## 🗄️ 6. Amazon RDS for MariaDB

Create an Amazon RDS database using MariaDB.

Configuration:
- Engine: MariaDB
- Deployment: Single-AZ for a basic learning project, or Multi-AZ if required
- Network: Private subnets
- Public Access: No
- Port: 3306
- Security Group: RDS security group
- Database Client: MySQL-compatible client

### Database Connectivity

The application server connects to the RDS endpoint using:

- RDS endpoint
- Database name
- Database username
- Database password
- Port `3306`

Store credentials securely using an appropriate secrets-management solution rather than hardcoding them in application code or GitHub.

---

## 🔄 7. Application Workflow

1. A user opens the website using the frontend ALB DNS name.
2. The frontend ALB forwards requests to the web server target group.
3. The web server serves the frontend application.
4. The frontend sends API requests to the backend ALB.
5. The backend ALB forwards requests to the application server on port 5000.
6. The application server processes the request.
7. The application server queries Amazon RDS for MariaDB on port 3306.
8. The database returns the requested data.
9. The application server sends the response back through the backend ALB.
10. The frontend displays the result to the user.

---

## 🎯 Project Objectives

- Build a three-tier architecture using AWS.
- Understand VPC and subnet design.
- Configure public and private networking.
- Deploy web and application servers on EC2.
- Configure frontend and backend load balancers.
- Create and register target groups.
- Configure security groups for tier-to-tier communication.
- Deploy Amazon RDS for MariaDB.
- Establish secure application-to-database connectivity.
- Practise AWS troubleshooting and cloud architecture design.

---

## 📚 Skills Demonstrated

- Amazon Web Services (AWS)
- Amazon VPC
- Public and Private Subnets
- Amazon EC2
- Application Load Balancer
- Target Groups
- Amazon RDS
- MariaDB and MySQL
- Linux Administration
- Apache HTTP Server
- Security Groups
- Cloud Networking
- Git and GitHub

---

## 👨‍💻 Author

Kishore

AWS Cloud | DevOps | Linux | Cloud Architecture

---

## 📌 Project Status

Project developed for hands-on AWS cloud learning and practical understanding of three-tier architecture.
