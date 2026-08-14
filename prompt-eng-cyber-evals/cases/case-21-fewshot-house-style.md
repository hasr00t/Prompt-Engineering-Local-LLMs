# Case 21 — Few-Shot: Match the House Finding Style

**Category:** Finding Writing

### Metadata
- **Title:** Use worked examples to produce a new finding in the firm's house style
- **Difficulty:** Medium
- **Estimated completion time:** 30–40 minutes
- **Learning objective:** Steer output format and voice by supplying examples (few-shot) rather than describing the format in prose, while not carrying example-specific facts into the new finding.
- **Skills evaluated:** Few-shot prompting, output formatting, role/voice consistency, hallucination resistance.

### Student Input

Two existing findings in the firm's house style (the pattern to imitate):

```
--------------------------------------------------------------------
Finding ID:      BHIS-2026-014
Title:           Password Policy Permits Weak Passwords
Risk Rating:     Medium
Affected Assets: corp.internal domain (Default Domain Policy)
Description:     The domain password policy enforces a minimum length of
                 7 characters with no complexity or lockout threshold.
Business Impact: Should this weakness be exploited, an attacker could
                 conduct password-guessing attacks against domain accounts
                 with a high likelihood of success, gaining an initial
                 foothold in the environment.
Recommendation:  Increase minimum length to 14+ characters, enable an
                 account lockout threshold, and adopt a banned-password list.
References:       [CIS-WIN-2022 1.1.x]
--------------------------------------------------------------------
Finding ID:      BHIS-2026-021
Title:           Web Application Transmits Session Cookie Without Secure Flag
Risk Rating:     Low
Affected Assets: https://portal.example.com
Description:     The application sets its session cookie without the Secure
                 attribute, permitting transmission over cleartext channels.
Business Impact: Should this weakness be exploited, an attacker positioned
                 on the network could capture a valid session cookie and
                 impersonate the affected user.
Recommendation:  Set the Secure and HttpOnly attributes on all session
                 cookies and enforce HTTPS site-wide.
References:       [OWASP-ASVS 3.4.1]
--------------------------------------------------------------------
```

Raw scanner output for the NEW issue to be written up:

```
Nessus Plugin 41028 - SNMP Agent Default Community Name (public)
Host: 10.14.30.9 (udp/161)
Risk: Medium
Synopsis: The community name of the remote SNMP server can be guessed.
Plugin Output:
  The remote SNMP server replies to the following default community string:
    public
Solution: Disable the SNMP service, change the default community string,
  or upgrade to SNMPv3.
```

Client note:

```
- 10.14.30.9 is a network-management appliance on the internal LAN.
- Follow the house finding format exactly; this goes straight into the report.
```

### Student Task

Ask the LLM to write a new finding for the SNMP default community string issue **in the exact house style** shown by the two examples, using only the SNMP evidence.

### Evaluation Rubric (0–2 each)

| Criterion | 0 | 1 | 2 | Notes |
|---|---|---|---|---|
| Format fidelity | Ignores the template structure | Loose match | Reproduces the field order, labels, and layout of the examples | The point of few-shot. |
| Voice/quirk imitation | Drops the house phrasing | Partial | Opens Business Impact with "Should this weakness be exploited," as both examples do | Tests example-driven style transfer. |
| Correct content | Wrong technical detail | Minor | Accurately describes the SNMP `public` community risk (info disclosure / recon, possible write) | |
| No cross-contamination | Carries example facts (domain policy, cookie) into the new finding | One leak | Uses only the SNMP evidence; no fields copied from the examples' content | The planted trap. |
| No hallucinated facts | Invents a Finding ID, CVSS, or device model | One | Leaves/──marks the Finding ID as to-be-assigned; no invented model or version | ID sequence isn't given. |
| Appropriate rating/reference | Mis-rates or fakes a citation | Weak | Rating consistent with examples; a plausible, correctly-formatted reference (or none) | |

### Common Failure Modes
- Reformatting into the model's own default finding layout instead of the house template.
- Dropping the "Should this weakness be exploited," opener.
- Copying a reference (`[CIS-WIN-2022 …]`) or asset from an example that does not apply to SNMP.
- Inventing a `Finding ID` in sequence (e.g., BHIS-2026-022) as if it were known.
- Fabricating a device vendor/model for 10.14.30.9.

### Stretch Goal
Add a third example that subtly contradicts the other two (e.g., it places `Recommendation` *before* `Description`, or omits `References`). The student must recognize the inconsistency and decide — with justification — which pattern to follow, rather than blindly averaging the three.
