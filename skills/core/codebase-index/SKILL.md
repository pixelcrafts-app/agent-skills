---
name: codebase-index
description: Apply when running repeated audits or spawning agents to analyze files. Maintain a findings cache keyed by file content hash to avoid re-reading unchanged files.
triggers:
  - Repeated audits in the same project
  - Multi-agent analysis where subagents may re-read the same files
  - Verifying changes across a large codebase
scope: File analysis and audit workflows
outputs: Cache-hit skip lists and written-back findings per file
---

# Codebase Index

> Maintain a persistent findings cache keyed by file content hash. Unchanged files are skipped. Only files whose content changed since the last audit are re-analyzed.

## When to Apply

- Before any repeated audit or verification run
- Before spawning subagents to analyze files
- When the same files may be audited multiple times in one session or across sessions

## Must-Do Checklist

- [ ] Identify or create a cache store keyed by file content hash
- [ ] Collect always-miss files before checking hashes
- [ ] Build an in-memory lookup of cached findings
- [ ] Skip cache-hit files during analysis
- [ ] Write findings back after each batch
- [ ] Invalidate entries when file content or rule definitions change

## Rules

### 1. Cache key

Cache findings per file, keyed by the file's current content hash. The hash must reflect the working tree content, not a stale index version.

Always-miss files (skip hash check):
- Files modified in the working tree
- New, untracked files

For all other files, use a reliable content hash from the version control system or compute one on demand.

### 2. Cache schema

Each entry stores:

```
path:
  content_hash: <hash>
  audited_dimensions: [dimension-name, ...]
  last_audited: <ISO timestamp>
  findings:
    - rule: <rule identifier>
      verdict: PASS | FAIL | N_A | INFO
      evidence: <file:line or excerpt>
      source: cache | tool | judgment
```

### 3. Cache lookup

Before analyzing a file, evaluate in order:

1. Is the file in the always-miss set? → cache miss
2. Is the file in the cache? → if not, cache miss
3. Does the cached hash match the current content hash? → if not, cache miss
4. Is the requested dimension in `audited_dimensions`? → if not, cache miss for this dimension

If all conditions pass → cache hit. Inject cached findings and skip the file.

### 4. Write findings

After analyzing a batch of files:

1. Get the current content hash for each analyzed file
2. Merge into the cache entry:
   - Update `content_hash`
   - Add the dimension to `audited_dimensions`
   - Replace findings for that dimension; preserve findings for other dimensions
   - Update `last_audited`
3. Write the full cache atomically

### 5. Invalidation rules

| Event | Action |
|---|---|
| File content changed | Remove all findings for that file; re-analyze from scratch |
| File deleted | Remove cache entry |
| File renamed | Remove old path entry; new path starts uncached |
| Skill rule definitions changed | Clear the entire cache or the affected dimension manually |

Do not merge old findings for a file whose content changed. Start clean.

### 6. Multi-agent protocol

Subagents do not automatically inherit the cache. The parent must pass cache context explicitly in the brief.

Parent responsibilities:
1. Identify the agent's file scope explicitly
2. Extract cache hits for that scope
3. Inject two lists into the brief:
   - Skip entirely — already audited, content unchanged
   - Analyze these — cache miss or changed
4. Paste excerpts for files the parent already read

Agent responsibilities:
1. Read the skip list first; do not analyze those files
2. Use pasted excerpts directly; do not re-read those files
3. Only analyze files in the "analyze these" list
4. Write findings back to the cache for every analyzed file
5. Return a compact summary only

Parent verifies by reading the cache, not by trusting agent prose.

### 7. When not to use cache

- User explicitly says "full re-audit" or "ignore cache"
- Skill rules were updated
- Debugging a suspected stale cache result

In these cases, clear the cache before running.

## Verification Commands

- Compare cache hashes against current file hashes for a sample of files
- Confirm always-miss files are not treated as cache hits
- Confirm analyzed files are written back to the cache

## Verdicts

- **CACHED** — file hash matches and dimension is covered; skip
- **MISS** — file changed, new, or dimension not yet covered; analyze
- **INVALIDATED** — old entry removed due to content change or rule update
