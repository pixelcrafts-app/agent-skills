---
name: codebase-onboarding
description: Analyze an unfamiliar codebase and produce an architecture map, key entry points, conventions, and a starter project-instructions file. Triggers on "onboard me", "walk me through this repo", or "generate project instructions".
origin: ECC
---

# Codebase Onboarding

Triggers: "onboard me"/"walk me through" → full 4 phases + instructions file · "generate project instructions" → phases 1–3 + file · "update instructions" → read existing first, merge. (Instructions file is harness-specific: `CLAUDE.md`, `AGENTS.md`, `.cursor/rules`, etc.)

## Phase 1 — Reconnaissance (Glob/Grep, parallel; Read only ambiguous signals)

Package manifests (`package.json`/`go.mod`/`Cargo.toml`/`pyproject.toml`/`pubspec.yaml`) · framework signals (`next.config`/`vite.config`/`angular.json`/rails) · entry points (`main.*`/`index.*`/`server.*`/`cmd/`) · top-2-level dir snapshot (skip node_modules/.git/dist) · tooling (`.eslintrc`/`tsconfig`/`Dockerfile`/`.github/workflows`/`.env.example`) · tests.

## Phase 2 — Architecture

Stack (language+version, framework, DB+ORM, bundler, CI) · pattern (monolith/monorepo/microservices/serverless; FE/BE split; REST/GraphQL/gRPC) · directory map (non-obvious dirs only) · request trace (entry → validation → logic → persistence → response).

## Phase 3 — Conventions

File naming · error handling (try/catch / Result / codes) · async pattern · git (branch naming from `git branch -r`, commit style from `git log --oneline -10`). Shallow/absent git → skip + note.

## Phase 4 — Output

**Onboarding guide:** Stack table · Architecture (3-line or mermaid) · Entry points (path → what happens) · Directory map (non-obvious) · Request lifecycle (1 sentence/step) · Conventions · Common commands (dev/test/lint/build) · "Where to look" table.

**Project-instructions file** (if one exists, read first and enhance — preserve existing, mark additions): Stack · Commands · Code style (naming, error handling) · Project structure (key dirs) · Conventions (commit style, test pattern).

## Rules

Trust code over config when they conflict · instructions file ≤100 lines (don't list every dependency or describe obvious dirs like `src/`) · unknown convention → state "Could not detect," never guess.
