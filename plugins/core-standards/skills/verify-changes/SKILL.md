---
name: verify-changes
description: Apply when the user asks to verify or audit a set of changes across any stack.
triggers:
  - "verify my changes"
  - "cross-check before confirming"
  - "audit what I did"
  - Before a commit or PR
scope: Any set of changed files in any codebase
outputs: A consolidated report with pass/fail findings and a SAFE/BLOCK verdict
---

# Verify Changes

> Cross-stack verification: reads the installed skill standards and applies them to changed files. Pure prompt workflow — no state, no hooks.

## Checklist

- [ ] Confirm scope/dimensions/depth · list changed files · build the consumer graph · run project tools · apply skill rules in batches · cite `file:line` for every finding · produce a verdict.

## Workflow

1. **Scope dialogue (don't guess).** Ask three things — **scope** (uncommitted / last N commits / path / area), **dimensions** (ALL / specific / SMART auto-pick), **depth** (direct / +consumers / full ripple). Default on "just go": uncommitted + SMART + direct+consumers; echo defaults before proceeding.
2. **List changed files.** `git status --short` + `git diff --name-status` (or `git log -n N --name-status` / Glob / ask). Codes: `M` verify · `A` new · `D` search for remaining refs · `R` check old refs + new file · `??` include if uncommitted. Exclude build output/lockfiles/binaries.
3. **Build the dependency graph** — for each changed file find direct consumers via the stack's import patterns; record `file → consumer` (one more level only if full ripple).
4. **Flag high-blast-radius** changes (removed/renamed export, changed signature, ORM schema, env var name, shared type/DTO, public route) → verify *every* consumer, not a sample.
5. **Run project tools first** (type-check/lint/tests from the manifest, scoped to changes). A tool FAIL is authoritative — judgment can't override it to PASS.
6. **Apply standards in batches** by stack+dimension: read only the batch files, load only that dimension's standard, iterate rule×file → {rule, evidence `path:line` or "no occurrence", verdict PASS/FAIL/N/A/INFO/REVIEW/CONFLICT, fix on FAIL}. Never skip a rule as "unrelated" (record N/A + reason); collect all FAILs, don't stop at the first.
7. **Stop and report mid-run** if: hardcoded secret found · protected route lost auth · env var reference gone · migration has `DROP COLUMN`/`DROP TABLE`/new `NOT NULL` without default · a breaking signature will break a consumer · scope is expanding uncontrollably.
8. **Fix loop (if asked)**: walk FAILs critical → consumer-break → polish; smallest fix; re-verify that pair; cap 3 attempts then mark stuck.

## Report & verdict

Report: scope/dimensions/depth, totals (files, PASS/FAIL), **critical failures** (file:line — rule — evidence — fix), polish failures, consumer impact, unverified/skipped + reason.

- **SAFE TO COMMIT** — 0 critical + 0 consumer-break
- **COMMIT IF DELIBERATE** — polish only
- **BLOCK** — any critical or consumer-break

## Commands

`git status --short` / `git diff --name-status` · manifest type-check/lint · `grep -R "import.*<symbol>" src/` (consumers) · `grep -n "TODO\|FIXME\|secret\|password" <files>` (sweep).
