"""
FinOps cost tracking constants for NimbusKart Cost Janitor.
All prices are in USD.
"""

# EBS gp3 storage pricing per GB-month ($0.08)
# Source: AWS EBS Pricing Official Page (https://aws.amazon.com/ebs/pricing/)
EBS_GB_MONTHLY_COST = 0.08

# Unassociated Elastic IP pricing per hour ($0.005)
# Source: AWS EC2 Pricing - Public IPv4 Addresses (https://aws.amazon.com/ec2/pricing/)
EIP_HOURLY_COST = 0.005
EIP_MONTHLY_COST = EIP_HOURLY_COST * 24 * 30  # ~3.60 USD per month

# EC2 Compute pricing when stopped
# Source: AWS EC2 Instance Pricing (https://aws.amazon.com/ec2/instance-types/t3/)
# Compute is free when stopped, but attached storage root drives still incur standard EBS fees.
EC2_STOPPED_COMPUTE_COST = 0.0
