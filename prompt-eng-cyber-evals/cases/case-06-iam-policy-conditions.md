# Case 06 — AWS IAM Policy With a Constraining Condition

**Category:** Configuration Review

### Metadata
- **Title:** Assess the real risk of an over-broad IAM policy that includes a condition block
- **Difficulty:** Hard
- **Estimated completion time:** 40–55 minutes
- **Learning objective:** Reason about effective permissions, not just the presence of a wildcard — a `Condition` can materially change the risk, and the honest assessment may be "it depends on facts not shown."
- **Skills evaluated:** IAM policy evaluation logic, nuanced risk reasoning, recognizing insufficient evidence, remediation.

### Student Input

IAM policy attached to role `ci-deployer`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DeployArtifacts",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*",
      "Condition": {
        "StringEquals": { "aws:PrincipalTag/team": "release" },
        "IpAddress": { "aws:SourceIp": "203.0.113.0/24" }
      }
    },
    {
      "Sid": "AssumeDeployRoles",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::*:role/deploy-*"
    },
    {
      "Sid": "PassAny",
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "*"
    }
  ]
}
```

Client note (partial):

```
- ci-deployer is assumed by the CI runner in account 111122223333.
- The CI runner egresses through a NAT with a static IP.
- (No information provided on which roles exist matching deploy-*, or on
   what the PassRole target roles can do.)
```

### Student Task

Ask the LLM to review the policy, identify the misconfigurations in order of real-world risk, and recommend least-privilege fixes. It should distinguish issues that are clearly bad from those whose severity depends on facts not in the evidence.

### Evaluation Rubric (0–2 each)

| Criterion | 0 | 1 | 2 | Notes |
|---|---|---|---|---|
| IAM reasoning | Judges by wildcard presence alone | Partial | Reasons about *effective* access: the `s3:*` statement is condition-gated; `iam:PassRole` on `*` is the sharper risk | Condition materially narrows statement 1. |
| Correct prioritization | Rates `s3:*` as the top issue | Mixed | Ranks unconstrained `iam:PassRole` (privilege escalation vector) above the condition-gated `s3:*` | Key discriminator. |
| Recognizing insufficient evidence | Asserts full escalation impact as fact | Hints at unknowns | States that `PassRole *` + `AssumeRole deploy-*` impact depends on what those roles can do — which is not provided | The honest core. |
| Cross-account scope | Does not notice the wildcard account-id | — | Notes that `arn:aws:iam::*:role/deploy-*` allows assuming `deploy-*` roles in *any* AWS account, not just 111122223333 — a cross-account risk | Secondary to PassRole but a valid finding. Credit if raised. |
| Technical accuracy | Misreads condition logic | Minor error | Correctly reads `StringEquals` + `IpAddress` as AND-combined constraints | |
| Actionable remediation | "Apply least privilege" | Generic | Scope `PassRole` to specific role ARNs, scope `s3:*` to needed actions/buckets, keep/verify the conditions | |
| No hallucinated facts | Invents role capabilities or bucket names | One | Does not fabricate what `deploy-*` roles can do | |

### Common Failure Modes
- Flagging `s3:*` as the worst problem because of the wildcard, ignoring that the condition gates it.
- Overlooking `iam:PassRole` on `*` as the real privilege-escalation risk.
- Asserting a full account-takeover impact without the target-role permissions to justify it.
- Misinterpreting how multiple keys inside one `Condition` combine (they AND).
- Recommending deletion of the IP/tag conditions (which are actually the good parts).

### Stretch Goal
Ask the LLM to describe the *concrete* privilege-escalation path an attacker with this role would attempt (assume-role into `deploy-*`, or pass a powerful role to a service), and to list exactly which pieces of evidence (the `deploy-*` trust policies, the passable roles' permissions) it would need to confirm the path is real versus theoretical.
