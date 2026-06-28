---
name: architecture-decision-records
description: Detect architectural decisions in conversation and capture them as structured ADRs. Auto-triggers on trade-off comparisons, "we decided to" statements, and explicit "ADR this" requests.
origin: ECC
---

# Architecture Decision Records

## Triggers

- **Auto-capture (confirm before writing):** choosing between frameworks/databases/libraries/patterns · "we decided to…" / "X instead of Y because…" · a trade-off analysis that reaches a conclusion.
- **Explicit:** "ADR this" / "record this decision" → write after confirmation.
- **Read:** "why did we choose X?" → scan `docs/adr/README.md`, return Context + Decision.

## Format

```markdown
# ADR-NNNN: <title>
**Date** YYYY-MM-DD · **Status** proposed|accepted|deprecated|superseded by ADR-NNNN · **Deciders** <who>
## Context        <constraint/force driving it — ≤8 lines; longer = two decisions>
## Decision       <present tense: "We use X">
## Alternatives Considered   <each: Pros / Cons / Rejected because>
## Consequences   Gains / Trade-offs / Risks
```

## Workflow

1. Extract the core choice + the constraints that ruled out alternatives.
2. Draft the ADR and present it **before writing any file**.
3. On approval: scan `docs/adr/` for the next number → write `docs/adr/NNNN-title.md` → append a row to `docs/adr/README.md` (`| ADR | Title | Status | Date |`).
4. On rejection: discard, no files. First time: if `docs/adr/` doesn't exist, ask before creating.

## Rules

| Signal | Rule |
|---|---|
| Magnitude | Record frameworks, DBs, patterns, auth, infra. Skip naming/formatting. |
| Specificity | "Use Prisma ORM", not "use an ORM" |
| Rationale | *Why* > *what* — never omit alternatives |
| Tense | present ("We use X") |
| Superseded | always link the replacement — never delete |

Lifecycle: `proposed → accepted → deprecated | superseded by ADR-NNNN`. Categories worth an ADR: technology, architecture (monolith vs microservices, CQRS), API (REST vs GraphQL, versioning, auth), data (schema, caching), infra (CI/CD, deploy, monitoring), security, testing strategy.
