## Copilot Operational Instructions for `wmi-lite`

> Authoritative guide for AI-assisted and human contributors. Follow these steps for every change. This document embeds guardrails, workflow automation details, Jira integration patterns, testing & coverage expectations, and interactive prompt discipline.

---

### 1. Purpose
Provide a consistent, auditable, and DCO-compliant workflow for implementing changes (feature, bugfix, maintenance) in this Ruby gem while preserving repository integrity, release automation (Expeditor), and CI fidelity. All actions must proceed iteratively with explicit user confirmation.

---

### 2. Repository Structure (Concise Hierarchy)
```
./                     # Root of the Ruby gem project
  Gemfile              # Dependency declarations (groups: docs, test, debug)
  Rakefile             # Tasks: spec, style (Cookstyle/Rubocop), docs, default
  VERSION              # Source of gem version; updated by Expeditor automation
  wmi-lite.gemspec     # Gem specification (metadata, files, dependencies)
  CHANGELOG.md         # Human + Expeditor managed changelog
  README.md            # Usage and development overview
  CONTRIBUTING.md      # Contribution policies (do not modify without approval)
  CODE_OF_CONDUCT.md   # Behavior standards (protected)
  LICENSE              # Apache 2.0 license (protected – never alter)
  .rspec               # RSpec CLI configuration (formatter, color)
  .rubocop.yml         # Lint/style configuration (Cookstyle compatible)
  .expeditor/          # Expeditor release automation config & scripts
    config.yml         # Defines version bump, changelog, publish pipelines
    update_version.sh  # Syncs bumped VERSION into code
  .github/
    CODEOWNERS         # Ownership & review attribution (protected)
    PULL_REQUEST_TEMPLATE.md  # Base human PR template (augmented by AI HTML)
    dependabot.yml     # Dependency updates config
    workflows/         # GitHub Actions CI workflows
      lint.yml         # Cookstyle (Rubocop) lint workflow
      unit-test.yml    # Cross-Ruby (3.1, 3.4) Windows unit tests
  lib/
    wmi-lite.rb        # Gem entrypoint requiring internal WMI wrapper
    wmi-lite/
      version.rb       # Ruby constant defining VERSION
      wmi_exception.rb # Custom exception class(es)
      wmi_instance.rb  # WMI instance abstraction wrapper
      wmi.rb           # Core WMI interaction logic (WIN32OLE usage)
  spec/
    spec_helper.rb     # RSpec test setup
    unit/              # Isolated, mocked unit specs
      wmi_spec.rb
    functional/        # Windows environment functional tests
      wmi_spec.rb
```
Excluded (none present): vendor/, node_modules/, build/, dist/, coverage/.

Protected: `LICENSE`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `.expeditor/*`, `.github/workflows/*`, `CODEOWNERS` (do not modify unless explicitly instructed).

---

### 3. Tooling & Ecosystem
| Aspect | Details |
|--------|---------|
| Language | Ruby (CI matrices include 3.1 and 3.4) |
| Test Framework | RSpec (`spec/**/*_spec.rb`) |
| Lint / Style | Cookstyle (Chef-flavored Rubocop) via `rake style` & `lint.yml` workflow |
| Coverage | SimpleCov available (in debug group). Enable by requiring `simplecov` at spec start if adding coverage gates. Maintain > 80% line coverage (policy here). |
| Release Automation | Expeditor (`.expeditor/config.yml`) handles version bump, changelog rollup, gem publishing post-merge based on labels. |
| CI Workflows | `lint.yml` (on PR + push to main) and `unit-test.yml` (on push & PR). |
| Docs | YARD (`rake docs`). |
| PR Template | `.github/PULL_REQUEST_TEMPLATE.md` (augmented with HTML summary per this doc). |
| Ownership | `CODEOWNERS` governs review routing. |

---

### 4. MCP Jira Integration (atlassian-mcp-server)
Used when a Jira issue ID (e.g., ABC-123) is supplied. Always fetch and plan before coding.

Standard Interaction Pattern:
1. Collect Jira ID input.
2. Invoke MCP (pseudo-call): `atlassian-mcp-server:getIssue <JIRA_ID>`.
3. Parse fields: summary, description, acceptance criteria (AC), linked issues, story points (if present), labels.
4. Construct Plan Object:
   - Design / Change Summary
   - Impacted Files (existing/new)
   - Test Strategy (unit + functional where applicable)
   - Edge Cases & Negative Paths
   - Risk & Mitigations
5. Present plan and ask: `Continue to implementation? (yes/no)`.
6. On yes: proceed with branch creation & incremental commits.

If NO Jira ID: treat as freeform task; still produce a structured plan & confirm.

Never proceed to code changes without explicit confirmation.

---

### 5. Workflow Overview (Canonical Lifecycle)
1. Intake & Clarify (Jira fetch if ID provided)
2. Analyze Repo (structure, constraints)
3. Plan Implementation (design + tests)
4. Confirm Plan
5. Implement Incrementally (branch per Jira ID or slug)
6. Add / Update Tests (unit + functional where relevant)
7. Run Lint & Tests (ensure >80% coverage)
8. Commit (DCO sign-off enforced)
9. Push branch
10. Create PR (HTML formatted description) & apply labels
11. Monitor CI (re-run or fix)
12. Summarize & Await Merge (do not merge automatically)

Every major step ends with:
```
Step Summary
Remaining Steps Checklist (with [x]/[ ])
Continue to next step? (yes/no)
```

---

### 6. Detailed Step Instructions
#### 6.1 Intake & Clarify
Prompt user (or self if autonomous session) for Jira ID or freeform problem statement. If Jira ID: perform MCP fetch.

#### 6.2 Analysis
Enumerate impacted components. Confirm no protected files require modification (if they do, halt and request approval).

#### 6.3 Plan
Produce structured plan (Design, Files, Tests, Edge Cases, Risks). Ask for confirmation.

#### 6.4 Branch Creation
Branch naming:
* If Jira ID: exactly `<JIRA_ID>` (e.g., `ABC-123`).
* Else: kebab-case slug (e.g., `improve-wmi-timeouts`).

Commands:
```bash
git fetch origin
git checkout -b ABC-123 origin/main   # or slug branch
```

Idempotency: If branch exists locally or remotely, reuse it (`git checkout ABC-123`).

#### 6.5 Implementation (Incremental)
Apply smallest coherent change set. Avoid unrelated refactors. Keep public API stable unless requirement demands change.

#### 6.6 Tests
Add/update unit specs under `spec/unit/`. For Windows-specific runtime behavior, update/extend `spec/functional/` with guards.
Coverage Target: > 80% line coverage across changed files. If below:
1. Identify untested lines (SimpleCov report).  
2. Add focused specs.  
3. Re-run until threshold met.

#### 6.7 Quality Checks
```bash
bundle install --jobs 4 --retry 3
rake style
rake spec
```
Optional coverage (if you add SimpleCov start in `spec_helper.rb`):
```bash
OPEN_COVERAGE=1 rake spec  # (Example flag if implemented; ensure instructions updated if you formalize)
```

#### 6.8 Commit (DCO Required)
Commit message format:
```
<Concise imperative subject> (ABC-123)

<Optional body detailing rationale, context, testing>

Signed-off-by: Full Name <email@example.com>
```
Refuse to proceed if sign-off missing. One logical change per commit when feasible.

#### 6.9 Push & PR
```bash
git push -u origin ABC-123
```
Create PR:
```bash
gh pr create --title "ABC-123: Short subject" --head ABC-123 --base main --draft --fill
```
Then update description (see Section 8) injecting HTML template.

#### 6.10 Labels
Apply relevant labels (see Labels Reference). For Expeditor bumping: apply one of: `Expeditor: Bump Version Major`, `Expeditor: Bump Version Minor`, or omit for patch.

#### 6.11 CI Monitoring
Re-run failed jobs:
```bash
gh run list --limit 5
gh run rerun <run-id>
```
Fix failures; never override by disabling tests.

#### 6.12 Completion
Summarize diff stats, coverage delta, risks mitigated. Await human merge; do **not** merge automatically. Expeditor handles version/changelog after merge.

---

### 7. Branching & PR Standards
| Item | Rule |
|------|------|
| Branch Name | Jira ID or slug (lowercase-kebab) |
| One PR Scope | Single feature/fix; avoid mixed concerns |
| Draft PR | Used until tests + lint pass & coverage ≥ 80% |
| Final PR | All checks green, description HTML complete, labels applied |
| Merge Strategy | Standard merge or squash (avoid rebase merges unless policy dictates). Expeditor expects normal merge to trigger subscriptions |
| Force Push | Discouraged after reviews begin; only to fix commits while retaining DCO |

Required PR Description HTML Template:
```html
<h2>Summary</h2>
<p><!-- High-level explanation --></p>
<h2>Jira</h2>
<p><a href="https://jira.example.com/browse/ABC-123">ABC-123</a></p>
<h2>Changes</h2>
<ul>
  <li>Code modifications summarized</li>
  <li>New/updated files listed</li>
  <li>Tests added/updated</li>
</ul>
<h2>Tests & Coverage</h2>
<p>Coverage: BEFORE xx.xx% → AFTER yy.yy% (Δ +z.zz%)</p>
<h2>Risk & Mitigations</h2>
<ul><li>Risk: ... Mitigation: ...</li></ul>
<h2>DCO</h2>
<p>All commits signed off.</p>
```

---

### 8. Commit & DCO Policy
Every commit MUST end with a valid Developer Certificate of Origin sign-off line:
```
Signed-off-by: Full Name <email@domain>
```
Reject or amend commits lacking this line. Do not fabricate identity information.

Amending missing sign-off:
```bash
git commit --amend -s
git push -f origin ABC-123
```

---

### 9. Testing & Coverage Enforcement
1. Run spec suite: `rake spec`.
2. Ensure added/changed lines are covered (write targeted specs first for complex logic—mock WIN32OLE interactions where needed).
3. If coverage < 80%:
   - Identify uncovered lines in `coverage/index.html` (if enabled).
   - Add minimal specs; re-run.
4. Never delete tests to inflate coverage.

Edge Cases to Test (when relevant):
* Empty WMI query results
* Multiple result sets & property casing tolerances
* Invalid namespace / invalid query exceptions
* Windows-specific environment differences (functional specs)

---

### 10. Labels Reference (Repository-Specific + Generic Mapping)
Repository labels fetched via GitHub API (snapshot):

Aspect / Quality Dimensions:
* Aspect: Documentation – How do we use this project?
* Aspect: Integration – Interoperability with other systems.
* Aspect: Packaging – Distribution artifacts.
* Aspect: Performance – Efficiency impacts.
* Aspect: Portability – Platform support validation.
* Aspect: Security – Stability vs third-party threats.
* Aspect: Stability – Consistent results.
* Aspect: Testing – Coverage / CI health.
* Aspect: UI – Interaction & visual design.
* Aspect: UX – Overall user experience.

Expeditor / Release Control:
* Expeditor: Bump Version Major – Triggers major version bump.
* Expeditor: Bump Version Minor – Triggers minor version bump.
* Expeditor: Skip All – Skips all merge actions.
* Expeditor: Skip Changelog – Skips changelog update.
* Expeditor: Skip Habitat – Skips Habitat package build.
* Expeditor: Skip Omnibus – Skips Omnibus release build.
* Expeditor: Skip Version Bump – Prevents version bump.

Community & Meta:
* hacktoberfest-accepted – Counts toward Hacktoberfest.
* oss-standards – OSS standardization work.

Platform Focus:
* Platform: AWS / Azure / GCP / Docker / VMware / Linux / macOS / Debian-like / RHEL-like / SLES-like / Unix-like

Generic Suggested Mapping (apply when appropriate):
* bug – Use with issue classification (if exists) and possibly `Aspect: Stability`.
* enhancement / feature – Pair with `Aspect: Performance` or `Aspect: UX` as relevant.
* documentation – Pair with `Aspect: Documentation`.
* chore / maintenance – Internal refactor or dependency update.
* test – Pair with `Aspect: Testing`.
* ci – Infra or workflow changes (NEVER modify without approval).
* security – Pair with `Aspect: Security`.

Label Strategy:
* Always include at least one Aspect label + one scope label (feature/bug/chore) where meaningful.
* Only one Expeditor version bump label at a time.

---

### 11. CI & Expeditor Integration
#### GitHub Actions Workflows
1. `lint.yml`
   - Triggers: push (main), pull_request
   - Purpose: Enforces style / lint via Cookstyle (Rubocop).
   - Concurrency: cancels in-progress same-ref runs.
2. `unit-test.yml`
   - Triggers: push, pull_request
   - Matrix: Ruby 3.1 & 3.4 on Windows
   - Purpose: Unit tests for functional correctness; includes Windows-specific behavior.

Status Checks: Ensure both workflows succeed before finalizing PR.

#### Expeditor (`.expeditor/config.yml`)
Automations triggered on PR merge (into release branch, typically `main`):
* Version bump (unless skipped by labels) – patch by default; minor/major via labels.
* Update `VERSION` via `update_version.sh`.
* Update changelog.
* Build gem.
* Publish pipeline on promotion triggers gem release & changelog rollover.

NEVER manually edit `VERSION`.

---

### 12. Security & Protected Files
DO NOT modify without explicit instruction:
* `LICENSE`
* `CODE_OF_CONDUCT.md`
* `CONTRIBUTING.md`
* `.github/workflows/*`
* `.expeditor/*`
* `CODEOWNERS`

Never:
* Expose or alter secrets/tokens.
* Commit large binaries or credential material.
* Force-push to `main`.
* Merge.

If a change appears to require CI or Expeditor modifications, pause and request explicit approval.

---

### 13. Prompts Pattern (Interactive Model)
All AI-assisted steps must follow this output contract:
```
<Concise Step Summary>
Remaining Steps:
[x] Intake & Clarify
[x] Plan (example marking)
[ ] Implement
[ ] Tests
[ ] Lint & Coverage
[ ] Commit & PR
[ ] Final Summary

Continue to next step? (yes/no)
```
If user answers `yes`, proceed to the next logical step. If `no`, halt and request clarification.

Always re-assess idempotency (existing branch, open PR, partial diff) before repeating actions.

---

### 14. Environment Preparation
Prerequisites:
* Ruby 3.1+ (align with CI matrix; optionally test against 3.4 locally if available)
* Bundler
* GitHub CLI (`gh`) authenticated (do NOT reference shell profile paths; follow `gh auth login` interactive flow)

Setup:
```bash
gem install bundler
bundle install --jobs 4 --retry 3
rake style          # Lint (Cookstyle)
rake spec           # Run tests
rake docs           # Generate YARD documentation (optional)
```
Optional (coverage instrumentation—add SimpleCov start block in `spec_helper.rb` if not already present):
```bash
rake spec
open coverage/index.html  # Inspect coverage
```

Windows Functional Tests: Run them only on Windows environments; they are tagged `:windows_only`.

---

### 15. Validation & Exit Criteria
A task is considered COMPLETE when:
* [ ] Plan approved (user confirmation captured)
* [ ] Branch created with correct naming convention
* [ ] Code changes implemented (scoped & minimal)
* [ ] New/updated tests added covering changes
* [ ] Lint passes locally + CI green (`lint.yml`)
* [ ] Tests pass locally + CI green (`unit-test.yml`)
* [ ] Coverage ≥ 80% overall and no significant drop in changed files
* [ ] Commits properly DCO signed
* [ ] PR created with HTML description template filled
* [ ] Appropriate labels applied (including Expeditor bump label if needed)
* [ ] Risk assessment documented
* [ ] Final interactive summary issued & user acknowledges completion

If any criterion fails, iterate until satisfied before declaring completion.

---

### 16. Idempotency Guidelines
On re-run:
* If branch exists locally: checkout instead of recreating.
* If remote branch exists: pull latest before continuing.
* If PR already open: update PR instead of creating a new one.
* If coverage instrumentation added previously, avoid duplicating configuration.

---

### 17. Coverage Instrumentation (If Expanding)
To formalize coverage, you may add at top of `spec/spec_helper.rb`:
```ruby
require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end
```
Commit this change only if project maintainers approve raising enforcement standards.

---

### 18. Safeguards Recap
| Action | Allowed? | Notes |
|--------|----------|-------|
| Modify core library code | Yes | Must add/update tests |
| Modify protected policy/license files | No | Requires explicit approval |
| Adjust CI workflows | No | Approval + justification needed |
| Add new dependency | Caution | Justify minimal necessity |
| Remove tests | Rare | Only if obsolete; replace coverage |
| Force push | Avoid | Only for DCO fix pre-review |

---

### 19. Quick Reference Commands
```bash
# Start feature
git checkout -b ABC-123 origin/main

# Lint & test
rake style && rake spec

# Commit with DCO
git add .
git commit -m "Fix WMI query edge case (ABC-123)" -s

# Push & PR
git push -u origin ABC-123
gh pr create --title "ABC-123: Fix WMI query edge case" --head ABC-123 --base main --draft --fill

# Apply labels
gh label list         # Inspect (if needed)
gh pr edit --add-label "Aspect: Stability" --add-label "bug"

# Re-run CI (if failing)
gh run list --limit 5
gh run rerun <run-id>
```

---

### 20. Failure Handling & Recovery
| Failure Type | Response |
|--------------|----------|
| Lint errors | Fix per Cookstyle output; avoid disabling cops unless justified |
| Failing unit test | Reproduce locally; add missing mocks for WIN32OLE as needed |
| Coverage drop | Add focused tests for unexecuted branches |
| CI workflow transient failure | Retry via `gh run rerun`; escalate if persistent |
| Merge conflict after rebasing main | Resolve carefully; re-run tests before push |

---

### 21. Example Interactive Step Output (Pattern)
```
Summary: Plan generated for ABC-123 (adds error handling in wmi.rb, +3 specs)
Remaining Steps:
[x] Intake & Clarify
[x] Plan
[ ] Implement
[ ] Tests
[ ] Lint & Coverage
[ ] Commit & PR
[ ] Final Summary

Continue to next step? (yes/no)
```

---

### 22. Final Notes
* Always prioritize minimal, test-backed changes.
* Do not attempt release tagging manually; Expeditor handles post-merge automation.
* Coverage improvements are welcome even if not required by a feature request.
* When uncertain, pause and request clarification instead of guessing.

## AI-Assisted Development & Compliance

- ✅ Create PR with `ai-assisted` label (if label doesn't exist, create it with description "Work completed with AI assistance following Progress AI policies" and color "9A4DFF")
- ✅ Include "This work was completed with AI assistance following Progress AI policies" in PR description

### Jira Ticket Updates (MANDATORY)

- ✅ **IMMEDIATELY after PR creation**: Update Jira ticket custom field `customfield_11170` ("Does this Work Include AI Assisted Code?") to "Yes"
- ✅ Use atlassian-mcp tools to update the Jira field programmatically
- ✅ **CRITICAL**: Use correct field format: `{"customfield_11170": {"value": "Yes"}}`
- ✅ Verify the field update was successful

### Documentation Requirements

- ✅ Reference AI assistance in commit messages where appropriate
- ✅ Document any AI-generated code patterns or approaches in PR description
- ✅ Maintain transparency about which parts were AI-assisted vs manual implementation

### Workflow Integration

This AI compliance checklist should be integrated into the main development workflow Step 4 (Pull Request Creation):

```
Step 4: Pull Request Creation & AI Compliance
- Step 4.1: Create branch and commit changes WITH SIGNED-OFF COMMITS
- Step 4.2: Push changes to remote
- Step 4.3: Create PR with ai-assisted label
- Step 4.4: IMMEDIATELY update Jira customfield_11170 to "Yes"
- Step 4.5: Verify both PR labels and Jira field are properly set
- Step 4.6: Provide complete summary including AI compliance confirmation
```

- **Never skip Jira field updates** - This is required for Progress AI governance
- **Always verify updates succeeded** - Check response from atlassian-mcp tools
- **Treat as atomic operation** - PR creation and Jira updates should happen together
- **Double-check before final summary** - Confirm all AI compliance items are completed

### Audit Trail

All AI-assisted work must be traceable through:

1. GitHub PR labels (`ai-assisted`)
2. Jira custom field (`customfield_11170` = "Yes")
3. PR descriptions mentioning AI assistance
4. Commit messages where relevant
