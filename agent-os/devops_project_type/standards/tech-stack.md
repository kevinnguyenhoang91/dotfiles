# DevOps Tech Stack

## Context

Global DevOps tech stack defaults for Agent OS projects, overridable in project-specific `.agent-os/product/tech-stack.md`.

- Infrastructure as Code: Terraform, Ansible
- Containerization: Docker, Docker Compose
- Orchestration: Kubernetes (Digital Ocean Kubernetes Service)
- CI/CD Platform: GitHub Actions
- CI/CD Trigger: Push to main/staging branches
- Automated Testing: Integrated with CI/CD pipelines
- Monitoring & Logging: Prometheus, Grafana, Loki
- Secrets Management: HashiCorp Vault, environment variables
- Configuration Management: Ansible, dotenv files
- Cloud Provider: Digital Ocean (App Platform, Droplets, Managed PostgreSQL)
- Database Backups: Daily automated, managed via cloud provider
- Asset Storage: Amazon S3
- CDN: CloudFront
- Asset Access: Private with signed URLs
- Security: Automated vulnerability scanning, dependency updates
- Networking: VPC, firewall rules, load balancers
- Deployment Strategy: Blue/Green or Rolling deployments
- Production Environment: main branch
- Staging Environment: staging branch
- Documentation: Markdown, diagrams via Mermaid
- CI/CD Platform: GitHub Actions
- CI/CD Trigger: Push to main/staging branches
- Tests: Run before deployment
- Production Environment: main branch
- Staging Environment: staging branch
