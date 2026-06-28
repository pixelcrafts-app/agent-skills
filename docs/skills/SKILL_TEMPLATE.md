# Pure Skill Template

Every skill in this repo must follow this template. A skill is a **self-contained instruction document** for an AI agent. It must not depend on any harness, tool, state file, or other skill.

---

## Required Frontmatter

```yaml
---
name: skill-name
description: One-line when-to-apply statement.
triggers:
  - Natural language trigger 1
  - Natural language trigger 2
scope: What files / situations this skill governs
outputs: What the agent must produce
---
```

## Section 1 — Identity

```markdown
# Skill Name

> One-sentence purpose.
```

## Section 2 — When to Apply

List the exact conditions. Use natural language, file patterns, stack detection, or user intent.

```markdown
## When to Apply

Apply this skill when:
- The user asks for ...
- You are editing files under `src/**/*.ts`
- The project uses NestJS (detected from `package.json`)
```

## Section 3 — Must-Do Checklist

Every skill must have a hard checklist. The AI must complete these steps.

```markdown
## Must-Do Checklist

- [ ] Step 1: Read the relevant files before changing them
- [ ] Step 2: Identify all consumers of the changed contract
- [ ] Step 3: Run the verification command: `npm run type-check`
- [ ] Step 4: Run the test command: `npm test`
- [ ] Step 5: Confirm no consumer imports are broken
```

## Section 4 — Rules

Concrete, numbered rules. Each rule must be enforceable by reading code.

```markdown
## Rules

1. Controllers contain no business logic.
2. Every request DTO uses class-validator decorators.
3. Services return DTOs, never raw database entities.
```

## Section 5 — Terminal Commands

List the exact commands the agent must run to verify compliance.

```markdown
## Verification Commands

```bash
npx tsc --noEmit
npm run lint
npm test
```
```

## Section 6 — Examples (Optional)

Good and bad code examples.

```markdown
## Examples

### ✅ Good

```ts
// example
```

### ❌ Bad

```ts
// example
```
```

## Section 7 — Verdict Semantics (if applicable)

```markdown
## Verdicts

- **PASS** — meets all rules
- **FAIL** — violates one or more rules
- **INFO** — suggestion, not enforced
```

---

## What Is Forbidden in a Pure Skill

| Forbidden | Why |
|-----------|-----|
| `.claude/...` paths | Harness-specific |
| `.kimi/...` paths | Harness-specific |
| `~/.kimi/skills/...` paths | Installation-specific |
| References to other skills | Skills must be independent |
| "Claude will..." / "Kimi will..." | Harness-specific actor |
| "Run `/slash-command`" | Claude-only |
| "The hook will block..." | Claude-only |
| "Write to state file X" | State-dependent |
| Vague prose without checkable criteria | Not enforceable |

## Allowed Generic Language

| Use | Example |
|-----|---------|
| "The agent..." | Generic actor |
| "You must..." | Direct instruction |
| "Read the file..." | Tool-agnostic |
| "Run the command..." | Tool-agnostic |
| "Before editing..." | Generic sequence |

---

## Example: Pure Version of a NestJS Skill

```markdown
---
name: nestjs-controllers
description: Apply when writing or reviewing NestJS controllers.
triggers:
  - "review this controller"
  - "create a new endpoint"
  - editing files under `src/**/*.controller.ts`
scope: NestJS controller files
outputs: Pass/fail verdict with file:line evidence
---

# NestJS Controllers

> Controllers handle HTTP. They must not contain business logic.

## When to Apply

Apply when editing or reviewing any file matching `*.controller.ts` in a NestJS project.

## Must-Do Checklist

- [ ] Read the controller file
- [ ] Verify all business logic is delegated to a service
- [ ] Verify every endpoint has a DTO for request/response
- [ ] Verify route params and query params use validated DTOs
- [ ] Run `npx tsc --noEmit`

## Rules

1. Controllers contain no business logic.
2. One controller per resource/domain concept.
3. Every endpoint accepts and returns a DTO.
4. Route params and query params are validated via DTOs.
5. HTTP status codes are explicit when non-default.

## Verification Commands

```bash
npx tsc --noEmit
npm run lint
```

## Verdicts

- **PASS** — controller follows all rules
- **FAIL** — controller violates one or more rules
```
