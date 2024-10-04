These are notes taken while setting up AWS through the UI while I figure out the configuration I want to automate in the future.

# AWS Aurora PostgreSQL

A key feature of the application is continuously updated listening activity, this means database queries every 15 minutes or so on a continuous bases. This makes serverless less cost effective. Therefore, I went with the cheapest persistent database I could find on AWS.

https://us-west-2.console.aws.amazon.com/rds/home?region=us-west-2#

```text
>Click: Create Database
Creation method: Standard create
Configuration: Aurora (PostreSQL Compatible)
Version: Aurora PostrgreSQL (Compatible with PostgreSQL 15.4) - default for 15
Template: Dev/Test
DB Cluster identifier: mixtapestudy-1
Master username: ***
Credentials management: Managed in AWS Secrets Manager
Select the encryption key: aws/secretsmanager
Cluster storage configuration: Aurora Standard
Instance configuration: Serverless v2
    Minimum capacity (ACUs)
    Maximum capcity (ACUs)
```

| Instance                  | On Demand / HR | On Demand / Month | Res 1 Year / Month | Res 3 Year / Month |
| ------------------------- | -------------- | ----------------- | ------------------ | ------------------ |
| Postgres db.t4g.micro     | 0.016          | $12               |  $8                | $6                 |
| Postgres db.t4g.small     | 0.032          | $24               |  $16               | $12                |


# AWS EC2

Originally, I considered Fargate ECS but given the regular calls to collect listening activity, the instances would be running constantly and the savings on idle time would be minimal.

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


