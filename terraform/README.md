# NimbusKart Cost Janitor & Cloud Automation

This repository contains the automated infrastructure baseline and FinOps cost optimization tools developed for the NimbusKart cloud environment. The project is designed to automatically detect cloud waste patterns, estimate monthly loss in USD, and execute continuous audits via automated pipelines.

## 🏗️ Part A: Infrastructure-as-Code Baseline
The staging environment is managed entirely via Terraform and deployed locally utilizing LocalStack to mirror core AWS services.
* **VPC Architecture**: A dual-Availability Zone public network topology (`10.20.1.0/24` and `10.20.2.0/24`).
* **Compute Cluster**: Multiple `t3.micro` EC2 instances simulating active application tiers.
* **Storage Optimization**: Dedicated S3 logging bucket equipped with automated 30-day non-current version retention policies.
* **Target Environment**: An intentional 10 GB unattached EBS storage volume was deployed to validate waste-detection mechanisms.

## 🐍 Part B: FinOps Cost Janitor
A Python automation suite engineered leveraging `boto3` to parse running inventory and isolate financial leakages.
* **Orphan Detection**: Locates unattached storage volumes and calculates financial impact using fixed pricing metrics ($0.08/GB-month).
* **Tag Governance**: Scans and surfaces any active cluster components completely missing required metadata (`Project`, `Environment`, `Owner`).
* **Reporting Output**: Compiles live execution statistics directly into a standardized audit summary at `samples/cost_waste_report.json`.

## 🚀 Part C: Continuous Integration Pipeline
Automated orchestration is configured via GitHub Actions (`.github/workflows/cost-janitor.yml`).
* **Trigger Mechanics**: Schedules an audit autonomously every 24 hours at midnight UTC or allows immediate interactive executions via user-driven UI dispatches.
* **Artifact Retention**: Packages and uploads validated JSON cost tracking sheets onto the workflow timeline for managerial visibility.
