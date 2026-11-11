# DevOps Terraform and Database Reliability Assessment

## 1. Project Overview

This project demonstrates AWS infrastructure provisioning using Terraform and database reliability practices using PostgreSQL.

The assessment covers:

- AWS infrastructure design using Terraform.
- VPC with public and private subnets.
- Application Load Balancer (ALB).
- ECS Fargate application deployment.
- Private Amazon RDS PostgreSQL database.
- Separate Dev and Production environments.
- PostgreSQL query optimization.
- Database backup and restore automation.
- GitHub Actions for Terraform validation and planning.

## 2. Architecture

### AWS Architecture

```text
                  Internet
                     |
                     |
             Application Load
                 Balancer
                     |
              Public Subnets
                     |
                ECS Fargate
              Private Subnets
                     |
                     |
              Amazon RDS
               PostgreSQL
              Private Subnets
```

### Network Design

- VPC contains public and private subnets.
- Public subnets host the Application Load Balancer.
- Private application subnets host ECS Fargate tasks.
- Private database subnets host Amazon RDS.
- ECS security group allows application traffic only from the ALB security group.
- RDS security group allows PostgreSQL traffic only from the ECS security group.
- RDS is not publicly accessible.

## 3. Project Structure

```text
devops-terraform-database-assessment/
│
├── infra/
│   ├── modules/
│   │   ├── network/
│   │   ├── ecs/
│   │   └── rds/
│   │
│   └── envs/
│       ├── dev/
│       └── prod/
│
├── database/
│   ├── docker-compose.yml
│   ├── migrations/
│   │   └── 001_create_tables.sql
│   └── seed/
│       └── 002_seed_data.sql
│
├── scripts/
│   ├── backup.sh
│   └── restore.sh
│
├── backups/
│
├── .github/
│   └── workflows/
│       └── terraform.yml
│
├── .gitignore
└── README.md
```

## 4. Technologies Used

| Technology | Purpose |
|---|---|
| AWS VPC | Network isolation |
| AWS ALB | Application traffic distribution |
| AWS ECS Fargate | Container hosting |
| Amazon RDS | Managed PostgreSQL database |
| Terraform | Infrastructure as Code |
| Docker Compose | Local PostgreSQL environment |
| PostgreSQL | Relational database |
| GitHub Actions | Terraform CI checks |
| Shell Script | Database backup and restore |

## 5. Terraform Infrastructure

Terraform infrastructure is divided into reusable modules.

### Modules

- `network`: Creates VPC, subnets, route tables, NAT Gateway and security groups.
- `ecs`: Creates ECS cluster, task definition, service and ALB.
- `rds`: Creates RDS PostgreSQL, subnet group and database credentials secret.

### Dev Environment

Dev environment uses smaller resources to reduce cost.

```bash
cd infra/envs/dev

terraform init
terraform fmt -recursive
terraform validate

terraform plan -var-file="dev.tfvars"
```

### Production Environment

Production environment uses higher resource capacity and longer backup retention.

```bash
cd infra/envs/prod

terraform init
terraform fmt -recursive
terraform validate

terraform plan -var-file="prod.tfvars"
```

**Note:** This assessment requires Terraform validation and plan review. AWS deployment is not required. Do not run `terraform apply` unless you intend to create AWS resources and have reviewed the costs.

## 6. Database Setup

The local PostgreSQL database runs using Docker Compose.

### Start PostgreSQL

```bash
cd database

docker compose up -d
```

### Check Container Status

```bash
docker compose ps
```

### Connect to PostgreSQL

```bash
docker exec -it hotel-postgres \
psql -U hotel_admin -d hotel_db
```

### Verify Tables

```sql
\dt
```

Expected tables:

- hotel_bookings
- booking_events

### Verify Booking Records

```sql
SELECT COUNT(*) FROM hotel_bookings;
```

The seed script inserts 200 sample bookings across multiple cities, organizations and booking statuses.

### Verify Booking Events

```sql
SELECT COUNT(*) FROM booking_events;
```

## 7. Database Query Optimization

### Business Query

The following query retrieves booking counts and total booking amounts for each organization and status in Delhi over the last 30 days.

```sql
SELECT
    org_id,
    status,
    COUNT(*),
    SUM(amount)
FROM hotel_bookings
WHERE city = 'delhi'
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY org_id, status;
```

### Indexing Strategy

The following index supports filtering by city and creation date while including columns used by the aggregation.

```sql
CREATE INDEX idx_hotel_bookings_city_created_org_status
ON hotel_bookings (city, created_at, org_id, status)
INCLUDE (amount);
```

### Verify Query Performance

```sql
EXPLAIN ANALYZE
SELECT
    org_id,
    status,
    COUNT(*),
    SUM(amount)
FROM hotel_bookings
WHERE city = 'delhi'
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY org_id, status;
```

Review the execution plan and execution time.

For a small sample dataset, PostgreSQL may choose a sequential scan instead of the index. This is normal.

## 8. Database Backup

The backup script creates a timestamped PostgreSQL backup file.

Run:

```bash
chmod +x scripts/*.sh

./scripts/backup.sh
```

Backup files are stored in:

```text
backups/
```

Example:

```text
hotel_db_20261111_120000.dump
```

## 9. Database Restore

The restore script restores a backup into a new database.

Run:

```bash
./scripts/restore.sh
```

By default, the restore database name is:

```text
hotel_db_restore
```

You can also provide a backup file and database name:

```bash
./scripts/restore.sh backups/hotel_db_20261111_120000.dump hotel_db_test
```

### Verify Restored Database

```bash
docker exec -it hotel-postgres \
psql -U hotel_admin -d hotel_db_restore
```

Run:

```sql
\dt

SELECT COUNT(*) FROM hotel_bookings;
```

The restored database should contain the same booking records as the backup.

## 10. GitHub Actions

GitHub Actions automatically performs Terraform checks when infrastructure files are pushed or a pull request is created against the `main` branch.

The workflow performs:

1. Terraform formatting check.
2. Terraform initialization.
3. Terraform validation.
4. Terraform plan for Dev.
5. Terraform plan for Production.
6. Upload of readable plan reports as workflow artifacts.

Workflow location:

```text
.github/workflows/terraform.yml
```

Check the workflow results in the GitHub repository's **Actions** tab.

## 11. Security Considerations

- RDS is configured as private and not publicly accessible.
- RDS security group accepts PostgreSQL traffic only from ECS.
- ECS tasks run in private application subnets.
- Database credentials are stored in AWS Secrets Manager.
- Terraform state files and database backup files are excluded from Git.
- Production environment enables RDS deletion protection and longer backup retention.

Terraform state may contain sensitive values. Protect it appropriately before using this configuration in a real production environment.

## 12. Assessment Verification Checklist

| Requirement | Status |
|---|---|
| AWS architecture design | Completed |
| Terraform network module | Completed |
| Terraform ECS module | Completed |
| Terraform RDS module | Completed |
| Dev environment | Completed |
| Production environment | Completed |
| Docker Compose PostgreSQL | Completed |
| Database tables and seed data | Completed |
| Query optimization and indexing | Completed |
| Backup script | Completed |
| Restore script | Completed |
| GitHub Actions workflow | Completed |
| README documentation | Completed |

## 13. Conclusion

This project demonstrates Infrastructure as Code using Terraform, AWS network and application infrastructure design, PostgreSQL database optimization, automated backup and restore procedures, and CI validation using GitHub Actions.

The infrastructure is prepared for Terraform plan review, and the database reliability workflows can be tested locally using Docker Compose.
