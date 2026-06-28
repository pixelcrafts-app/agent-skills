---
name: contracts
description: Interface contract system for autonomous development. The architect defines all contracts before any implementation; human-approved contracts are locked and no agent may change them. Eliminates integration blindness by making every integration point explicit before code is written.
---

# Contracts

> Agents implement in parallel: A returns `user_id: string`, B expects `userId: number`, both pass their own tests, integration fails — the mismatch lived in the gap no agent saw. Contracts make every integration point explicit *before* code, so integration is mechanical once contracts hold.

Location: `<project-state-dir>/contracts/<domain>.contract.md` (one per domain boundary) + a `LOCKED` file listing locked files + hashes. (`<project-state-dir>` is harness-specific — `.claude/`, `.kimi/`, `.agent/`, or project root.)

## Contract format

```markdown
# Contract: <domain>
## Status: draft | reviewed | locked
## Types        # TS-style interfaces (shape + invariants, not implementation), any impl language
## API surface  # table: Method | Path | Request | Response | Errors
## Events       # table: Event | Payload | Publisher | Subscribers
## Invariants   # rules that always hold (e.g. User.id is UUID v4; refresh token single-use → 401 on reuse)
## Dependencies # Depends on / Used by: <other contracts>
```

## Architect protocol (after `spec.md` locked, before any implementation)

1. Read the full spec — list all entities and every point where code exchanges data.
2. Write one contract per **domain boundary** (service-to-service, API endpoint, event bus, shared model).
3. **Completeness:** every entity has a contract type; every API call/event has a table row; no undefined type referenced.
4. **Cross-contract consistency:** every boundary-crossing `id` has the identical type on both sides; every shared entity has the same shape everywhere; every error code is defined where it's emitted.
5. Set status `reviewed` → submit for Challenger.

## Challenger review (mandatory before locking)

Clean context, contracts only: (1) where are type mismatches across contracts? (2) is error handling specified when an invariant is violated? (3) what will implementations need that isn't here? Findings addressed before locking.

## Locking

After human approval: set each `status: locked`; write `LOCKED` with timestamp + sha256 per contract file. **No agent may modify a locked contract** (mechanically enforced where the harness supports it, otherwise a hard protocol rule).

## Implementer scope

Each implementer owns exactly ONE contract: writes only files implementing its surface; may read other contracts (not modify); tests are generated from the contract by the Test Writer (implementer can't write or modify `tests/contracts/`).

## Agents must not

Implement before all contracts are locked · modify a locked contract · implement a different contract than assigned · write types contradicting the contract · reference a type not defined in a locked contract.
