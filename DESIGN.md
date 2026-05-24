# Architecture & Design Note: Enterprise Cloud Cost Optimization

This document outlines the strategic design patterns and engineering guardrails required to scale, harden, and productionize the NimbusKart Cost Janitor suite into an enterprise-ready FinOps framework.

## 1. Multi-Cloud Architecture Reality
To prevent rewriting core validation engines when adding Google Cloud Platform (GCP) or Microsoft Azure, the framework decouples **Resource Discovery** from **Cost Evaluation Logic** using a Provider Factory Pattern.

### Module Boundaries
1. **Core Janitor Engine (Cloud-Agnostic)**: Consumes a standardized intermediate object schema (containing uniform keys: `resource_id`, `raw_status`, `size_metrics`, `metadata_tags`) and maps them against global accounting tables.
2. **Cloud Discovery Modules (Cloud-Specific)**: Isolated translation plugins. The AWS module converts `boto3` descriptions, while the incoming GCP module will consume `google-cloud-asset` client payloads to map Compute Engine disks to the standard uniform schema.

---

## 2. Least-Privilege IAM Permissions
To enforce strict boundary security, the Janitor execution identity requires distinct access vectors based on its runtime mode. 

### Read-Only (--dry-run) Minimal IAM Policy
The following JSON document enforces strict read-only access, permitting resource analysis while denying destructive mutation verbs (`Delete*`, `Terminate*`):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "FinOpsJanitorReadOnlyBaseline",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeVolumes",
        "ec2:DescribeInstances",
        "ec2:DescribeAddresses",
        "ec2:DescribeTags",
        "s3:GetBucketTagging",
        "s3:ListAllMyBuckets"
      ],
      "Resource": "*"
    }
  ]
}
Destruction Mode (--delete) Additional Grants
When live remediation is enabled, the policy appends exact resource mutation privileges bounded by environment tags via condition statements:

ec2:DeleteVolume

ec2:TerminateInstances

ec2:ReleaseAddress

3. Production Safety Guardrails & Outage Prevention
Failure Mode A: Short-Lived Ephemeral Disks Caught In-Between
The Risk: A data engineering pipeline spins up a batch compute cluster that drops a massive 1 TB unattached staging disk for a 5-minute transformation matrix. If the Janitor sweeps during minute 3, it catches a false positive "unattached" disk and destroys active pipeline data.

The Guardrail: Enforce a strict Lookback Window / Cool-down Filter. The discovery layer must inspect the resource creation timestamp. If CurrentTime - VolumeCreationTime is less than 24 hours, the asset is automatically skipped.

Failure Mode B: Secondary Cluster Master Node Is Stopped for Maintenance
The Risk: A database master node is temporarily stopped during a scheduled offline patching window. A naive script sees a stopped instance and executes a termination sweep, completely deleting the core database system.

The Guardrail: Implement an explicit Opt-Out Tag Exception (Protected=true) and integrate a multi-stage validation check. Before executing destruction, the script calls an independent verification block checking for cluster state values. If any protected criteria match, deletion is blocked and a Slack warning alerts operations.

4. Observability & FinOps Alerts
Metrics are pushed directly to a central Prometheus/CloudWatch aggregation platform to track operational health:

Metric Name	Data Source	Alert Trigger Threshold	Operational Action
finops_janitor_execution_status	Script Exit Code	Value > 1 (Failure)	PagerDuty alert to DevOps: Script execution crashed mid-run.
finops_monthly_waste_identified_usd	JSON Summary Data	Value > 5000	Warning to FinOps Team: Rapid cloud cost escalation observed.
finops_protected_skip_count	Audit Findings Logs	Value > 50	Slack alert to Engineering: Accumulation of unmanaged assets marked protected.
5. Intentional Scoping Limitations
To deliver a high-quality automation suite within a focused timeline, the following elements were consciously excluded:

Automated Asset Snapshots: The script terminates objects directly in delete mode without first triggering a backup snapshot. In a production framework, generating a pre-destruction backup is mandatory to preserve historical data.

Multi-Account Cross-Assume Role Logic: This implementation executes entirely within a single localized credentials profile. True multi-account enterprise rollouts require iterating across AWS Organizations using dynamic STS AssumeRole profiles.
