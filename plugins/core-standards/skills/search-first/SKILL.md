---
name: search-first
description: Research-before-coding discipline. Search for existing tools, libraries, servers, and patterns before writing custom code.
triggers:
  - "Add X functionality" and code is about to be written
  - Adding a dependency or integration
  - Creating a new utility, helper, or abstraction
  - Starting a feature that likely has existing solutions
scope: All code that could reuse an existing solution
outputs: Adopt, extend, compose, or build decision with evidence
---

# Search First

> Custom code is the last resort. Search first.

## When to Apply

- Before writing a utility, helper, or integration
- Before adding a dependency
- Before creating a new abstraction
- Whenever a feature likely has existing solutions

## Must-Do Checklist

- [ ] Search the current repo for existing implementations
- [ ] Search package registries for the exact problem
- [ ] Search available tool servers / connectors if applicable
- [ ] Search GitHub / OSS for maintained solutions
- [ ] Apply the decision matrix before building

## Rules

### 1. Decision matrix

| Signal | Action |
|---|---|
| Exact match, well-maintained, permissive license | **Adopt** — install and use directly |
| Partial match, good foundation | **Extend** — install + thin wrapper |
| Multiple weak matches | **Compose** — combine 2–3 small packages |
| Nothing suitable | **Build** — custom, but informed by research |

### 2. Quick mode — always run first

1. Repo search — search relevant modules/tests; does it exist already?
2. Package search — registry search for the exact problem
3. Tool-server search — is there an existing connector for this?
4. OSS search — maintained open-source before writing net-new code

### 3. Full mode — for non-trivial functionality

If research requires significant effort, spawn a research subagent with:

- Description of the problem
- Language/framework
- Constraints
- Search targets: registries, tool servers, OSS
- Required output: structured comparison with recommendation

### 4. Search shortcuts

| Category | Top candidates |
|---|---|
| Linting | `eslint`, `ruff`, `markdownlint` |
| Formatting | `prettier`, `black`, `gofmt` |
| Testing | `jest`, `vitest`, `pytest`, `go test` |
| Pre-commit | `husky`, `lint-staged` |
| HTTP clients | `ky`/`got` (Node), `httpx` (Python) |
| Validation | `zod` (TS), `pydantic` (Python) |
| Markdown | `remark`, `unified`, `markdown-it` |
| Image | `sharp`, `imagemin` |
| Document parsing | `unstructured`, `pdfplumber`, `mammoth` |

### 5. Anti-patterns

- Writing a utility without checking if one exists in the repo first
- Skipping tool-server checks when the capability is a natural fit
- Wrapping a library so heavily it loses its benefits
- Installing a large package for a 5-line problem

## Verification Commands

- `grep -R "<functionality>" src/` — repo search
- Registry search command appropriate to the stack
- `ls` or manifest inspection to confirm dependency is installed

## Verdicts

- **ADOPT** — use an existing solution directly
- **EXTEND** — use an existing solution with a thin wrapper
- **COMPOSE** — combine existing solutions
- **BUILD** — no suitable existing solution; build custom code
