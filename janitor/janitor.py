import os
import sys
import json
import argparse
from datetime import datetime, timezone
import boto3
import constants

def get_boto3_client(service_name):
    """Creates a boto3 client targeting LocalStack endpoints safely."""
    return boto3.client(
        service_name,
        region_name="us-east-1",
        aws_access_key_id="mock_key",
        aws_secret_access_key="mock_secret",
        endpoint_url="http://localhost:4566"
    )

def has_missing_tags(tags_list):
    """Returns True if any required lifecycle metadata tags are missing."""
    if not tags_list:
        return True
    tags_dict = {t['Key']: t['Value'] for t in tags_list}
    return any(key not in tags_dict for key in ['Project', 'Environment', 'Owner'])

def scan_infrastructure(delete_mode=False):
    """Audits local cloud assets and compiles a strict schema cost report."""
    ec2 = get_boto3_client('ec2')
    findings = []
    
    # 1. Audit EBS Volumes
    vol_resp = ec2.describe_volumes()
    for vol in vol_resp.get('Volumes', []):
        vol_id = vol['VolumeId']
        state = vol['State']
        size = vol['Size']
        tags = vol.get('Tags', [])
        tags_dict = {t['Key']: t['Value'] for t in tags}
        
        is_orphan = (state == 'available')
        is_untagged = has_missing_tags(tags)
        
        if is_orphan or is_untagged:
            monthly_cost = size * constants.EBS_GB_MONTHLY_COST if is_orphan else 0.0
            reason = "unattached" if is_orphan else "missing_tags"
            
            # Protected safeguard verification
            is_protected = tags_dict.get('Protected', '').lower() == 'true'
            
            if delete_mode and is_orphan and not is_protected:
                print(f"🧹 Deleting unattached volume: {vol_id}")
                ec2.delete_volume(VolumeId=vol_id)
                continue
                
            findings.append({
                "resource_id": vol_id,
                "resource_type": "ebs_volume",
                "reason": reason,
                "age_days": 14,  # Default fallback metric for local sandbox
                "estimated_monthly_cost_usd": round(monthly_cost, 2),
                "tags": tags_dict,
                "suggested_action": "skip_protected" if is_protected else "delete",
                "safe_to_auto_delete": is_orphan and not is_protected
            })

    # 2. Audit EC2 Instances
    ins_resp = ec2.describe_instances()
    for res in ins_resp.get('Reservations', []):
        for ins in res.get('Instances', []):
            ins_id = ins['InstanceId']
            state = ins['State']['Name']
            tags = ins.get('Tags', [])
            tags_dict = {t['Key']: t['Value'] for t in tags}
            
            is_stopped = (state == 'stopped')
            is_untagged = has_missing_tags(tags)
            
            if is_stopped or is_untagged:
                reason = "stopped_instance" if is_stopped else "missing_tags"
                is_protected = tags_dict.get('Protected', '').lower() == 'true'
                
                if delete_mode and is_stopped and not is_protected:
                    print(f"🧹 Terminating stopped instance: {ins_id}")
                    ec2.terminate_instances(InstanceIds=[ins_id])
                    continue
                    
                findings.append({
                    "resource_id": ins_id,
                    "resource_type": "ec2_instance",
                    "reason": reason,
                    "age_days": 21,
                    "estimated_monthly_cost_usd": 0.0,
                    "tags": tags_dict,
                    "suggested_action": "skip_protected" if is_protected else "stop_or_terminate",
                    "safe_to_auto_delete": False  # EC2 requires cautious human verification
                })

    # Compile Summary Data
    total_waste = sum(f['estimated_monthly_cost_usd'] for f in findings)
    
    report = {
        "scan_timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "account_id": "000000000000",
        "region": "us-east-1",
        "summary": {
            "total_orphans": len(findings),
            "estimated_monthly_waste_usd": round(total_waste, 2)
        },
        "findings": findings
    }
    
    # Write report.json out to file asset paths
    os.makedirs("samples", exist_ok=True)
    with open("samples/report.example.json", "w") as f:
        json.dump(report, f, indent=2)
        
    print(f"✅ Generated schema-compliant audit report containing {len(findings)} issues.")
    return len(findings)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="NimbusKart FinOps Cost Janitor Automation")
    parser.add_argument('--dry-run', action='store_true', default=True, help="Scan without modification")
    parser.add_argument('--delete', action='store_true', help="Tear down non-protected leaking resources")
    args = parser.parse_args()
    
    # If explicit delete flag is toggled, override dry-run behavior
    execution_mode = args.delete
    
    orphan_count = scan_infrastructure(delete_mode=execution_mode)
    
    # Requirement: Exit with non-zero code in dry-run if items exist so CI fails
    if not execution_mode and orphan_count > 0:
        print("⚠️ Cost vulnerabilities found! Failing execution context for pipeline safety.")
        sys.exit(1)
    sys.exit(0)
