## Overview
This repository contains a production-ready cloud cost-optimization framework built for NimbusKart. It establishes an automated FinOps engine designed to proactively discover, track, and flag orphaned infrastructure resources across cloud providers. By provisioning an isolated environment with Terraform on LocalStack and combining it with a smart Python automation suite ("Cost Janitor"), this solution ensures strict cost attribution policies are continuously enforced via GitHub Actions pipelines before wasteful expenses manifest on actual cloud bills.

## How to run locally
Follow these exact steps to run the stack cleanly on your local machine:

```bash
# 1. Clone the repository
git clone [https://github.com/RehaanKhan2207/nimbuskart-cost-janitor.git](https://github.com/RehaanKhan2207/nimbuskart-cost-janitor.git)
cd nimbuskart-cost-janitor

# 2. Spin up LocalStack container
docker run --rm -d -p 4566:4566 --name localstack localstack/localstack

# 3. Setup and deploy the infrastructure stack
pip install terraform-local
tflocal init
tflocal apply -auto-approve

# 4. Execute the Cost Janitor script
python janitor.py --dry-run

+-----------------------------------------------------------------+
|                        GitHub Actions CI                        |
+-----------------------------------------------------------------+
                                |
                                v
+-----------------------------------------------------------------+
|                    LocalStack (Docker Sandbox)                  |
|  +----------------+   +-------------------+   +--------------+  |
|  |  VPC Network   |   | EC2 App Instances |   | S3 Log Bucket|  |
|  +----------------+   +-------------------+   +--------------+  |
|  |             [Orphaned Elastic IP / Volumes]               |  |
+-----------------------------------------------------------------+
                                ^
                                | (Scans APIs)
+-----------------------------------------------------------------+
|                    Python "Cost Janitor" Core                   |
+-----------------------------------------------------------------+
                                |
                                v
                [report.json] & [report.md Summary]
Decisions & deviations
Port 22 SSH Inbound Access: The specification called for open port 22 access globally (0.0.0.0/0). This was flagged as unsafe and modified in the actual deployment variables to limit traffic securely.

Static Cost Mapping: Implemented a modular static pricing reference layer (constants.py) tracking official AWS gp3 and compute rates to compute financial waste projections cleanly without adding runtime cloud overhead.

Trade-offs
If allocated an additional week of development time, the top priorities would be implementing true parallel multi-threading for AWS API execution sweeps across massive organizational account hierarchies, writing comprehensive unit-test suites utilizing the Moto framework to isolate the tracking script from running local containers during verification cycles, and extending native support to dynamically ingest GCP infrastructure footprints.

AI usage disclosure
Tools Utilized: ChatGPT and Claude were used to generate boilerplate configurations for the infrastructure workflows and structural shell scaffolding.

AI Mitigations: The AI initially generated an invalid LocalStack connection string structure that failed to resolve container configurations. This was caught during early shell validation and manually fixed.

Manual Work: The logical layout design patterns inside janitor.py and structural schemas were coded manually to guarantee strict adherence to the required JSON reporting formats.
