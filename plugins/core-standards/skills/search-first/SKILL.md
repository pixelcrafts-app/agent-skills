---
name: search-first
description: Apply before creating utilities, helpers, abstractions, integrations, dependencies, or non-trivial features that may already exist. Search local code and installed capabilities first; use external package or OSS research only when it can materially reduce complexity or risk.
triggers:
  - "Add X functionality" and code is about to be written
  - Adding a dependency or integration
  - Creating a new utility, helper, or abstraction
  - Starting a feature that likely has existing solutions
scope: Code that could reuse local code, stdlib/native features, installed dependencies, tools, or a justified new dependency
outputs: Reuse, use installed, build local, or adopt dependency decision with evidence
---

# Search First

> Reuse first. Build small. Add dependencies last.

## When to Apply

- Before writing a utility, helper, or integration
- Before adding a dependency
- Before creating a new abstraction
- Whenever a feature likely has existing solutions

## Priority

Research must reduce code, risk, or maintenance burden. Do not add a package just because one exists. For small obvious changes, a repo search plus installed-dependency check is enough.

## Search Ladder

1. Search the current repo with `rg` for existing helpers, tests, components, commands, or patterns.
2. Inspect manifests and imports for already-installed dependencies or framework/native features.
3. Use stdlib or platform features when they are clear, correct, and already available.
4. Build local code when the solution is small, readable, and lower-risk than a dependency.
5. Do external registry/OSS research only for new dependencies, integrations, protocols, parsers, security-sensitive code, complex algorithms, or broadly reusable abstractions.
6. Add a new dependency only when it clearly beats local code on correctness, maintenance, security, and total complexity.

## Decision Matrix

| Signal | Decision |
|---|---|
| Existing project code fits | **REUSE** — call or adapt it in place |
| Stdlib, native feature, or installed dependency fits | **USE INSTALLED** — no new dependency |
| Solution is small and project-specific | **BUILD LOCAL** — keep it boring and tested |
| New dependency is clearly safer or simpler overall | **ADOPT** — install with version, license, and maintenance rationale |
| Only multiple weak new packages fit | **BUILD LOCAL** or ask before adding dependency chain |
| Nothing suitable | **BUILD LOCAL** — informed by patterns found |

## External Research Gate

Before external package or OSS research, confirm at least one is true:

- The user asked to add or compare dependencies.
- The feature is an integration, protocol, parser, file format, auth/security primitive, or complex algorithm.
- The implementation would otherwise create a reusable subsystem or substantial custom code.
- The project already uses a nearby dependency family and extending it may be smaller.

When adopting a dependency, verify maintenance, license, package size or footprint, API stability, security posture, and fit with the existing stack.

## Anti-Patterns

- Searching package registries before checking the repo.
- Installing a library for a small helper the project can own safely.
- Combining multiple new packages to avoid writing a small clear function.
- Creating a wrapper so thick that the dependency no longer reduces code.
- Rebuilding protocol, crypto, parsing, or file-format logic without checking proven options.

## Output

For implementation: mention only the decision that affected the diff, such as reused existing helper, used installed dependency, built local because it was smaller, or adopted a dependency with rationale.

For review: report missed reuse or unnecessary dependency findings with `file:line` evidence and the smaller replacement.

## Verification Commands

- `rg "<concept|function|type>" .` — repo search
- Inspect the project manifest and lockfile for installed dependencies
- Use the registry, package manager, or official docs only when the external research gate is met

## Verdicts

- **REUSE** — use existing project code
- **USE INSTALLED** — use stdlib, native feature, or installed dependency
- **BUILD LOCAL** — custom code is smaller and lower-risk
- **ADOPT** — add a dependency with clear payoff
