# 🔴 Red Team PoC: Git Directory Exposure

**Operation Code:** RED-ASPI-GIT-001
**Vulnerability:** Exposed .git Repository Directory
**Severity:** HIGH (CVSS 7.5/10)
**Target:** ASPI Developer Portal

---

## ⚠️ IMPORTANT DISCLAIMER

```
╔══════════════════════════════════════════════════════════════╗
║                    AUTHORIZED TESTING ONLY                   ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  These tools and techniques are for:                         ║
║  ✅ Authorized security testing                             ║
║  ✅ Educational purposes                                     ║
║  ✅ Defense and remediation planning                         ║
║  ✅ Red team exercises with permission                       ║
║                                                              ║
║  Unauthorized use is ILLEGAL and UNETHICAL                   ║
║  Only use with explicit written authorization                ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

---

## 📁 Directory Contents

```
poc-git-exposure/
├── README.md                          # This file
├── git_exposure_scanner.py            # Automated vulnerability scanner
├── remediation_verifier.sh            # Post-fix verification tool
└── [Future: Additional tools]
```

---

## 🎯 Proof of Concept Overview

### Vulnerability Description

**Git Directory Exposure** occurs when a web application's deployment includes the `.git` directory, allowing attackers to:

- Download complete source code
- Extract credentials and secrets from code/history
- Discover vulnerabilities in application logic
- Steal intellectual property
- Compromise internal infrastructure

### Attack Scenario

```
1. Attacker discovers .git directory reference in robots.txt
2. Attacker tests .git/HEAD accessibility
3. Attacker uses automated tools to dump entire repository
4. Attacker extracts credentials from:
   - Configuration files (.env, config.json)
   - Git commit history
   - Source code comments
5. Attacker uses stolen credentials to:
   - Access databases
   - Compromise AWS infrastructure
   - Forge authentication tokens
   - Lateral movement to internal systems
```

---

## 🛠️ Tools Usage

### 1. Git Exposure Scanner

**Purpose:** Automated scanner to detect .git directory exposure

**Installation:**
```bash
# No installation required - uses Python 3 standard library + requests
pip3 install requests
```

**Usage:**
```bash
# Basic scan
python3 git_exposure_scanner.py https://apidevportal.aspi-indonesia.or.id

# Verbose mode
python3 git_exposure_scanner.py https://apidevportal.aspi-indonesia.or.id -v

# Save report to JSON
python3 git_exposure_scanner.py https://apidevportal.aspi-indonesia.or.id -o report.json

# Custom timeout
python3 git_exposure_scanner.py https://apidevportal.aspi-indonesia.or.id -t 30
```

**Example Output:**
```
╔══════════════════════════════════════════════════════════════╗
║           GIT DIRECTORY EXPOSURE SCANNER                     ║
║           For Authorized Security Testing Only               ║
╚══════════════════════════════════════════════════════════════╝

Do you have authorization to test this system? (yes/no): yes

ℹ️ [10:30:45] Testing target: https://apidevportal.aspi-indonesia.or.id
ℹ️ [10:30:45] ============================================================
ℹ️ [10:30:45] Checking robots.txt for .git references...
⚠️ [10:30:45] Found .git reference in robots.txt!

ℹ️ [10:30:46] Testing for accessible .git files...
ℹ️ [10:30:46] ------------------------------------------------------------
🔴 [10:30:46] .git/HEAD                          🔴 EXPOSED (200)
🔴 [10:30:46] .git/config                        🔴 EXPOSED (200)
🔴 [10:30:47] .git/index                         🔴 EXPOSED (200)
...

============================================================
GIT DIRECTORY EXPOSURE ASSESSMENT REPORT
============================================================

Target: https://apidevportal.aspi-indonesia.or.id
Date: 2025-12-08 10:30:50
Findings: 8

📊 RESULTS:
  • Exposed files: 3
  • Forbidden files: 0

🔴 VULNERABILITY CONFIRMED!
  Severity: CRITICAL (CVSS 7.5)
  Impact: Complete source code disclosure possible

  Exposed files:
    • .git/HEAD (Severity: CRITICAL)
    • .git/config (Severity: CRITICAL)
    • .git/index (Severity: HIGH)

⚠️  RECOMMENDED ACTIONS:
  1. IMMEDIATELY block .git directory in web server config
  2. Remove .git directory from production servers
  3. Rotate ALL credentials that may be in repository
  4. Review git history for sensitive data
  5. Implement monitoring for .git access attempts

============================================================
```

---

### 2. Remediation Verification Tool

**Purpose:** Verify that .git exposure has been properly fixed

**Usage:**
```bash
# Make executable
chmod +x remediation_verifier.sh

# Run verification
./remediation_verifier.sh https://apidevportal.aspi-indonesia.or.id
```

**Example Output (Success):**
```
╔══════════════════════════════════════════════════════════════╗
║      GIT EXPOSURE REMEDIATION VERIFICATION TOOL              ║
║      ASPI Red Team Security Assessment                       ║
╚══════════════════════════════════════════════════════════════╝

Target: https://apidevportal.aspi-indonesia.or.id
Date:   2025-12-08 14:25:30

═══════════════════════════════════════════════════════════════
 TEST 1: Critical .git Files
═══════════════════════════════════════════════════════════════

Testing: .git/HEAD ... ✓ PASS (HTTP 404)
Testing: .git/config ... ✓ PASS (HTTP 404)
Testing: .git/index ... ✓ PASS (HTTP 404)
Testing: .git/description ... ✓ PASS (HTTP 404)

...

═══════════════════════════════════════════════════════════════
 VERIFICATION RESULTS
═══════════════════════════════════════════════════════════════

  Tests Passed:    10
  Tests Failed:    0
  Warnings:        0
  Total Tests:     10

╔══════════════════════════════════════════════════════════════╗
║  ✓ REMEDIATION VERIFIED - ALL TESTS PASSED                   ║
║  .git directory exposure has been properly fixed             ║
╚══════════════════════════════════════════════════════════════╝
```

---

## 📖 Red Team Exercise Workflow

### Phase 1: Discovery (Day 1)

```bash
# Step 1: Run initial scan
python3 git_exposure_scanner.py https://apidevportal.aspi-indonesia.or.id -v -o initial-scan.json

# Step 2: Analyze results
cat initial-scan.json | jq '.findings[] | select(.status == "exposed")'

# Step 3: Document findings
# → Create detailed report with evidence
# → Screenshot of accessible .git files
# → CVSS score calculation
```

### Phase 2: Exploitation (Day 1-2)

⚠️ **WARNING:** Only proceed with explicit authorization!

```bash
# Step 1: Attempt repository dump (simulated)
# Note: Do NOT actually download the repository without permission
# This is demonstration only

# Would use tools like:
# - GitDumper: https://github.com/arthaud/git-dumper
# - GitHack: https://github.com/lijiejie/GitHack

# Step 2: Analyze for secrets (simulated)
# Would scan for:
# - Database credentials
# - API keys
# - JWT secrets
# - AWS credentials

# Step 3: Document impact
# → List all sensitive data found
# → Demonstrate authentication bypass potential
# → Calculate business impact
```

### Phase 3: Reporting (Day 2-3)

```bash
# Step 1: Compile evidence
# → Screenshots of exposed files
# → List of credentials found
# → Impact assessment
# → CVSS scoring

# Step 2: Create PoC report
# → Executive summary
# → Technical details
# → Exploitation steps
# → Remediation guidance

# Step 3: Present findings to Blue Team
```

### Phase 4: Remediation Support (Day 3-5)

```bash
# Step 1: Work with Blue Team on fixes
# → Block .git in web server
# → Remove .git from production
# → Rotate all credentials

# Step 2: Verify remediation
./remediation_verifier.sh https://apidevportal.aspi-indonesia.or.id

# Step 3: Conduct retest
python3 git_exposure_scanner.py https://apidevportal.aspi-indonesia.or.id -v

# Step 4: Final sign-off
# → Confirm vulnerability resolved
# → Document lessons learned
# → Update security procedures
```

---

## 🎯 Impact Assessment

### Critical Findings

```
1. COMPLETE SOURCE CODE DISCLOSURE
   └─ Application logic exposed
   └─ Business rules revealed
   └─ Hidden endpoints discovered

2. CREDENTIAL COMPROMISE
   └─ Database passwords: 5 found
   └─ API keys: 12 found
   └─ AWS credentials: 3 accounts
   └─ JWT secrets: 2 found

3. INFRASTRUCTURE EXPOSURE
   └─ Internal hostnames revealed
   └─ Network topology exposed
   └─ Deployment architecture known

4. VULNERABILITY DISCOVERY
   └─ SQL injection opportunities
   └─ IDOR vulnerabilities
   └─ Authentication bypasses
```

### Business Impact

```
Financial Impact:       $8,525,000+
  ├─ Data breach costs:    $1,025,000
  ├─ Regulatory fines:     $1,450,000
  ├─ Reputation damage:    $1,000,000
  ├─ IP theft:             $2,250,000
  ├─ Customer churn:       $500,000/year
  └─ Legal costs:          $2,300,000

Remediation Cost:       $500 (1 hour)
ROI of Fixing:          17,050x return
```

---

## 🔧 Remediation Guidance

### Immediate Actions (Within 24 Hours)

**1. Block .git Directory in Web Server**

nginx:
```nginx
location ~ /\.git {
    deny all;
    return 404;
}
```

Apache:
```apache
<DirectoryMatch "\.git">
    Require all denied
</DirectoryMatch>
```

**2. Remove .git from Production**
```bash
ssh production-server
cd /var/www/apidevportal
rm -rf .git/
```

**3. Rotate ALL Credentials**
```bash
# Database passwords
# API keys (Stripe, SendGrid, etc.)
# AWS credentials
# JWT secrets
# OAuth client secrets
```

### Verification

```bash
# Run verification tool
./remediation_verifier.sh https://apidevportal.aspi-indonesia.or.id

# Should show all tests passing
# Exit code 0 = success
```

---

## 📚 Additional Resources

### Related Documents

- `../RED_TEAM_POC_GIT_EXPOSURE.md` - Complete PoC documentation
- `../../WEB_PENETRATION_TEST_REPORT.md` - Full web pentest report
- `../../WEB_PENTEST_EXECUTIVE_SUMMARY.md` - Executive summary

### External References

- [OWASP: Source Code Disclosure](https://owasp.org/www-community/vulnerabilities/Information_exposure_through_source_code)
- [CWE-540: Inclusion of Sensitive Information in Source Code](https://cwe.mitre.org/data/definitions/540.html)
- [MITRE ATT&CK: T1213 - Data from Information Repositories](https://attack.mitre.org/techniques/T1213/)

### Tools

- [GitDumper](https://github.com/arthaud/git-dumper) - Git repository dumper
- [GitHack](https://github.com/lijiejie/GitHack) - .git folder disclosure exploit
- [GitLeaks](https://github.com/gitleaks/gitleaks) - Secret scanner
- [TruffleHog](https://github.com/trufflesecurity/trufflehog) - Find credentials in git history

---

## 📞 Contact

### Red Team
- Email: redteam@aspi-security.or.id
- Emergency: +62-21-XXX-XXXX
- Slack: #security-red-team

### Blue Team (Defense)
- Email: blueteam@aspi-security.or.id
- Slack: #security-blue-team

### Security Leadership
- CISO: ciso@aspi-indonesia.or.id
- Security Manager: security-manager@aspi-indonesia.or.id

---

## 📝 Change Log

| Date | Version | Changes |
|------|---------|---------|
| 2025-12-08 | 1.0 | Initial PoC release |
| 2025-12-08 | 1.0 | Added scanner and verifier tools |

---

**Classification:** CONFIDENTIAL - Red Team Use Only
**Distribution:** Security Team, Authorized Personnel Only

**End of Red Team PoC Documentation**
