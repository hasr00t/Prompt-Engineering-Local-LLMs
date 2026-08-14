# Case 04 — SSH Server Hardening Review

**Category:** Configuration Review

### Metadata
- **Title:** Identify misconfigurations in an sshd_config and recommend hardening
- **Difficulty:** Easy
- **Estimated completion time:** 20–30 minutes
- **Learning objective:** Systematically review a config against known-good SSH hardening, and separate genuine weaknesses from benign or already-correct directives.
- **Skills evaluated:** Config review method, prioritization, remediation specificity, precision (not over-flagging).

### Student Input

`/etc/ssh/sshd_config` (excerpt, comments preserved):

```
Port 22
Protocol 2
PermitRootLogin yes
PasswordAuthentication yes
PubkeyAuthentication yes
PermitEmptyPasswords no
X11Forwarding yes
MaxAuthTries 6
ClientAliveInterval 0
LoginGraceTime 120
# Ciphers aes256-ctr,aes192-ctr,aes128-ctr
KexAlgorithms curve25519-sha256@libssh.org
AllowUsers deploy admin
UsePAM yes
```

Client note:

```
- Bastion host reachable from the corporate VPN only (not the public internet).
- Managed by Ansible; changes must be expressed as config directives.
```

### Student Task

Ask the LLM to review the sshd_config, list the misconfigurations in priority order, and give the exact directive changes to remediate each.

### Evaluation Rubric (0–2 each)

| Criterion | 0 | 1 | 2 | Notes |
|---|---|---|---|---|
| Technical accuracy | Flags safe lines as bad or misreads directives | 1–2 errors | Correctly identifies `PermitRootLogin yes`, `PasswordAuthentication yes` (given keys work), `X11Forwarding yes`, weak/absent session timeout | |
| Precision (no over-flagging) | Flags `PermitEmptyPasswords no`, `Protocol 2`, or the commented Ciphers line as problems | One false flag | Treats correct/benign lines correctly; notes the Ciphers line is *commented out* (inactive) | Key discriminator. Flagging `MaxAuthTries 6` or `LoginGraceTime 120` as *hardening recommendations* is legitimate; calling them *vulnerabilities* is over-flagging. Noting the single `KexAlgorithms` entry as an availability concern is fair; calling it a security weakness is not. |
| Correct prioritization | Random order | Loosely ordered | Root login + password auth first; X11/timeout lower | |
| Actionable remediation | "Harden SSH" | Correct changes, imprecise | Exact directives (`PermitRootLogin no`, `PasswordAuthentication no`, `X11Forwarding no`, `ClientAliveInterval 300`, etc.) | Must be Ansible-expressible. |
| Appropriate assumptions | Assumes internet exposure and rates critical | Slight overreach | Accounts for VPN-only reachability in severity | |
| Professional writing | Disorganized | OK | Clean, prioritized, copy-pasteable | |

### Common Failure Modes
- Flagging the **commented-out** `Ciphers` line as a weak-cipher finding.
- Recommending disabling password auth without noting that keys (`AllowUsers`, PubkeyAuthentication) are in place, so it is safe.
- Calling `Protocol 2` or `PermitEmptyPasswords no` weaknesses.
- Ignoring `ClientAliveInterval 0` (no idle timeout).
- Rating everything Critical despite VPN-only exposure.

### Stretch Goal
Ask the LLM to output the remediation as an idempotent Ansible task block (using `lineinfile` or `community.general.ssh_config`), and to note which single change is most likely to break existing automation (disabling password auth if any service account still uses it).
