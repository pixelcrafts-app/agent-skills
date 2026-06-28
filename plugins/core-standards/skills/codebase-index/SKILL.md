---
name: codebase-index
description: Apply when running repeated audits or spawning agents to analyze files. Maintain a findings cache keyed by file content hash to skip unchanged files.
triggers:
  - Repeated audits in the same project
  - Multi-agent analysis where subagents may re-read the same files
  - Verifying changes across a large codebase
scope: File analysis and audit workflows
outputs: Cache-hit skip lists and written-back findings per file
---

# Codebase Index

> A persistent findings cache keyed by **file content hash** — unchanged files are skipped, only changed content is re-analyzed.

## Cache key & schema

Key findings per file by current **working-tree** content hash (not a stale index). **Always-miss** (skip the hash check): working-tree-modified files and new/untracked files. Otherwise use the VCS hash or compute one.

```
path:
  content_hash: <hash>
  audited_dimensions: [<dimension>, ...]
  last_audited: <ISO>
  findings: [{ rule, verdict: PASS|FAIL|N_A|INFO, evidence: <file:line>, source: cache|tool|judgment }]
```

## Lookup (cache hit only if all pass)

1. Not in the always-miss set, **and** 2. present in cache, **and** 3. cached hash == current hash, **and** 4. requested dimension ∈ `audited_dimensions`. Hit → inject cached findings, skip the file. Any failure → miss, analyze.

## Write back (after each batch)

Per analyzed file: update `content_hash`, add the dimension to `audited_dimensions`, **replace** findings for that dimension (preserve others), update `last_audited`. Write the cache atomically.

## Invalidation

| Event | Action |
|---|---|
| Content changed | drop all findings for that file; re-analyze clean (never merge old) |
| File deleted / renamed | remove old entry; new path starts uncached |
| Skill rules changed | clear the whole cache or the affected dimension |

## Multi-agent protocol (subagents don't inherit the cache)

**Parent:** scope the agent's files → extract cache hits → inject two lists in the brief (**Skip** = audited + unchanged; **Analyze** = miss/changed) → paste excerpts for files the parent already read. **Agent:** honor the skip list, use pasted excerpts (don't re-read), analyze only the "Analyze" list, write findings back, return a compact summary. **Parent verifies by reading the cache, not by trusting agent prose.**

## When not to cache

User says "full re-audit"/"ignore cache" · skill rules updated · debugging a suspected stale result → clear the cache first.

## Verdicts

- **CACHED** — hash matches + dimension covered → skip
- **MISS** — changed/new/uncovered dimension → analyze
- **INVALIDATED** — entry removed due to content change or rule update
