These are notes taken while setting up AWS through the UI while I figure out the configuration I want to automate in the future.

# AWS Aurora PostgreSQL

A key feature of the application is continuously updated listening activity, this means database queries every 15 minutes or so on a continuous bases. This makes serverless less cost effective. Therefore, I went with the cheapest persistent database I could find on AWS.

https://us-west-2.console.aws.amazon.com/rds/home?region=us-west-2#

```text
>Click: Create Database
Creation method: Standard create
Configuration: PostgreSQL
Engine Version: PostgreSQL 16.3-R2
Template: Dev/Test
Availability and durability: Single DB Instance
DB instance identifier: mixtapestudy-1
Master username: ***
Credentials management: Managed in AWS Secrets Manager
Select the encryption key: aws/secretsmanager
Storage type: gp2
Allocated storage: 20GB ($2.30)
Enable storage autoscaling: True
Maximum storage threshold: 60 GiB ($7)
Compute resource: Connect to an EC2 compute resource
    - Sets up security group policies I think
EC2 Instance: Selected the one created below
DB subnet group: Automatic setup
Public access: No
VPC security group: Create new
New VPC security group name: mixtapestudy-1
Certificate authority: (default)
Database authentication: Password authentication
Turn on Preformance insights: false
```

| Instance                  | On Demand / HR | On Demand / Month | Res 1 Year / Month | Res 3 Year / Month |
| ------------------------- | -------------- | ----------------- | ------------------ | ------------------ |
| **Postgres db.t4g.micro** | 0.016          | $12               |  $8                | **$6** <-- This    |
| Postgres db.t4g.small     | 0.032          | $24               |  $16               | $12                |


# AWS EC2

Originally, I considered Fargate ECS but given the regular calls to collect listening activity, the instances would be running constantly and the savings on idle time would be minimal. So, instead, I'm going to run a docker-compose stack on an EC2 instance so that it's as similar as possible to my preferred dev environment. Of course this has scaling limitations but it's cost effective and it means that if/when I move to Fargate that path will be a little easier.

```text
>Click: Create instance
AMI: Amazon Linux 2023 AMI
Architecture: 64-bit (Arm)
Instance type: t4g.small
Key Pair: Created new pair
Firewall: Create security group
Allow SSH Traffic from: Anywhere
Allow HTTPS Traffic from the internet: False (Planning to use an ALB for this)
Allow HTTP traffic from the internet: False
Configure storage: 1x8 GiB gp3
```

| Instance      | On Demand / HR | On Demand / Month | Res 1 Year / Month | Res 3 Year / Month |
| ------------- | -------------- | ----------------- | ------------------ | ------------------ |
| t4g.nano      | 0.0042         | $3.20             | $2                 |                    |
| t4g.micro     | 0.0058         | $4                | $4                 |                    |
| **t4g.small** | 0.0168         | $12               | $8                 | **$5** <-- This    |


# ALB


