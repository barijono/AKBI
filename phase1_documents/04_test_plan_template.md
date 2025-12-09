# SNAP API Security Testing Plan
## Bank Indonesia Security Assessment

**Version:** 1.0
**Date:** December 2025
**Classification:** Internal Use - Bank Indonesia

---

## 1. Executive Summary

Bank Indonesia's Security Assessment Division will conduct comprehensive security
testing of the SNAP (Standard National API Payment) API to evaluate security controls,
identify vulnerabilities, and ensure compliance with security standards.

**Scope:** Balance Inquiry API (Sandbox Environment)
**Duration:** 2 weeks (December 15-30, 2025)
**Methodology:** OWASP API Security Top 10

---

## 2. Testing Objectives

### Primary Objectives
1. Verify authentication mechanisms (OAuth 2.0, HMAC signatures)
2. Test authorization controls (access control, privilege escalation)
3. Identify injection vulnerabilities (SQL, NoSQL, Command, XSS)
4. Evaluate input validation and sanitization
5. Test rate limiting and abuse prevention

### Secondary Objectives
1. Assess error handling and information disclosure
2. Evaluate business logic security
3. Test session management
4. Verify compliance with OWASP API Security Top 10
5. Document security best practices

---

## 3. Scope Definition

### In Scope

**APIs:**
- Balance Inquiry API (POST /1.0/balance-inquiry)
- OAuth Token Endpoint (POST /oauth/token)
- Authentication mechanisms
- Authorization controls

**Test Types:**
- Authentication testing (11 tests)
- Authorization testing (4 tests)
- Injection testing (50+ tests)
- Business logic testing (5 tests)
- Rate limiting testing (3 tests)

**Environment:**
- Sandbox only: https://sandbox.aspi-indonesia.or.id
- Test accounts provided by ASPI
- No production data

### Out of Scope

**Not Included:**
- Production environment testing
- DoS/DDoS attacks
- Social engineering
- Physical security testing
- Internal network penetration
- Client-side testing (mobile apps, web portals)

---

## 4. Methodology

### Testing Framework: OWASP API Security Top 10

| OWASP Category | Test Coverage |
|----------------|---------------|
| API1: Broken Object Level Authorization | ✓ IDOR testing |
| API2: Broken Authentication | ✓ Token validation, HMAC |
| API3: Broken Object Property Level Authorization | ✓ Data exposure |
| API4: Unrestricted Resource Consumption | ✓ Rate limiting |
| API5: Broken Function Level Authorization | ✓ Privilege escalation |
| API8: Security Misconfiguration | ✓ Error handling |

### Testing Phases

**Phase 1: Reconnaissance (Day 1)**
- Review API documentation
- Understand authentication flow
- Identify test scenarios
- Setup testing environment

**Phase 2: Authentication Testing (Days 2-3)**
- Token validation
- HMAC signature verification
- Timestamp validation
- Replay attack testing
- Session management

**Phase 3: Authorization Testing (Days 4-5)**
- IDOR vulnerabilities
- Horizontal privilege escalation
- Vertical privilege escalation
- Account enumeration

**Phase 4: Injection Testing (Days 6-9)**
- SQL injection (15+ payloads)
- NoSQL injection (8+ payloads)
- LDAP injection (7+ payloads)
- Command injection (9+ payloads)
- XSS injection (8+ payloads)
- JSON injection / Prototype pollution

**Phase 5: Business Logic Testing (Days 10-12)**
- Parameter tampering
- Race conditions
- Boundary value testing
- Negative testing

**Phase 6: Rate Limiting Testing (Day 13)**
- Threshold identification
- Bypass testing
- Burst handling

**Phase 7: Reporting (Days 14-15)**
- Findings consolidation
- Report writing
- Evidence compilation

---

## 5. Testing Tools

### Automated Tools
- Custom SNAP Penetration Testing Framework (OWASP-based)
- Python 3.8+ with requests library
- YAML configuration management

### Manual Tools
- Burp Suite Professional (traffic inspection)
- curl (manual request crafting)
- jq (JSON parsing)

### Prohibited Tools
- No vulnerability scanners that may cause DoS
- No brute force tools
- No exploitation frameworks

---

## 6. Test Scenarios

### Authentication Testing (11 tests)
1. Missing authentication token
2. Invalid/malformed tokens
3. Expired token handling
4. Token reuse capability
5. Missing HMAC signature
6. Invalid HMAC signature
7. Weak HMAC algorithms
8. Timestamp manipulation
9. Replay attack protection
10. Signature stripping
11. Token validation

### Authorization Testing (4 tests)
1. IDOR - Unauthorized account access
2. Horizontal privilege escalation
3. Customer token requirements
4. Account enumeration

### Injection Testing (50+ tests)
- SQL Injection (15+ payloads)
- NoSQL Injection (8+ payloads)
- LDAP Injection (7+ payloads)
- Command Injection (9+ payloads)
- XSS Injection (8+ payloads)
- JSON Injection

### Business Logic Testing (5 tests)
1. Parameter pollution
2. Negative/invalid values
3. Excessive data requests
4. Race conditions
5. Boundary value testing

### Rate Limiting Testing (3 tests)
1. Threshold identification
2. Rate limit headers
3. Burst request handling

---

## 7. Risk Management

### Testing Risks

**Risk: Service Disruption**
- Likelihood: Low
- Impact: High
- Mitigation: Configurable rate limiting, test delays, sandbox only

**Risk: Data Exposure**
- Likelihood: Low
- Impact: Medium
- Mitigation: Test accounts only, no real customer data

**Risk: False Positives**
- Likelihood: Medium
- Impact: Low
- Mitigation: Manual verification of all findings

### Safety Controls

1. **Rate Limiting**
   - Maximum 100 requests per minute
   - Configurable delays between requests (100-200ms)
   - Automatic backoff on 429 errors

2. **Scope Limitation**
   - Sandbox environment only
   - Approved APIs only
   - No destructive testing

3. **Monitoring**
   - Real-time logging
   - Error tracking
   - Performance monitoring

4. **Emergency Stop**
   - Immediate cessation if issues detected
   - Emergency contact notification
   - Incident reporting

---

## 8. Success Criteria

### Testing Complete When:
- ✓ All test scenarios executed
- ✓ All findings documented with evidence
- ✓ Critical findings verified manually
- ✓ No false positives in final report
- ✓ Comprehensive report delivered

### Deliverables:
1. Executive summary
2. Technical vulnerability report
3. Remediation recommendations
4. Test evidence (sanitized logs)
5. Retest plan for fixed issues

---

## 9. Communication Plan

### Regular Updates
- Daily: Email update on testing progress
- Weekly: Status call with ASPI (if needed)
- Ad-hoc: Immediate notification for critical findings

### Critical Finding Process
1. Immediate notification to ASPI security team
2. Verbal confirmation via phone
3. Detailed email within 24 hours
4. Evidence provided
5. Remediation discussion

### Reporting Timeline
- Draft report: Day 14
- Final report: Day 16
- Presentation: Day 17 (if requested)

---

## 10. Team & Resources

### Bank Indonesia Team
- Lead Tester: [Your Name]
- Secondary Tester: [Backup Name]
- Security Team Lead: [Lead Name]
- Report Reviewer: [Reviewer Name]

### ASPI Points of Contact
- Security Team: security@aspi-indonesia.or.id
- Technical Support: support@aspi-indonesia.or.id
- Emergency Contact: [To be provided]

---

## 11. Timeline

| Week | Days | Activities |
|------|------|-----------|
| Week 1 | Mon-Tue | Reconnaissance, Authentication Testing |
| Week 1 | Wed-Thu | Authorization Testing |
| Week 1 | Fri | Injection Testing (Part 1) |
| Week 2 | Mon-Wed | Injection Testing (Part 2) |
| Week 2 | Thu | Business Logic & Rate Limiting |
| Week 2 | Fri | Reporting & Documentation |

---

## 12. Compliance & Standards

### Regulatory Framework
- Bank Indonesia Regulations (PBI)
- ISO 27001 Information Security
- OWASP API Security Top 10
- NIST Cybersecurity Framework

### Security Standards
- Secure handling of credentials
- Encrypted storage of sensitive data
- Responsible disclosure practices
- Professional testing ethics

---

## Approval

**Prepared By:**
Name: ___________
Title: ___________
Date: ___________
Signature: ___________

**Reviewed By:**
Name: ___________
Title: ___________
Date: ___________
Signature: ___________

**Approved By:**
Name: ___________
Title: Security Team Lead
Date: ___________
Signature: ___________

---

**Classification:** Internal Use - Bank Indonesia
**Distribution:** ASPI Security Team, Bank Indonesia Security Division
**Version Control:** v1.0 - December 2025
