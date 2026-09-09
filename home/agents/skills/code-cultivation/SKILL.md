---
name: code-cultivation
description: Review and refactor code so each unit has a clear job, APIs return usable results, data models prevent invalid states, ownership and dependencies stay explicit, and real behavior is verified. Use for clean-code or architecture review, root-cause refactoring, API/configuration/schema/test/documentation audits, or fitting new behavior into an existing design.
---

# Code cultivation: make the job clear and the structure honest

Start with the result the caller needs, not the techniques used to produce it. If every caller runs `download(source)` and then `verify(file, hash)`, and an unverified file has no valid use, expose one operation such as `fetch_tarball(source, hash)`. Keep download and hashing helpers private if they make the implementation easier to read. Do not make callers assemble half of a protocol.

At module scale, name the complete repository change. For an updater, organize the code around "replace the pin only after every downloaded artifact and generated record identifies the same release," not around peer stages called fetch, parse, and render.

Apply this rule at every scale. State what useful job the function, module, or service finishes and what must be true when it finishes. Then make the data, ownership, control flow, and failure behavior support that job.

Do not stop after naming the job. Reject a well-named operation when it permits contradictory states, duplicates facts, hides dependencies, or ignores real failure and resource constraints. Use two questions throughout:

1. Does the code make its useful job obvious?
2. Does the structure make the claimed result true and maintainable?

## Start from the useful result

Before judging names or abstractions:

- Read the actual behavior, callers, tests, help, examples, schemas, and relevant documentation. Inspect history when the code looks half-migrated.
- State the result a caller may rely on, the condition that makes it valid, and the failure that condition prevents.
- Record valid states and normal transitions. Identify the natural owner of state, policy, validation, cleanup, retry, and commit.
- Identify which intermediate values have legitimate independent uses.
- Note the real consumers, lifetime, compatibility requirements, trust boundaries, and resource limits.
- Trace the normal path from input through representation and decisions to the external effect.

For persisted or generated state, trace creation, validation, consumption, update, recovery, and migration. Before changing an exported symbol or stored shape, find every consumer. Blast radius is a query, not a guess.

Review the path that produces the result, not files in isolation. Treat the current structure as evidence, not authority. Assume surprising code may carry a constraint until behavior, callers, or history show otherwise.

When qualities conflict, prefer:

1. observable behavior and domain truth;
2. a complete operation enforced by its representations and API;
3. explicit invariants, clear ownership, and one-way data flow;
4. one authoritative home for each fact and fewer degrees of freedom;
5. less mechanism and indirection;
6. precise expression over superficial uniformity.

Treat evidence according to what it proves. A sample, metadata field, default, or heuristic does not establish an exact claim. Check that the probe and selector are trustworthy before changing code around their result.

## Put boundaries where results become usable

Treat a function, type, or module name as a contract. Ask:

- What may the caller safely do with the result?
- Has this unit completed everything its name implies?
- Must every caller remember the same next call?
- Can an unsafe, contradictory, or useless intermediate escape?
- Did the boundary follow a useful result, or merely a change from I/O to parsing, parsing to validation, or one library to another?

Keep steps together when one has no useful meaning without the other, a later step validates or commits an earlier step, they share cleanup or retry policy, or they change for the same reason.

Keep steps separate when the intermediate result has a real consumer, lifecycle, policy, recovery role, or trust boundary. For example, keep parsing separate from validation when an editor uses an invalid syntax tree to report several errors. Combine them when every caller requires a valid configuration.

Do not split merely because the verbs or techniques differ. Do not merge merely because calls are sequential. Place the boundary where the caller receives a useful result.

Let a complete operation delegate substantial mechanics. The main flow should retain the decisions, order, and success condition; helpers should remove detail without taking ownership of the job.

## Make the structure support the job

Use the following checks after identifying the operation:

- Represent valid states and transitions directly. Add a distinction when states have different validity or ownership; remove one when it exists only to be synchronized.
- Prevent invalid construction when practical instead of validating the same combination in every caller.
- Give each invariant and mutable fact one owner. Keep policy in data rather than copying it into labels, defaults, schemas, tests, and documentation.
- Pass required context forward. Do not recover discarded information or depend on ambient state when the caller already knows it.
- Use a type when it prevents invalid use, carries durable identity, crosses a real boundary, or owns a lifecycle or policy. Do not create a type for every pipeline stage.
- Keep important domain decisions more visible than URL construction, adapters, serialization, and formatting.
- Generalize only when real uses share policy and ownership. Similar syntax may encode different knowledge and should not be merged by appearance alone.
- Keep error, cancellation, retry, locking, cleanup, and resource behavior consistent with the operation's contract.

Look specifically for:

- claims named "exact", "safe", or "identical" that rely only on samples, defaults, or metadata;
- fields, flags, or collections that callers must synchronize, or that become ignored in some modes;
- routine changes that require coordinated edits to validators, defaults, schemas, and labels;
- callers that always pair the same operations or reconstruct the same context;
- half-migrated paths, stale aliases, dead dependents, magic offsets, and cleanup that compensates for an earlier design error.

Trace these symptoms backward. Fix the earliest boundary or representation that can own the rule instead of polishing downstream compensation.

Do not delete a useful seam because it looks thin. A filesystem wrapper that rebases paths, attaches consistent errors, and shares execution context owns real policy. A local one-off is also fine when it stays local and duplicates no policy.

## Change the responsible boundary

Make the strongest case for the current shape before changing it. An intermediate may have a real consumer. A split may protect recovery, cancellation, locking, or a trust boundary. An abstraction may own context that is not visible from one call site. Report only problems with a demonstrated consequence, and state confidence. Do not assume the largest function or oldest abstraction is the cause.

For risky changes, run the smallest reversible probe that can confirm the suspected cause. Then repair the responsible boundary and make a clean cutover. Update every caller, test, schema, persisted form, and relevant document. Remove obsolete paths, aliases, parallel implementations, and compensations whose cause is gone.

Treat compatibility as a requirement to prove, not a default. When stored data changes, choose migration, explicit rejection, or maintained compatibility. For schemas, versions, and generated artifacts, identify the authoritative form and make routine edits and upgrades deliberate. Keep tests, help, examples, and documentation aligned with the stable contract.

Scale the change to the evidence. Do not redesign unrelated code because a broader design would look cleaner.

## Verify the complete operation

Exercise the real operation from input to externally visible result. Compilation only proves that the pieces fit.

- Run the ordinary workflow through the actual CLI, UI, API, or runtime surface.
- Inspect the resulting artifact or state at the boundary consumers use.
- Try the misuse the new boundary should prevent, such as skipped validation, stale context, partial commit, contradictory fields, or an escaped intermediate.
- Exercise relevant normal transitions and failure, recovery, concurrency, and resource behavior.
- For an exact contract, inspect all relevant data with a trustworthy check rather than a sample or metadata proxy.
- After removals or renames, prove that code, tests, schemas, documentation, callers, and persisted references agree.

Add a lasting test only when a plausible regression would violate observable behavior or an invariant. Prefer guards in this order: representation, ownership or API, boundary validation, behavioral test, then a comment for a constraint that cannot be encoded.

Read the main flow once after the change. Confirm that each major step serves the stated job, each important unit returns a useful result, obsolete compensation is gone, and the next plausible change has one obvious home. Continue only if this pass finds a material problem.

## Report and stop

Infer the mode from the request. In review mode, report only material findings and say when suspicious code should stay. In refactor mode, repair proven causes with a clean cutover. When adding behavior, place it inside the operation that already owns the job; reshape only when the existing boundary cannot support it honestly.

Report in this order:

```text
Purpose: the useful result this code must produce.
Problem: where the current structure makes that result unclear or unreliable.
Decision: what to merge, split, move, model, rename, or deliberately keep.
Check: the real operation exercised and the result observed.
```

Use metrics, line counts, abstraction counts, and uniformity only as signals. Delete stale explanations when their cause disappears; preserve comments that carry a live, nonlocal constraint. Use specialist review for security, performance, accessibility, or domain claims that this skill cannot prove.

Stop when the useful job is clear, important units return valid results, supporting mechanics stay subordinate, each fact has one owner, and behavior is proven. Another structural pass needs new evidence, not residual aesthetic discomfort.
