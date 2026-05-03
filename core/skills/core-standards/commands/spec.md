---
description: Define what to build. Validates and locks the spec before any implementation begins. Creates acceptance-tests.md as the objective definition of done.
---

# /spec

$ARGUMENTS

Read and execute the `core-standards:spec-validator` skill exactly as specified.

The goal to spec is: $ARGUMENTS

Steps:
1. Create or update `.claude/spec.md` with the goal from $ARGUMENTS
2. Run the validation protocol — challenge for gaps, ambiguities, missing criteria
3. Surface open questions for the user to answer
4. Once validated, generate `.claude/acceptance-tests.md`
5. Lock both files after human approval
