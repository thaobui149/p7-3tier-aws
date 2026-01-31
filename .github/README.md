# Project 7 – 3-tier AWS (ALB → ECS Fargate → RDS Postgres)

## Architecture
- Public: ALB (HTTP)
- Private: ECS Fargate service
- Private: RDS Postgres
- Logs: CloudWatch Log Group
- CI/CD: GitHub Actions (OIDC) build Docker → push ECR → force new ECS deployment

## Outputs
- ALB DNS: http://p7-3tier-dev-alb-749288646.eu-central-1.elb.amazonaws.com
- ECR: 329771247218.dkr.ecr.eu-central-1.amazonaws.com/p7-3tier-dev-app
- RDS endpoint: p7-3tier-dev-db.cxgkswya624y.eu-central-1.rds.amazonaws.com
- Log group: /ecs/p7-3tier-dev

## Endpoints
- /        : hello
- /health  : health check
- /db      : DB connection test

## Test (End-to-end)
- Open /, /health, /db via ALB DNS
- Stop 1 ECS task → service self-heals, new task runs

## Deploy
- terraform init / apply
- Push code → GitHub Actions deploys to ECS (OIDC)

## Cleanup
- terraform destroy

![Architecture Diagram](docs/architecture.png)
