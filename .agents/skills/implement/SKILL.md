---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

When invoked, first check active issues using GitHub CLI:

```bash
gh issue list --state open --limit 20 --json number,title,labels --jq '.[] | "\(.number) - \(.title) [\(.labels | map(.name) | join(", "))]"'
```

If no ticket or spec is specified by the user, present the open issues with the `ready-for-agent` label as candidates for implementation.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /code-review to review the work.

Commit your work to the current branch.
