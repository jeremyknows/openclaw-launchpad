# ClawStarter Security Fix Plan

**Status:** 🔴 BLOCK RELEASE  
**Created:** 2026-02-11 15:14 EST  
**Estimated Total Time:** 12-16 hours  
**Team:** Security specialists + verification agents

---

## Executive Summary

**3 comprehensive reviews completed:**
- **Security Audit:** 5 CRITICAL, 5 HIGH issues — 🔴 BLOCK RELEASE
- **UX Review:** 75% ready, minor improvements needed
- **Edge Cases:** 10 critical failure modes — 🔴 Medium-High Risk

**Verdict:** Script is NOT ready for beta testers. Security issues must be fixed first.

---

## Phase 1: CRITICAL Security Fixes (Priority 1)
**Estimated Time:** 6-8 hours  
**Must complete before ANY beta testing**

### 1.1 API Key Security
**Issue:** Keys exposed in process environment (`ps e`)  
**Fix:** Use secure keychain storage or encrypted config  
**Agent:** security-fix-api-keys  
**Verification:** Test `ps e` during install, confirm no leaked secrets  
**Time:** 2-3 hours

### 1.2 Command Injection Prevention
**Issue:** User input (bot name, model) passed unsanitized to Python heredoc  
**Fix:** Escape all user input, validate against allowed patterns  
**Agent:** security-fix-injection  
**Verification:** Attempt injection attacks (`'; rm -rf /`, `$(whoami)`)  
**Time:** 2 hours

### 1.3 Config File Race Condition
**Issue:** API keys written before `chmod 600` applied  
**Fix:** Create file with 600 permissions FIRST, then write  
**Agent:** security-fix-race-condition  
**Verification:** Monitor file permissions during write  
**Time:** 1 hour

### 1.4 Template Download Verification
**Issue:** No checksum/signature validation from GitHub  
**Fix:** Add SHA256 verification for downloaded files  
**Agent:** security-fix-checksums  
**Verification:** Test with modified templates (should reject)  
**Time:** 2 hours

### 1.5 LaunchAgent Plist Injection
**Issue:** Unsanitized `$HOME` variable in plist  
**Fix:** Validate $HOME, escape XML entities  
**Agent:** security-fix-plist  
**Verification:** Test with malicious $HOME values  
**Time:** 1 hour

---

## Phase 2: HIGH Priority Fixes (Priority 2)
**Estimated Time:** 4-5 hours  
**Complete before public beta**

### 2.1 Cleanup on Failure
**Issue:** Leaked secrets, partial installs remain on failure  
**Fix:** Add trap handlers for ERR and EXIT  
**Agent:** fix-cleanup-handlers  
**Verification:** Ctrl+C mid-install, verify rollback  
**Time:** 2 hours

### 2.2 Input Validation
**Issue:** URL validation missing in `open` commands  
**Fix:** Validate URLs before executing `open`  
**Agent:** fix-url-validation  
**Verification:** Test with malicious URLs  
**Time:** 1 hour

### 2.3 Secure Defaults
**Issue:** Gateway token displayed in plaintext (shell history)  
**Fix:** Never echo secrets, use secure generation  
**Agent:** fix-secure-defaults  
**Verification:** Check `.zsh_history` for leaked tokens  
**Time:** 1 hour

### 2.4 Dependency Verification
**Issue:** Homebrew and OpenClaw install scripts executed blindly  
**Fix:** Add warning + confirmation before curl-to-bash  
**Agent:** fix-dependency-verification  
**Verification:** User sees clear warning before executing  
**Time:** 1 hour

---

## Phase 3: Edge Case Hardening (Priority 3)
**Estimated Time:** 3-4 hours  
**Complete before wide release**

### 3.1 Pre-Flight Checks
**Issue:** No validation of internet, disk space, ports  
**Fix:** Check requirements before installation starts  
**Agent:** fix-preflight-checks  
**Time:** 2 hours

### 3.2 Signal Handlers
**Issue:** Ctrl+C leaves partial state  
**Fix:** Add SIGINT/SIGTERM handlers for clean shutdown  
**Agent:** fix-signal-handlers  
**Time:** 1 hour

### 3.3 Idempotency
**Issue:** Running twice duplicates content  
**Fix:** Detect existing installation, offer upgrade path  
**Agent:** fix-idempotency  
**Time:** 1-2 hours

---

## Phase 4: UX Polish (Priority 4)
**Estimated Time:** 2-3 hours  
**Can ship without, but recommended**

### 4.1 Error Recovery
**Issue:** One typo = restart entire script  
**Fix:** Allow user to go back, confirm before proceeding  
**Agent:** fix-error-recovery  
**Time:** 1 hour

### 4.2 Jargon Simplification
**Issue:** "API key", "sandbox", "LaunchAgent" unexplained  
**Fix:** Add tooltips/explanations for technical terms  
**Agent:** fix-jargon  
**Time:** 30 min

### 4.3 Success Clarity
**Issue:** Dashboard URL shown but purpose unclear  
**Fix:** Explicit "What to do now" steps  
**Agent:** fix-success-message  
**Time:** 30 min

### 4.4 Title Accuracy
**Issue:** Says "2 Questions" but asks 3  
**Fix:** Update all references to "3 Questions"  
**Agent:** ALREADY FIXED ✅  
**Time:** 0 min

---

## Execution Strategy

### Parallel Work Streams
**Stream A (Security Core):**
- Phase 1.1, 1.2, 1.3 (API keys, injection, race condition)
- 3 agents working in parallel

**Stream B (Security Validation):**
- Phase 1.4, 1.5 (checksums, plist)
- 2 agents working in parallel

**Stream C (Hardening):**
- Phase 2 (cleanup, validation, secure defaults)
- After Stream A/B complete

**Stream D (Polish):**
- Phase 3 & 4 (edge cases, UX)
- After Stream C complete

### Verification Protocol
**For EACH fix:**
1. Agent implements fix
2. Second agent attempts to break it (adversarial testing)
3. Third agent reviews code changes
4. Manual verification by Jeremy (for CRITICAL issues)

### Progress Tracking
- [ ] Phase 1: CRITICAL (0/5 complete)
- [ ] Phase 2: HIGH (0/4 complete)
- [ ] Phase 3: Edge Cases (0/3 complete)
- [ ] Phase 4: UX Polish (1/4 complete)

---

## Risk Assessment

**Current State:**
- 🔴 **Security:** Unacceptable for any release
- 🟡 **UX:** Good enough for closed beta (with fixes)
- 🔴 **Reliability:** Too many failure modes

**After Phase 1 (CRITICAL):**
- 🟢 **Security:** Acceptable for closed beta with trusted testers
- 🟡 **UX:** Same
- 🟡 **Reliability:** Improved but still risky

**After Phase 2 (HIGH):**
- 🟢 **Security:** Acceptable for public beta
- 🟢 **UX:** Ready for non-technical users
- 🟡 **Reliability:** Most edge cases handled

**After Phase 3+4 (Complete):**
- 🟢 **Security:** Production-ready
- 🟢 **UX:** Production-ready
- 🟢 **Reliability:** Production-ready

---

## Timeline

**Optimistic (Full team, no blockers):**
- Phase 1: 2-3 days
- Phase 2: 1 day
- Phase 3: 1 day
- Phase 4: Half day
- **Total:** 4.5-5.5 days

**Realistic (Serial work, verification delays):**
- Phase 1: 4-5 days
- Phase 2: 2 days
- Phase 3: 1-2 days
- Phase 4: 1 day
- **Total:** 8-10 days

**Conservative (Blockers, redesigns):**
- Phase 1: 1 week
- Phase 2: 3-4 days
- Phase 3: 2-3 days
- Phase 4: 1-2 days
- **Total:** 2-2.5 weeks

---

## Recommendation

**Ship Timeline:**
1. **Phase 1 ONLY** → Closed beta with 3 trusted testers (Courtney, Kowski, Jeremy)
2. **Phase 1+2** → Public beta announcement
3. **Phase 1+2+3** → Wide release, social media promotion
4. **All phases** → Production-ready, documentation site

**Next Steps:**
1. Deploy security fix team (5 agents)
2. Start with Phase 1.1 (API key security) - highest risk
3. Verify each fix with adversarial testing
4. Jeremy reviews critical security changes before merge

---

**This is the foundation. We get it right.**
