---
name: minimize-code
description: Apply on coding implementation and review tasks to satisfy explicit requirements with the smallest maintainable diff, reuse existing code/stdlib/native/installed dependencies, avoid speculative abstractions or dependencies, and challenge only ambiguous or unnecessary scope before reducing it.
---

# Minimize Code

> Ship the requested behavior with the least code that remains correct, clear, and maintainable.

## Priority

Minimization is subordinate to the user's explicit request, correctness, security, accessibility, data safety, and maintainability. Do not reduce accepted scope silently. If a smaller version may satisfy the intent, ask or state the tradeoff before implementing the smaller version.

## Decision Ladder

Run this after reading the task and the touched code path:

1. Remove work that is speculative, unused, or outside the request.
2. Reuse an existing helper, component, pattern, command, or convention.
3. Prefer the standard library or native platform feature.
4. Prefer an already-installed dependency when it is clearer or safer than custom code.
5. Add a new dependency only when it materially reduces complexity or risk and fits the project.
6. Write the smallest maintainable diff that satisfies the requirement.

## Rules

- Keep the fewest files, public surfaces, configuration knobs, and abstractions that solve the real problem.
- Do not create interfaces, factories, registries, base classes, or extension points for one caller unless the codebase already uses that pattern for the same reason.
- Prefer deletion, reuse, and local changes over new modules.
- Use one line only when it is still idiomatic and readable.
- Pick the edge-case-correct option when two options are similarly small.
- Preserve trust-boundary validation, error handling that prevents data loss, security controls, accessibility basics, and required observability.
- Use `minimize-code:` comments only for non-obvious simplifications with a known ceiling or upgrade path. Do not label ordinary simple code.

## When to Ask

Ask before reducing scope when:

- The request is explicit but seems larger than necessary.
- The smaller version changes user-visible behavior, compatibility, persistence, security, or API shape.
- A new dependency, migration, generated code path, or broad refactor looks unnecessary.
- The requirement is ambiguous enough that building the small version may be wrong.

## Output

For implementation: make the smallest maintainable change. In the final response, mention only material simplifications, omitted speculative work, or tradeoffs the user needs to know.

For review: report bloat findings first with `file:line` evidence. For each finding, name the simpler replacement: delete, reuse existing code, use stdlib/native behavior, use an installed dependency, or narrow the abstraction.

## Done Check

- Explicit requested behavior is still implemented.
- The diff has no speculative abstractions, unused options, or new dependency without a clear payoff.
- The code is readable to the next maintainer, not merely short.
- Verification matches the risk of the change.
