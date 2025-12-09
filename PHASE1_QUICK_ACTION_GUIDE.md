# PHASE 1 - Quick Action Guide
## Get ASPI Credentials - What to Do NOW

**Current Status:** Ready to Start Phase 1
**Estimated Time:** 5-10 business days (mostly waiting for approvals)
**Active Work:** ~2 hours total

---

## 🎯 YOUR IMMEDIATE ACTIONS

### Action 1: Access ASPI Portal (10 minutes - DO NOW)

**Open your browser:**
```
URL: https://apidevportal.aspi-indonesia.or.id/
```

**What you should see:**
- ASPI Developer Portal homepage
- "Sign Up" or "Register" button
- Login form (for existing users)
- API documentation links

**⚠️ STOP if portal is not accessible:**
- Check network connection
- Try different browser
- Contact ASPI support: support@aspi-indonesia.or.id

---

### Action 2: Prepare Registration Information (15 minutes - DO NOW)

**Open this file you just created:**
```bash
cat /home/user/AKBI/phase1_documents/01_registration_info.txt
```

**Fill in BEFORE starting registration:**

**Required Information:**
- ✅ Your full name
- ✅ Your official BI email address
- ✅ Your phone number (mobile)
- ✅ Your position/title
- ✅ Bank Indonesia address
- ✅ Department: Security Assessment Division

**Optional but Helpful:**
- Organization registration number
- Secondary contact person
- Technical lead information

**Save the filled information somewhere secure (NOT this file if public)**

---

### Action 3: Register at ASPI Portal (20 minutes - DO TODAY)

**Step-by-step:**

1. **Go to:** https://apidevportal.aspi-indonesia.or.id/

2. **Click:** "Sign Up" or "Register"

3. **Fill the registration form with:**
   - Organization: **Bank Indonesia**
   - Your name: **[Your full name]**
   - Email: **[your-email]@bi.go.id** (MUST be official BI email)
   - Phone: **+62-[your-number]**
   - Position: **Security Consultant / Penetration Tester**
   - Purpose: **Security Testing / Penetration Testing**

4. **Submit** the registration

5. **Check your email** (within 5-10 minutes)
   - Subject: "ASPI Developer Portal - Email Verification"
   - From: noreply@aspi-indonesia.or.id or similar
   - Check spam folder if not received

6. **Click verification link** in email

7. **Log in** to portal with your email and password

8. **Verify you can see:**
   - Dashboard
   - "My Applications" menu
   - Profile section

**✅ SUCCESS:** You're logged into ASPI portal

**Mark in progress tracker:**
```bash
# Update your status
vim /home/user/AKBI/phase1_progress.md
# Check off: Portal Registration steps
```

---

### Action 4: Create Partner Application (30 minutes - DO TODAY)

**In ASPI Portal:**

1. **Navigate to:** Dashboard → "My Applications"

2. **Click:** "Create New Application" or "+ New"

3. **Fill Application Form:**

   **Use this reference file:**
   ```bash
   cat /home/user/AKBI/phase1_documents/02_application_details.txt
   ```

   **Application Name:**
   ```
   BI-Security-Assessment-SNAP-2025
   ```

   **Description:**
   ```
   Authorized security testing and vulnerability assessment of the SNAP API
   system conducted by Bank Indonesia's Security Assessment Division for
   regulatory oversight and security compliance verification.
   ```

   **Application Type:** Testing/Development

   **Requested APIs:**
   - ✅ Balance Inquiry API (MUST select)
   - ⬜ Others (optional for now)

   **Callback URL:**
   ```
   https://localhost:8080/oauth/callback
   ```

   **IP Addresses:** (if requested)
   - Get your current IP: `curl ifconfig.me`
   - Or use Bank Indonesia office IP range

4. **Submit Application**

5. **Save Application ID** (will be displayed after submission)
   ```
   Application ID: [copy this number]
   ```

6. **Note the status:** Usually "Pending" or "Under Review"

**✅ SUCCESS:** Application submitted, ID received

**Update progress tracker:**
```bash
vim /home/user/AKBI/phase1_progress.md
# Update Application ID
# Check off: Create Partner Application steps
```

---

### Action 5: Wait for Application Approval (1-3 business days - WAIT)

**What happens now:**
- ASPI reviews your application
- They may contact you for clarification
- Approval typically takes 1-3 business days

**During waiting:**

**DO:**
- ✅ Check email daily
- ✅ Check ASPI portal for status updates
- ✅ Prepare authorization request documents (next action)

**DON'T:**
- ❌ Submit multiple applications
- ❌ Contact support daily asking for updates
- ❌ Start Phase 2 yet (wait for credentials)

**Check application status:**
1. Log into ASPI portal
2. Go to "My Applications"
3. Check status: Pending / Under Review / Approved / Rejected

**If status is "Approved":**
- ✅ Proceed to Action 6
- ✅ You'll receive email notification

**If rejected:**
- Read rejection reason carefully
- Fix issues
- Resubmit or contact support@aspi-indonesia.or.id

---

### Action 6: Retrieve Credentials (5 minutes - AFTER APPROVAL)

**⚠️ ONLY AFTER application is APPROVED**

**In ASPI Portal:**

1. **Navigate to:** My Applications → [Your App Name]

2. **Find "Credentials" section or tab**

3. **You will see:**
   ```
   Partner ID: PARTNER-BI-XXXXX
   Client ID: abc123def456...
   Client Secret: xyz789uvw456...
   HMAC Secret Key: hmac_secret_...
   ```

4. **COPY each credential carefully**
   - Use copy button if available
   - Or triple-click to select all text
   - Paste into secure location

5. **Save credentials to secure file:**
   ```bash
   # Create secure directory
   mkdir -p ~/secure/aspi-credentials
   chmod 700 ~/secure/aspi-credentials

   # Copy template
   cp /home/user/AKBI/phase1_documents/05_credentials_storage_template.txt \
      ~/secure/aspi-credentials/credentials.txt

   # Edit and fill in credentials
   vim ~/secure/aspi-credentials/credentials.txt

   # Secure the file
   chmod 600 ~/secure/aspi-credentials/credentials.txt
   ```

**✅ SUCCESS:** All 4 credentials saved securely

**Verify credentials format:**
- Partner ID: Usually starts with "PARTNER-"
- Client ID: Long alphanumeric string (20-50 chars)
- Client Secret: Long alphanumeric string (20-50 chars)
- HMAC Secret: Alphanumeric string (32+ chars)

---

### Action 7: Prepare Authorization Request (45 minutes - WHILE WAITING)

**You can do this while waiting for application approval**

**1. Get approval from your BI supervisor**
   - Explain the testing purpose
   - Get written approval
   - Note approval date and reference

**2. Prepare Authorization Letter**
   - On Bank Indonesia official letterhead
   - Signed by authorized person
   - Reference the security assessment
   - Include test dates and scope

**3. Customize authorization request email**
   ```bash
   # Open template
   vim /home/user/AKBI/phase1_documents/03_authorization_request_email.txt
   ```

   **Fill in ALL fields marked with [brackets]:**
   - [Your Full Name]
   - [Your Title]
   - [your-email]@bi.go.id
   - [your-phone]
   - [Your Partner ID] (from Action 6)
   - [Your IP addresses]
   - [Test dates]
   - All other [bracketed fields]

**4. Review test plan**
   ```bash
   # Open test plan
   vim /home/user/AKBI/phase1_documents/04_test_plan_template.md
   ```

   **Customize if needed:**
   - Update dates
   - Update team members
   - Update contact information
   - Get it reviewed by your supervisor

**5. Gather required attachments:**
   - ✅ Authorization letter (PDF on BI letterhead)
   - ✅ Test plan (PDF, 3-5 pages)
   - ✅ Scope document (can use test plan)
   - ⬜ NDA (if ASPI requires - check first)

**✅ SUCCESS:** Authorization request email and attachments ready

---

### Action 8: Submit Authorization Request (10 minutes - AFTER CREDENTIALS)

**⚠️ ONLY AFTER you have credentials (Action 6 complete)**

**Send the email:**

1. **Open your email client**

2. **Compose new email:**
   - **To:** security@aspi-indonesia.or.id
   - **CC:** support@aspi-indonesia.or.id
   - **Subject:** Request for Penetration Testing Authorization - Bank Indonesia Security Assessment

3. **Copy email body from:**
   ```bash
   cat /home/user/AKBI/phase1_documents/03_authorization_request_email.txt
   ```

4. **Attach documents:**
   - Authorization letter (PDF)
   - Test plan (PDF)
   - Any other required documents

5. **Review checklist:**
   - ✅ All [bracketed] fields filled
   - ✅ Correct Partner ID included
   - ✅ Correct email addresses
   - ✅ All attachments added
   - ✅ Sent from official BI email
   - ✅ Professional tone

6. **Send email**

7. **Save sent email** for records

**✅ SUCCESS:** Authorization request submitted

**Track in progress:**
```bash
vim /home/user/AKBI/phase1_progress.md
# Note email sent date
# Check off: Submit Authorization Request
```

---

### Action 9: Wait for Authorization (3-5 business days - WAIT)

**What happens:**
- ASPI security team reviews request
- They may ask for clarification
- They will respond with approval or questions

**During waiting:**

**Check email daily for:**
- Acknowledgment email
- Questions from ASPI
- Authorization approval
- Emergency contact information

**If ASPI requests more information:**
- Respond promptly (within 24 hours)
- Provide clear, detailed answers
- Be professional and cooperative

**If approved:**
- ✅ Note approval date
- ✅ Note approved test window
- ✅ Note any restrictions
- ✅ Save emergency contact info
- ✅ Proceed to Action 10

---

### Action 10: Document Everything (15 minutes - AFTER AUTHORIZATION)

**Create documentation folder:**
```bash
mkdir -p ~/secure/aspi-authorization
chmod 700 ~/secure/aspi-authorization
```

**Save these files:**

1. **Approval Email**
   - Save as PDF
   - File: `aspi_authorization_approval.pdf`

2. **Authorization Letter**
   - Your original BI letter
   - File: `bi_authorization_letter.pdf`

3. **Test Window**
   - Create a text file:
   ```bash
   cat > ~/secure/aspi-authorization/test_window.txt << EOF
   Test Window Approved:
   Start: December 15, 2025 00:00 WIB
   End: December 30, 2025 23:59 WIB

   Scope:
   - Balance Inquiry API
   - Authentication testing
   - Authorization testing
   - Injection testing

   Restrictions:
   - Sandbox only
   - Max 100 req/min
   - Report critical findings within 24h
   EOF
   ```

4. **Emergency Contacts**
   ```bash
   cat > ~/secure/aspi-authorization/emergency_contacts.txt << EOF
   ASPI Emergency Contacts:
   Name: [from approval email]
   Phone: [from approval email]
   Email: security@aspi-indonesia.or.id

   Bank Indonesia Contacts:
   Primary: [your name] - [phone] - [email]
   Secondary: [backup name] - [phone] - [email]
   EOF
   ```

**Secure all files:**
```bash
chmod 600 ~/secure/aspi-authorization/*
```

**✅ SUCCESS:** All authorization documents saved securely

**Final progress update:**
```bash
vim /home/user/AKBI/phase1_progress.md
# Mark Step 8 as complete
# Update overall status
```

---

## ✅ PHASE 1 COMPLETION CHECKLIST

Before moving to Phase 2, verify:

- [x] ASPI portal account created and verified
- [x] Partner application created and approved
- [x] All 4 credentials obtained (Partner ID, Client ID, Client Secret, HMAC Secret)
- [x] Credentials saved securely (chmod 600)
- [x] Authorization request submitted
- [x] Authorization approval received
- [x] Test window confirmed
- [x] Scope documented
- [x] Emergency contacts saved
- [x] All documents organized

**If all checked:**
✅ **PHASE 1 COMPLETE!**
🎯 **Ready for PHASE 2: Configuration**

---

## 📞 NEED HELP?

### Portal Access Issues
**Problem:** Cannot access ASPI portal
**Contact:** support@aspi-indonesia.or.id
**Subject:** "Unable to access ASPI Developer Portal"

### Application Not Approved
**Problem:** Application pending > 3 business days
**Contact:** support@aspi-indonesia.or.id
**Subject:** "Application Status Inquiry - [Your App Name]"

### Authorization Delays
**Problem:** No response to authorization request > 5 days
**Contact:** security@aspi-indonesia.or.id
**Subject:** "Follow-up: Penetration Testing Authorization - Bank Indonesia"

### Questions About Process
**Contact:** support@aspi-indonesia.or.id
**Phone:** Check ASPI portal for support number

---

## 📊 TYPICAL TIMELINE

| Day | Activity | Status |
|-----|----------|--------|
| Day 0 | Register, create application | ✅ Your action |
| Day 1-3 | Wait for application approval | ⏸️ ASPI review |
| Day 3 | Get credentials, send auth request | ✅ Your action |
| Day 4-8 | Wait for authorization | ⏸️ ASPI review |
| Day 8 | Authorization approved! | ✅ |
| Day 8+ | Phase 2: Configuration | Next phase |

**Total:** ~8-10 business days from start to ready-to-test

---

## 🎯 WHAT'S NEXT?

**After Phase 1 is complete:**

1. **Proceed to Phase 2:** Configuration
   ```bash
   cat /home/user/AKBI/pentest/PHASE2_CONFIGURATION.md
   ```

2. **Estimated time for Phase 2:** 15 minutes

3. **Then Phase 3:** Run Tests
   ```bash
   cat /home/user/AKBI/pentest/PHASE3_RUN_TESTS.md
   ```

**You're on track to start security testing in ~10 business days!**

---

**Status:** Phase 1 Action Guide - Ready to Use
**Next Action:** Access ASPI portal and register NOW!
**File Location:** `/home/user/AKBI/PHASE1_QUICK_ACTION_GUIDE.md`
