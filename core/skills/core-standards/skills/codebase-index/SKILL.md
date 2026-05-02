---
name: codebase-index
description: Persistent audit cache keyed by git blob hash. Load before any audit to skip unchanged files; write findings after each batch. Zero infra — one JSON file at .claude/audit-cache.json. Eliminates re-reading thousands of files across repeated audits in the same or future sessions.
---

# Codebase Index

## What it solves

Every audit reads all files from scratch. At 2000+ files with 5 audits in a session, that is 10,000 file reads. If `users.service.ts` did not change between audit 1 and audit 2, its findings from audit 1 are still valid — re-reading and re-analyzing it is pure waste.

This skill maintains a persistent findings cache keyed by file content hash. Unchanged files are skipped. Only files whose content changed since the last audit are re-analyzed.

## Cache file

Location: `.claude/audit-cache.json`

Add to the project's `.gitignore`:
```
.claude/audit-cache.json
```

This is a local development artifact — machine-specific, session-derived. Unlike `.claude/craft.json` (project config, committed), the cache is not shared across the team.

### Schema

```json
{
  "version": 1,
  "schema": "codebase-index:v1",
  "files": {
    "src/users/users.service.ts": {
      "blob_hash": "a1b2c3d4e5f67890abcdef1234567890abcdef12",
      "audited_dimensions": ["universal-rules:security", "api-standards:code-quality"],
      "last_audited": "2026-05-02T10:00:00Z",
      "findings": [
        {
          "rule": "universal-rules:security",
          "verdict": "PASS",
          "evidence": "src/users/users.service.ts:45 — parameterized query, no raw SQL",
          "source": "ai_judgment"
        }
      ]
    }
  }
}
```

## Hash strategy

**Tracked files** (committed to git): use `git ls-files -s <path>` — returns the blob SHA-1 git already computed. Zero extra cost; no hashing needed.

```bash
git ls-files -s src/users/users.service.ts
# 100644 a1b2c3d4e5f67890abcdef1234567890abcdef12 0	src/users/users.service.ts
# Take field 2 as the hash.
```

**Untracked files** (new, not yet staged): fall back to content hash.
```bash
shasum -a 256 src/new-file.ts | awk '{print $1}'   # macOS
sha256sum src/new-file.ts | awk '{print $1}'        # Linux
```

**Why git blob hash over mtime**: `mtime` changes on every `git checkout` even when content is identical to a prior version. Git blob hash is content-derived — same bytes → same hash regardless of when, where, or which branch.

## Protocol

### Step 1 — Load cache (before any audit begins)

```bash
# Get all tracked file hashes in one pass (fast, O(repo size), single process)
git ls-files -s
# Output: <mode> <hash> <stage>\t<path>
# Parse: split by tab, take field 2 as hash, field 1's last column as path
```

Read `.claude/audit-cache.json`. Build an in-memory lookup:
```
{ path → { blob_hash, audited_dimensions[], findings[] } }
```

If the file does not exist: start with an empty cache. Do not error.

### Step 2 — Check cache per file (before analyzing each file)

Before reading or analyzing a file, evaluate three conditions in order:

1. **File in cache?** — If not → must analyze.
2. **Hash matches?** — Run `git ls-files -s <path>` and compare to `cached_hash`. If different → content changed, must re-analyze this file fully.
3. **Dimension covered?** — Does `audited_dimensions` include the dimension being audited? If not → must analyze for this dimension.

**All three must pass** (in cache, same hash, dimension already covered) → **cache hit**: skip reading and analyzing the file. Inject cached findings for this dimension directly into `verify-state.json` with `source: "cache"`.

**Any condition fails** → cache miss: read and analyze normally.

### Step 3 — Write findings after each batch

After completing a batch (after writing to `verify-state.json`):

For each file analyzed in the batch:
1. Get current blob hash (as above)
2. Merge into cache entry:
   - `blob_hash` → current hash
   - `audited_dimensions` → existing list + new dimension (deduplicated)
   - `findings` → existing findings for other dimensions, plus new findings for this dimension (replace, not append, for the same dimension)
   - `last_audited` → current ISO timestamp
3. Write full `.claude/audit-cache.json`

**Merge rule for findings**: a cache entry accumulates findings across dimensions. Auditing `universal-rules:security` on Monday and `api-standards:code-quality` on Tuesday produces one cache entry with both sets of findings. When re-auditing the same dimension, replace only that dimension's findings — do not discard findings from other dimensions.

### Step 4 — Invalidation rules

| Event | Action |
|---|---|
| File hash changed | Remove all findings for that file, re-analyze from scratch |
| File deleted (`D` in git status) | Remove cache entry entirely |
| File renamed | Remove old path entry; new path starts uncached |
| New dependency added to project | No action — cache is per-file, not per-project |
| Skill rule definition changed | Manual: delete `.claude/audit-cache.json` to force full re-audit |

If a file's hash changed, do not try to merge old findings — the content is different, old findings may be stale or wrong. Always start clean for a changed file.

## Integration points

This skill is invoked by `verify-changes` at three points:

**Phase 0 (after state init):**
Run Step 1 — load cache into working memory alongside `verify-state.json`.

**Phase 4.1 step 1 (before each file in a batch):**
Run Step 2 — check cache. On cache hit, inject findings into `verify-state.json` (`source: "cache"`) and skip to the next file. Do not read the file, do not run rules.

**Phase 4.1 step 6 (after writing to verify-state.json):**
Run Step 3 — write findings for this batch back to the cache.

## Token savings

| Scenario | Without cache | With cache |
|---|---|---|
| 1st audit, 2000 files | 2000 files read | 2000 files read (cache populated) |
| 2nd audit, 50 files changed | 2000 files read | 50 files read |
| 3rd audit, 5 files changed | 2000 files read | 5 files read |
| 5 audits, ~50 changed between each | 10,000 file reads | ~2,250 file reads (~78% reduction) |

The first audit is always a full read. All subsequent audits are scoped to changed files only.

## When not to use cache

- The user explicitly says "full re-audit" or "ignore cache"
- Skill rules were updated (the cached findings were produced by an older version of the rules)
- Debugging a suspected stale cache result

In these cases: delete `.claude/audit-cache.json` before running. The next audit repopulates it from scratch.
