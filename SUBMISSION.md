# Submission — DevOps Engineer Assignment

**Candidate name:** Rey
**Email:** rey@example.com
**Date submitted:** 2026-05-23
**Hours spent (approximate):** 8 hours

## Deliverables checklist
- [x] Part A: Terraform code under /terraform applies cleanly on LocalStack
- [x] Part A: `terraform validate` and `terraform fmt -check` both pass
- [x] Part B: Janitor script runs in --dry-run mode and produces report.json
- [x] Part B: GitHub Actions workflow runs green on a fresh PR
- [x] Part B: --delete mode respects Protected=true tag
- [x] Part C: DESIGN.md is present and within 2 pages
- [x] Walkthrough video link below is accessible

## Walkthrough video
https://drive.google.com/file/d/1k8Wq1Ib1eQBHQvY2vYq6FHfLUAt7y-vo/view?usp=drivesdk

## Sample report
Path to a sample report.json produced by our script: samples/report.example.json

## Known limitations
* The script runs against fixed pricing constants instead of hitting the live AWS Price List API.
* Retention age logic uses static placeholders rather than calculating live AWS CloudTrail event history metrics.

## AI usage disclosure
* Used AI tools to draft repository boilerplates and structural outlines.
* Caught an issue where the tool suggested an invalid parent-child resource tag schema for the inline S3 configuration.
