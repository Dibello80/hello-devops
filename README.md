
# Hello DevOps AWS CI/CD Portfolio Project

A hands-on DevOps project demonstrating automated Java application delivery, Infrastructure as Code, monitoring, and secure HTTPS hosting on AWS.

## Live Application

https://devops.dibellointeractive.com/

## Technology Stack

- Java 21 and Spring Boot
- Apache Maven
- Docker and GitHub Container Registry (GHCR)
- GitHub Actions
- Amazon EC2 (Amazon Linux 2023)
- AWS Systems Manager (SSM)
- Terraform with Amazon S3 remote state
- AWS IAM and GitHub OIDC
- Nginx reverse proxy
- Let's Encrypt and Certbot
- Amazon CloudWatch Logs and Alarms
- Amazon SNS email notifications

## Architecture

```text
Developer
    |
    v
GitHub Repository
    |
    v
GitHub Actions (CI/CD)
    |-- Build and test Java application
    |-- Build Docker image
    |-- Publish to GHCR
    |-- Authenticate to AWS with OIDC
    |-- Deploy to EC2 through SSM
    |-- Verify application health
    |
    v
Amazon EC2
    |
    +-- Nginx :443 (HTTPS)
    |       |
    |       v
    |   Docker :127.0.0.1:8080
    |       |
    |       v
    |   Spring Boot
    |
    +-- CloudWatch Logs
    +-- CloudWatch CPU Alarm
             |
             v
          Amazon SNS
             |
             v
       Email Notification

Terraform manages AWS infrastructure
using remote state stored in Amazon S3.
```

## Continuous Integration and Deployment

The Java workflow is defined in `.github/workflows/ci.yml`.

On relevant pushes to `main`, it:

1. Checks out the source code.
2. Installs Java 21.
3. Builds and tests with Maven.
4. Creates a Docker image.
5. Pushes the image to GHCR.
6. Assumes an AWS IAM role through GitHub OIDC.
7. Uses AWS SSM to run the deployment script on EC2.
8. Verifies the application responds over HTTPS.

Pull requests run build and validation checks without deploying.

## Deployment and Rollback

The deployment script is stored in `deploy/deploy.sh`.

It records the existing Docker image ID, pulls the latest image, and attempts to deploy it.

If deployment or local application health validation fails, the script attempts to restore the previous image.

Rollback is a recovery mechanism, not a guarantee of zero downtime. Automatic rollback was successfully validated using an isolated test container and

an intentionally unhealthy Docker image.

## Infrastructure as Code

Terraform files are stored in `terraform/`.

Terraform manages the EC2 instance, Elastic IP, HTTPS security-group rule, CloudWatch resources, and SNS notification infrastructure.

Terraform uses:

- Amazon S3 remote state
- S3 state locking
- A dedicated GitHub OIDC role for read-only infrastructure planning

The Terraform GitHub Actions workflow validates formatting and configuration and runs plans against AWS infrastructure.

## Security

Security controls include:

- HTTPS using Let's Encrypt certificates
- Automated TLS certificate renewal
- HTTP-to-HTTPS redirection
- Restricted SSH access
- Docker bound to localhost
- GitHub OIDC instead of static AWS credentials
- AWS Systems Manager for remote deployment
- IAM roles for EC2 and GitHub Actions
- Terraform state stored outside the Git repository

## Monitoring

Application logs are sent to Amazon CloudWatch Logs.

The CloudWatch log group is configured with seven-day retention.

A CloudWatch alarm monitors average EC2 CPU utilization and enters ALARM when utilization exceeds 70% for two consecutive five-minute periods.

Amazon SNS sends email notifications when the CPU alarm enters the ALARM state.

## Running Locally

Requirements:

- Java 21
- Docker
- Git

Build the application:

```bash
./mvnw clean package
```

Build the Docker image:

```bash
docker build -t hello-devops .
```

Run locally:

```bash
docker run --rm -p 8080:8080 hello-devops
```

Open:

http://localhost:8080/

## Repository Structure

```text
.github/workflows/   GitHub Actions CI/CD and Terraform workflows
src/                 Java Spring Boot source code
terraform/           AWS infrastructure configuration
deploy/deploy.sh     Application deployment and rollback script
nginx/devops.conf    Nginx HTTPS reverse-proxy configuration
Dockerfile           Docker image definition
pom.xml              Maven configuration
README.md            Project documentation
```

## Troubleshooting

### Application unavailable

Check the container status, Nginx service, and application logs.

### CI/CD deployment fails

Inspect the GitHub Actions run and the AWS Systems Manager command output.

### Terraform plan fails

Check AWS OIDC permissions, Terraform validation, and S3 state access.

### HTTPS certificate renewal fails

Inspect Certbot logs and test renewal using:

```bash
sudo certbot renew --dry-run --no-random-sleep-on-renew
```

### Monitoring alerts not received

Check the CloudWatch alarm action, SNS subscription confirmation, and email delivery.

## Project Status

The application is deployed and accessible over HTTPS, and the CI/CD, Terraform, and monitoring workflows have been verified.

Remaining validation includes deliberate rollback failure testing and final operational checks.
