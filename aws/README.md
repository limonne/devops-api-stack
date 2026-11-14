# AWS Governance Baseline

This directory contains the initial governance design for running DevOps API Stack on AWS.

The current files are design artifacts. They are version-controlled and validated, but they are not automatically attached to an AWS Organization.

## Target account structure

```text
AWS Organization
├── Security OU
│   ├── Log Archive account
│   └── Audit account
└── Workloads OU
    ├── NonProduction OU
    │   ├── Lab account
    │   ├── Development account
    │   └── Staging account
    └── Production OU
        └── Production account
```

The management account is reserved for organization administration and governance. Application workloads run in member accounts.

## Governance controls

| Area | Planned control |
| --- | --- |
| Workforce access | IAM Identity Center and temporary role sessions |
| Account organization | AWS Organizations and organizational units |
| Regional restrictions | Service control policies |
| API auditing | Multi-Region organization CloudTrail trail |
| Resource configuration | AWS Config recorders |
| Compliance | AWS Config managed rules |
| Central visibility | AWS Config aggregator in the Audit account |
| Cost ownership | Standard resource tags |
| Cost monitoring | AWS Budgets alerts |

## Regional guardrail

`governance/scp-deny-ec2-outside-ireland.json` denies Amazon EC2 API operations when the requested Region is different from `eu-west-1`.

This policy is a learning guardrail and must be tested in an isolated organizational unit before it is attached to production accounts. It does not provide a complete Region restriction for every AWS service.

## Tagging standard

`governance/tag-policy-environment.json` defines the preferred capitalization and values for the following tags:

| Tag | Purpose |
| --- | --- |
| `Environment` | Identifies Lab, Staging, or Production resources |
| `Project` | Associates resources with an application |
| `Owner` | Identifies the responsible team |
| `ManagedBy` | Identifies the provisioning method |

Cost allocation tags must be activated in AWS Billing before they appear in Cost Explorer and cost reports.

## Audit baseline

The planned CloudTrail baseline includes:

- An organization trail.
- Multi-Region management event collection.
- Log file validation.
- A dedicated S3 bucket in the Log Archive account.
- Encryption using AWS KMS.
- Restricted access to audit logs.
- Optional delivery to CloudWatch Logs for alerting.
- Selected data events where the additional visibility is justified.

The planned AWS Config baseline includes:

- A configuration recorder in each required Region.
- Recording of supported resource types used by the project.
- A protected delivery channel.
- Managed rules for security and operational requirements.
- A multi-account and multi-Region aggregator in the Audit account.

## Cost baseline

The initial cost controls include:

- A monthly account budget.
- Alerts for actual spend at 50% and 80%.
- A forecasted spend alert at 100%.
- Cost reporting by `Project` and `Environment`.
- Regular review of untagged resources.

AWS Budgets provides monitoring and notifications. It does not act as a real-time spending limit.

## Deployment sequence

1. Create the organization and organizational units.
2. Create or enroll the required AWS accounts.
3. Configure workforce access.
4. Configure centralized CloudTrail logging.
5. Enable AWS Config in the required accounts and Regions.
6. Create the central Config aggregator.
7. Test service control policies in an isolated OU.
8. Apply the tagging standard.
9. Activate cost allocation tags.
10. Configure budgets and notifications.
11. Deploy the application infrastructure.

## Local validation

Validate the governance policy files from the repository root:

```bash
for policy_file in aws/governance/*.json; do
  python3 -m json.tool "$policy_file" >/dev/null
done
```
