# AGENTS.md

## 🎛️ Task Triage & Complexity Classification

Before starting any task, evaluate its impact and complexity to determine the correct execution path:

1. **Trivial / Administrative Tasks:** Simple configuration changes (e.g., updating `.gitignore`, modifying environment variable templates), fixing typos in documentation, or minor dependency updates.
   * **Workflow:** **Fast-Track.** You are permitted to bypass steps 1 through 3. Proceed directly to Step 4 (`/implement`) and finalize with Step 5 (`/code-review`).
2. **Engineering Tasks:** Any change that alters, adds, or removes business logic, components, database schemas, API endpoints, or software architecture.
   * **Workflow:** **Full Pipeline.** You must execute the strict 5-step development workflow sequentially without exceptions.

---

## 🔄 The 5-Step Development Pipeline (Matt Pocock Workflow)

For all Engineering Tasks, you must strictly follow this chronological sequence. To preserve your context window, load and read the corresponding skill file under `.github/skills/[skill-name].md` (or your local skills path) on-demand right before starting each phase.

| Step | Command | Core Purpose / Description | Exit Gate (Verification) |
| :---: | :--- | :--- | :--- |
| **1** | `/grill-with-docs` | A relentless interview to sharpen a plan or design, which also creates docs (ADR's and glossary) as we go. | All design ambiguities are resolved; ADRs and glossary are updated. |
| **2** | `/to-spec` | Turn the current conversation into a spec and publish it to the project issue tracker — no interview, just synthesis of what you've already discussed. | A technical spec is synthesized and published to the configured tracker. |
| **3** | `/to-tickets` | Break a plan, spec, or the current conversation into a set of tracer-bullet tickets, each declaring its blocking edges, published to the configured tracker — edges as text in a local file, or native blocking links on a real tracker. | An atomic set of tickets with explicit blocking edges is published/saved. |
| **4** | `/implement` | Implement a piece of work based on a spec or set of tickets. | Working code is written and automated tests pass successfully. No "vibe coding". |
| **5** | `/code-review` | Review the changes since a fixed point (commit, branch, tag, or merge-base) along two axes — Standards (does the code follow this repo's documented coding standards?) and Spec (does the code match what the originating issue/PRD asked for?). Runs both reviews in parallel sub-agents and reports them side by side. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to "review since X". | A side-by-side parallel report detailing Standards vs. Spec compliance. |

---

## 🚫 Strict Operational Rules & Anti-Rationalization

* **Absolute Sequentiality:** You are strictly forbidden from running `/implement` for engineering tasks unless a valid specification (`/to-spec`) and broken-down tickets (`/to-tickets`) already exist to back it up.
* **Verification is Non-Negotiable:** Do not claim a task is complete based on intuition. The exit gates for `/implement` and `/code-review` require deterministic proof (passing test suites, successful builds, or explicit terminal confirmations).
* **The Socratic Mandate:** During `/grill-with-docs`, do not be agreeable. Your objective is to actively find flaws, missing requirements, and architectural conflicts in the proposal *before* a single line of production code is written.

---

## Agent skills

### Issue tracker

Issues live in GitHub Issues, accessed via the `gh` CLI. External PRs are not triaged. See `docs/agents/issue-tracker.md`.

### Triage labels

Five canonical roles mapped to their default strings. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout — one `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.

---

> **Engineering Policy for AI Agents**
>
> This repository follows an engineering-first workflow inspired by
> Matt Pocock's Skills, adapted for long-term development,
> large-scale refactoring,
> and feature evolution of the RaVN framework.

---

> *"The objective is not to write code.*
>
> *The objective is to leave behind a repository that future engineers can confidently understand, extend, and maintain."*

---

# Preface

> **Engineering Policy for Human–AI Collaboration**
>
> This repository is developed through a long-term collaboration between human engineers and AI agents.
> Every contributor—human or AI—is expected to follow the same engineering principles, repository conventions, and quality standards.
>
> The purpose of this document is not to constrain implementation.
> Its purpose is to ensure that every change improves the long-term health of the repository.

---

# Why This Document Exists

Software often outlives the conversations that created it.

Over the lifetime of this repository, contributors may include:

- human maintainers
- GPT models
- Claude models
- Gemini models
- Codex
- future AI systems
- open-source contributors

Each contributor will have different strengths, limitations, and reasoning styles.

Without shared engineering principles, the repository will gradually lose consistency.

This document exists to prevent that.

It defines a common engineering philosophy that remains stable regardless of who—or what—is contributing.

The objective is continuity.

Not uniformity.

---

# Human Ownership

The repository belongs to its maintainers.

AI agents are engineering collaborators.

Not engineering owners.

Humans define:

- product direction
- project goals
- architectural vision
- long-term priorities
- acceptable trade-offs

AI agents assist by providing:

- implementation
- engineering analysis
- design exploration
- documentation
- testing
- code review
- identification of risks

The final engineering decision always belongs to the repository maintainers.

---

# Engineering Partnership

The relationship between humans and AI is collaborative.

Humans provide experience, judgment, and domain knowledge.

AI provides speed, breadth of analysis, and implementation assistance.

Neither replaces the other.

The strongest engineering emerges when:

- humans provide direction
- AI challenges assumptions
- alternatives are evaluated openly
- decisions are documented
- implementation follows agreed designs

Constructive disagreement is encouraged.

Silent assumptions are not.

---

# Challenge Before Commit

AI agents are expected to think critically.

If a request introduces:

- architectural inconsistencies
- unnecessary complexity
- duplicated functionality
- undocumented behavioral changes
- long-term maintenance risks

the agent should raise those concerns before implementation begins.

Questioning a proposal is part of good engineering.

Once a decision has been made, however, implementation should faithfully execute that decision unless doing so would:

- introduce a defect
- violate repository policy
- create a security issue
- contradict an accepted specification

---

# Repository Continuity

Every engineering decision should be made as though the repository will still be actively maintained five years from now.

Optimize for future contributors.

Not for the current conversation.

Every accepted change becomes part of the repository's permanent engineering history.

Leave that history better than you found it.

---

# Repository Memory

Existing repository knowledge always has priority over assumptions.

When multiple sources of truth exist, prefer them in this order:

1. Accepted Architecture Decision Records (ADRs)
2. Accepted specifications
3. Existing repository architecture
4. Accepted tickets
5. Repository conventions
6. Explicit maintainer instructions
7. Existing implementation
8. External examples
9. AI assumptions

Never replace documented engineering knowledge with speculation.

---

# Engineering Responsibility

Every accepted change creates future maintenance work.

Before implementing any modification, ask:

- Will future contributors understand this?
- Does this simplify or complicate the repository?
- Does this reduce or increase maintenance cost?
- Is this consistent with existing architecture?
- Is this the smallest correct solution?
- Would this still feel like the right decision in two years?

If those questions cannot be answered confidently,

engineering is not yet complete.

---

# Engineering Principles

Every section of this document should be interpreted through the following principles.

## Correctness Before Speed

Fast implementation has little value if it introduces technical debt.

Correctness always comes first.

---

## Simplicity Before Cleverness

Prefer solutions that future contributors immediately understand.

Avoid clever implementations that require explanation.

---

## Consistency Before Novelty

The repository should feel like the work of one engineering team.

Not many independent contributors.

Whenever multiple valid implementations exist,

prefer the one that best matches existing repository conventions.

---

## Evolution Before Rewrite

Improve existing systems whenever practical.

Rewrites should be exceptional.

Evolution should be continuous.

---

## Reuse Before Reinvention

Before creating:

- utilities
- helpers
- abstractions
- frameworks
- modules

search the repository.

Existing solutions should be extended before new ones are introduced.

---

## Repository Before Implementation

The repository is more important than any individual change.

Every implementation should leave the project:

- easier to understand
- easier to review
- easier to maintain
- easier to extend
- more internally consistent

than it was before.

---

# One Philosophy

Everything that follows in this document—workflow selection, planning, implementation, review, and completion—exists to support one simple objective:

> **Leave behind a repository that future engineers can confidently understand, modify, and extend.**

If a proposed change improves the immediate implementation but harms the long-term health of the repository,

it is not the correct engineering decision.

The repository is the product.

Every individual implementation is merely one contribution to it.


---


# 1. Engineering Philosophy

## Purpose

This document defines how AI agents should reason,
plan,
implement,
and review changes within this repository.

It is **not** a prompt.

It is **not** a checklist.

It is the engineering policy governing every code change.

Every agent working on this repository is expected to follow these rules before modifying production code.

---

# Vision

The objective of this repository is **not** to maximize implementation speed.

The objective is to maximize:

- correctness
- maintainability
- consistency
- long-term evolution
- engineering quality

A slower, well-reasoned implementation is always preferred over a fast implementation that introduces technical debt.

---

# Non-Goals

This workflow is **not** intended to:

- generate unnecessary documentation
- maximize the number of artifacts
- introduce bureaucracy
- slow down obvious work
- force every task through the same pipeline

Documentation exists only when it reduces uncertainty.

Tickets exist only when they improve execution.

Process exists only when it improves engineering quality.

---

# Core Philosophy

Good engineers do not begin by writing code.

Good engineers begin by reducing uncertainty.

Implementation should be the final step—not the first.

Whenever uncertainty exists,
the first objective is to eliminate it.

---

# Engineering Uncertainty

The amount of process required is proportional to the amount of engineering uncertainty.

Not to the number of changed lines.

Not to the size of the pull request.

Not to the number of modified files.

Instead, ask:

> **Do we already know the correct solution?**

If the answer is yes,
implementation may begin immediately.

If the answer is no,
implementation must not begin until the uncertainty has been removed.

---

# The Golden Rule

> Choose the smallest workflow that preserves engineering quality.

This is the primary decision rule for the repository.

Never choose a larger workflow simply because it exists.

Never choose a smaller workflow simply because it is faster.

Choose the smallest workflow that:

- removes uncertainty
- preserves correctness
- produces maintainable code

---

# Engineering Cost

Every engineering artifact has a cost.

Examples include:

- documentation
- specifications
- ADRs
- tickets
- diagrams
- meetings
- implementation
- reviews

These artifacts should only exist when their value exceeds their maintenance cost.

Creating unnecessary process is considered an engineering mistake.

---

# Repository Philosophy

RaVN is a framework.

It is not an application.

Frameworks evolve differently.

Because of this,
the repository values:

- composability
- modularity
- incremental evolution
- backwards compatibility
- consistency

over:

- rewrites
- novelty
- unnecessary abstractions
- clever implementations

---

# Framework Principles

## Consistency Over Cleverness

Prefer code that resembles the existing repository.

Even if another implementation is technically "better,"

consistency across the project is more valuable.

The repository should feel like it was written by one engineering team.

Not by many independent AI agents.

---

## Evolution Over Rewrite

Prefer improving existing systems.

Do not replace working code simply because a newer approach exists.

Rewrites should be rare.

Evolution should be continuous.

---

## Reuse Over Duplication

Before introducing:

- helper functions
- utilities
- modules
- abstractions

search the repository.

If similar functionality already exists,
extend it.

Do not introduce competing implementations.

---

## Simplicity Over Abstraction

Abstractions should remove duplication.

They should never exist simply because abstraction is possible.

Avoid creating new layers unless they solve an actual engineering problem.

---

## Behavior Preservation

Behavior-preserving refactors are preferred.

Unless explicitly requested,

observable behavior should remain unchanged.

Improving:

- readability
- modularity
- maintainability
- organization

without changing behavior is considered a safe refactor.

Behavioral changes require engineering discussion.

---

# Repository-First Thinking

Before creating anything new:

Read.

Search.

Understand.

Only then implement.

Agents should understand the surrounding module before proposing changes.

The existing repository always has priority over external examples.

---

# Incremental Engineering

Large changes should emerge through many small,
reviewable,
independently verifiable improvements.

Avoid introducing large monolithic changes whenever incremental evolution can achieve the same result.

---

# Engineering Gravity

Engineering naturally tends toward unnecessary complexity.

The purpose of this workflow is to constantly pull changes back toward simplicity.

Every proposed change should attempt to reduce:

- complexity
- duplication
- coupling
- hidden behavior

without reducing flexibility.

---

# Workflow Gravity

The repository deliberately biases toward the smallest acceptable workflow.

Process should grow only when uncertainty grows.

The workflow therefore follows one simple principle:

Small uncertainty.

↓

Small workflow.

Large uncertainty.

↓

Large workflow.

---

# Escalation Rule

Whenever uncertain which workflow applies,

choose the more conservative path.

It is acceptable to spend extra time removing uncertainty.

It is **not** acceptable to make undocumented engineering decisions.

---

# Repository Values

The following priorities should guide every engineering decision.

Highest priority first.

1. Correctness

2. Maintainability

3. Consistency

4. Readability

5. Simplicity

6. Reuse

7. Performance

8. Cleverness

If two possible implementations exist,

prefer the one that scores higher according to this ordering.

---

# Definition of Engineering Quality

Engineering quality is measured by the ability of future contributors to understand,
modify,
and extend the repository.

Good code is not merely code that works.

Good code is:

- understandable
- predictable
- testable
- reviewable
- reusable
- maintainable

This repository optimizes for long-term engineering quality over short-term implementation speed.

---

# 2. Decision Framework

The purpose of this section is to determine **how much engineering process is required before implementation begins.**

The workflow is **not** determined by:

- lines of code
- number of modified files
- pull request size
- implementation time

Instead, the workflow is determined by **engineering uncertainty**.

---

# The Decision Question

Before writing any production code, every agent must answer one question.

> **Is the correct implementation already known?**

If the answer is **yes**, implementation may begin immediately.

If the answer is **no**, implementation must not begin until the uncertainty has been removed.

Everything else in this workflow derives from this single decision.

---

# Decision Tree

```
                           New Request
                                │
                                ▼
          Is the implementation already obvious?
                     │                    │
                   YES                  NO
                    │                    │
                    ▼                    ▼
            Mechanical Work     Engineering Decisions
                    │                    │
                    │            /grill-with-docs
                    │                    │
                    │            Is the solution agreed?
                    │                    │
                    │             NO            YES
                    │              │             │
                    │      Continue grilling     ▼
                    │                    /to-spec
                    │                         │
                    │       Multiple independent work items?
                    │               │                    │
                    │              NO                  YES
                    │               │                    │
                    ▼               ▼                    ▼
              /implement     /implement          /to-tickets
                    │                                  │
                    └──────────────────┬───────────────┘
                                       ▼
                                /code-review
```

---

# Engineering Decision Levels

Every request belongs to one of three levels.

The objective is always to select the **lowest level that preserves engineering quality.**

---

# Level 1 — Mechanical Execution

Definition:

The implementation path is already known.

No meaningful engineering decisions remain.

The agent is executing—not designing.

Typical characteristics:

- behavior already defined
- implementation obvious
- follows existing repository patterns
- no architecture changes
- no domain decisions
- no API design

Examples (RaVN):

- Fix documentation
- Correct typos
- Rename variables
- ShellCheck fixes
- Format scripts
- Update dependency versions
- Improve comments
- Add an already-specified package
- Add an already-defined Hyprland bind
- Behavior-preserving refactors
- Follow an existing ticket
- Implement an existing specification

Workflow:

```
/implement
↓
/code-review
```

No planning artifacts should be created.

---

# Level 2 — Decision-Based Engineering

Definition:

The repository does not yet contain enough information to safely implement the change.

The agent must discover the correct solution.

Typical characteristics:

- multiple valid implementations
- architectural trade-offs
- missing requirements
- public interface design
- business logic decisions
- uncertainty

Examples (RaVN):

- New configuration system
- Theme loading improvements
- Wallpaper cache design
- Module organization
- New CLI behavior
- New feature
- Startup sequence redesign
- Performance optimization strategy
- Configuration format changes

Workflow:

```
/grill-with-docs
↓
/to-spec
↓
/implement
↓
/code-review
```

Planning exists to eliminate uncertainty.

Once uncertainty is removed,
implementation should proceed immediately.

---

# Level 3 — Architectural Changes

Definition:

The implementation affects multiple independent systems,
requires coordination,
or cannot reasonably be completed as one engineering task.

Typical characteristics:

- cross-module changes
- multiple milestones
- multiple pull requests
- plugin architecture
- framework redesign
- installer rewrite
- repository-wide refactor

Examples (RaVN):

- Rewrite installer
- Plugin architecture
- Theme architecture redesign
- Shared framework extraction
- Configuration architecture redesign
- Modularization across multiple directories
- Replace core framework abstractions

Workflow:

```
/grill-with-docs
↓
/to-spec
↓
/to-tickets
↓
/implement
↓
/code-review
```

Tickets exist only to coordinate execution.

Never create tickets solely because the workflow allows them.

---

# Decision Matrix

| Situation | Grill | Spec | Tickets | Implement | Review |
|------------|:----:|:----:|:-------:|:---------:|:------:|
| README changes | ❌ | ❌ | ❌ | ✅ | ✅ |
| Documentation | ❌ | ❌ | ❌ | ✅ | ✅ |
| Typo | ❌ | ❌ | ❌ | ✅ | ✅ |
| ShellCheck fixes | ❌ | ❌ | ❌ | ✅ | ✅ |
| Formatting | ❌ | ❌ | ❌ | ✅ | ✅ |
| Rename variables | ❌ | ❌ | ❌ | ✅ | ✅ |
| Dependency update | ❌ | ❌ | ❌ | ✅ | ✅ |
| Add missing package | ❌ | ❌ | ❌ | ✅ | ✅ |
| Behavior-preserving refactor | ❌ | ❌ | ❌ | ✅ | ✅ |
| Small bug (root cause known) | ❌ | ❌ | ❌ | ✅ | ✅ |
| Small bug (root cause unknown) | ✅ | ✅ | ❌ | ✅ | ✅ |
| New RaVN module | ✅ | ✅ | ❌ | ✅ | ✅ |
| Theme discovery redesign | ✅ | ✅ | ❌ | ✅ | ✅ |
| Wallpaper subsystem | ✅ | ✅ | ❌ | ✅ | ✅ |
| Configuration redesign | ✅ | ✅ | ❌ | ✅ | ✅ |
| Installer rewrite | ✅ | ✅ | ✅ | ✅ | ✅ |
| Plugin system | ✅ | ✅ | ✅ | ✅ | ✅ |
| Framework extraction | ✅ | ✅ | ✅ | ✅ | ✅ |
| Repository-wide refactor | ✅ | ✅ | ✅ | ✅ | ✅ |

---

# Escalation Heuristics

The following situations automatically increase the required workflow level.

## Unknown Root Cause

If the bug cannot be confidently explained,

stop implementation.

Understand the problem first.

---

## Multiple Valid Designs

If multiple reasonable implementations exist,

run `/grill-with-docs`.

The objective is to select the best engineering direction before coding.

---

## Public Behavior Changes

If observable behavior changes,

the task becomes Decision-Based Engineering.

---

## New Abstractions

Introducing a new abstraction should never be automatic.

First ask:

- Does one already exist?
- Can an existing abstraction be extended?
- Will this reduce long-term complexity?

If the answer is uncertain,

grill first.

---

## Cross-Module Changes

If the implementation touches several independent modules,

consider whether the work should become multiple tickets.

---

## Large Refactors

Refactors follow one simple rule.

Behavior preserved:

→ Mechanical Execution.

Behavior changes:

→ Decision-Based Engineering.

---

# Decision Anti-Patterns

Never use the workflow mechanically.

The following are considered engineering mistakes.

❌ Creating a specification for a typo.

❌ Creating tickets for a one-hour task.

❌ Skipping grilling because implementation "looks easy."

❌ Introducing architecture during implementation.

❌ Expanding scope while coding.

❌ Creating abstractions before understanding the repository.

❌ Choosing a larger workflow because it feels more "professional."

The workflow should always remain proportional to engineering uncertainty.

---

# Decision Principle

When uncertain,

opt for understanding before implementation.

Thinking is never wasted.

Unnecessary implementation almost always is.

---

# 3. Skill Definitions

The repository uses Matt Pocock's Skills as engineering tools.

Skills are **not** workflows.

They are **building blocks**.

A workflow is simply the correct composition of multiple skills.

Every skill has:

- a purpose
- an expected input
- an expected output
- clear completion criteria

Do not execute a skill simply because it exists.

Use it only when it reduces engineering uncertainty or improves implementation quality.

---

# /grill-with-docs

## Purpose

`/grill-with-docs` exists to eliminate uncertainty.

It is **not** an implementation step.

It is an engineering discussion whose objective is to discover the best solution before writing production code.

The output is confidence—not code.

---

## When To Use

Use this skill whenever:

- requirements are incomplete
- multiple designs are possible
- architecture may change
- public behavior changes
- trade-offs exist
- assumptions need validation

Typical RaVN examples:

- Designing a plugin system.
- Replacing the theme loader.
- Introducing a new framework module.
- Redesigning startup.
- Reorganizing configuration.

---

## When NOT To Use

Do not use grill for:

- documentation
- typos
- formatting
- existing tickets
- already-approved specifications
- behavior-preserving refactors

If implementation is obvious,

implement immediately.

---

## Expected Behaviour

The agent should actively challenge ideas.

Do **not** seek agreement.

Instead:

- identify hidden assumptions
- discover edge cases
- expose missing requirements
- compare alternative designs
- discuss trade-offs

Agreement is **not** success.

Clarity is.

---

## Expected Outputs

Possible outputs include:

- ADRs
- design notes
- glossary updates
- engineering decisions
- implementation strategy

The exact artifact is less important than reducing uncertainty.

---

## Exit Criteria

Do not leave grill until:

✓ major assumptions are explicit

✓ architecture is understood

✓ edge cases have been discussed

✓ trade-offs are documented

✓ implementation path is obvious

---

## Anti-Patterns

Never:

❌ defend the first solution

❌ accept vague requirements

❌ skip difficult questions

❌ begin implementation during discussion

---

# /to-spec

## Purpose

A specification records engineering decisions.

It does **not** discover them.

Discovery belongs to grill.

---

## When To Use

Create a specification only after:

- important decisions have been made
- uncertainty has been removed
- implementation direction is agreed

---

## What A Good Specification Contains

A specification should explain:

- objectives

- scope

- constraints

- non-goals

- acceptance criteria

- implementation overview

It should describe **what** will be built.

Not every implementation detail.

---

## What A Specification Should NOT Contain

Avoid:

- brainstorming

- open questions

- unfinished ideas

- implementation diary

The specification should represent an engineering agreement.

---

## Exit Criteria

A developer should be able to implement the work without asking additional architectural questions.

---

# /to-tickets

## Purpose

Tickets coordinate execution.

They do not improve engineering decisions.

Those decisions already exist.

---

## When To Use

Use tickets only when:

- work naturally decomposes
- implementation spans multiple milestones
- parallel work is possible
- independent review is valuable

---

## Ticket Characteristics

Every ticket should be:

- independently implementable

- independently testable

- independently reviewable

- clearly scoped

Avoid creating "mega tickets."

---

## Dependencies

Dependencies should be explicit.

A ticket should never depend on implicit engineering knowledge.

---

## Exit Criteria

The entire implementation should be executable one ticket at a time.

---

## Anti-Patterns

Do not create tickets:

- because process requires them

- for one-hour tasks

- for mechanical changes

---

# /implement

## Purpose

Transform an agreed solution into production-quality code.

Implementation is execution.

Not discovery.

---

## Preconditions

Implementation should begin only after:

- the workflow level has been selected

- repository architecture has been understood

- similar implementations have been reviewed

- existing abstractions have been searched

---

## Repository First

Before writing code:

Search the repository.

Prefer extending existing modules.

Avoid parallel implementations.

---

## Behavior Preservation

Unless explicitly requested,

behavior should remain unchanged.

Improve:

- readability

- maintainability

- modularity

without changing observable behavior.

---

## Incremental Changes

Prefer:

small,

reviewable,

focused commits.

Avoid:

large,

monolithic implementations.

---

## Implementation Checklist

During implementation:

✓ reuse existing abstractions

✓ use `/tdd` whenever practical

✓ run ShellCheck on modified scripts

✓ typecheck frequently

✓ execute targeted tests continuously

✓ run the complete validation suite

✓ update documentation when necessary

✓ commit completed work

---

## Things To Avoid

Never:

❌ invent new architecture

❌ change unrelated files

❌ introduce duplicate helpers

❌ rewrite working code unnecessarily

❌ increase scope

❌ postpone obvious cleanup indefinitely

---

## Exit Criteria

Implementation is complete only when:

✓ requested behavior exists

✓ existing behavior is preserved

✓ tests pass

✓ validation succeeds

✓ code compiles (where applicable)

✓ changes are committed

---

# /code-review

## Purpose

Review validates implementation.

It does not redesign architecture.

It verifies that implementation satisfies engineering expectations.

---

## Review Axes

Every review examines two independent questions.

### Standards

Does the implementation follow repository conventions?

Examples:

- architecture

- naming

- shell style

- consistency

- modularity

---

### Specification

Does the implementation satisfy the agreed specification?

No more.

No less.

---

## Reviewer Mindset

Assume mistakes exist.

Search for them.

Do not attempt to justify implementation.

Attempt to break it.

---

## Typical Findings

Review should search for:

- missing edge cases

- duplicated code

- unnecessary abstractions

- inconsistent naming

- behavioral regressions

- hidden coupling

- poor modularity

---

## Exit Criteria

Review completes only when:

✓ Standards pass

✓ Specification pass

✓ Remaining findings are documented

---

# Skill Composition

The repository intentionally keeps Skills independent.

Typical compositions include:

Mechanical Work

```
implement

↓

code-review
```

Decision-Based Engineering

```
grill-with-docs

↓

to-spec

↓

implement

↓

code-review
```

Architectural Work

```
grill-with-docs

↓

to-spec

↓

to-tickets

↓

implement

↓

code-review
```

Remember:

Skills are reusable.

The workflow exists to combine them appropriately.

Never execute additional skills unless they provide engineering value.

---

# 4. Repository Engineering Policy

This repository is not merely a collection of scripts.

It is a long-lived engineering project.

Every contribution should improve the repository without making future contributions harder.

The objective is sustainable evolution.

Not short-term implementation speed.

---

# Repository First

Before creating new code,
understand the existing code.

Always search the repository before introducing:

- helper functions
- utility scripts
- abstractions
- configuration systems
- module layouts
- shell libraries

Existing solutions should always be preferred over creating parallel implementations.

The repository should evolve through extension,
not duplication.

---

# Understand Before Modifying

Before modifying any module,
the agent should understand:

- why the module exists
- how it interacts with neighboring modules
- which public behavior it exposes
- which internal assumptions it relies upon

Never modify code that has not been understood.

Reading code is engineering work.

---

# Preserve Architectural Consistency

Every repository naturally develops an architectural style.

New code should reinforce that style.

Not replace it.

When multiple implementations are possible,
prefer the implementation that is most consistent with the existing repository.

Consistency reduces cognitive load.

---

# Never Introduce Parallel Patterns

One repository should have one preferred solution for each problem.

Avoid introducing:

- multiple logging systems
- multiple configuration loaders
- multiple plugin mechanisms
- multiple helper libraries
- multiple architectural styles

If an existing solution is imperfect,

improve it.

Do not replace it unless the replacement provides significant long-term value.

---

# Behavior Preservation

Refactoring should improve implementation.

Not functionality.

Unless explicitly requested otherwise,
observable behavior should remain unchanged.

Safe refactors include:

- improving readability

- reducing duplication

- reorganizing modules

- simplifying functions

- improving naming

Unsafe refactors include:

- changing execution order

- changing defaults

- changing CLI behavior

- changing configuration semantics

Unsafe refactors require engineering discussion.

---

# Refactoring Philosophy

Refactoring is not rewriting.

Refactoring is continuous improvement.

Prefer many small refactors over one massive rewrite.

Each refactor should have one clearly defined objective.

Examples:

✓ Reduce duplication

✓ Improve naming

✓ Improve modularity

✓ Simplify control flow

✓ Remove dead code

Avoid "cleanup while I'm here."

Every refactor should remain reviewable.

---

# Incremental Engineering

Large improvements should emerge through many small changes.

Small changes are:

- easier to understand

- easier to review

- easier to revert

- easier to validate

- easier to maintain

Large changes should only exist when no reasonable incremental path exists.

---

# Minimal Surface Area

Touch the fewest files necessary.

Every modified file increases:

- review complexity

- merge conflicts

- regression risk

Avoid modifying unrelated files.

Avoid opportunistic cleanup.

Avoid "while I'm here" engineering.

---

# Locality of Change

Keep related changes together.

Avoid scattering one logical change across many unrelated modules.

The implementation should have a clear center of gravity.

Future contributors should immediately understand:

"This change belongs here."

---

# Modularity

Prefer:

small modules

over

large scripts.

Prefer:

focused utilities

over

general-purpose frameworks.

Every module should have one primary responsibility.

---

# Shell Philosophy

RaVN is primarily a shell project.

Respect that identity.

Do not introduce additional languages simply because they are familiar.

Introducing another language should require a clear technical justification.

Consistency across the repository is generally more valuable than mixing technologies.

---

# Bash Engineering Standards

Shell code should be:

- predictable

- readable

- idempotent whenever practical

- correctly quoted

- defensive against failure

- compatible with repository conventions

Modified scripts should pass ShellCheck before review.

---

# Error Handling

Errors should be:

- explicit

- actionable

- understandable

Avoid silent failures.

Avoid hidden recovery logic.

Fail early when continuing would create inconsistent state.

---

# Naming

Names should communicate intent.

Avoid abbreviations.

Avoid clever names.

Prefer descriptive names over short names.

Consistency is more important than personal preference.

---

# Dependencies

Before adding a dependency ask:

Does the repository already solve this problem?

If yes,

reuse the existing solution.

If no,

justify the new dependency.

Every dependency increases long-term maintenance cost.

---

# Performance

Performance improvements should be measured.

Avoid speculative optimization.

Correctness comes first.

Maintainability comes second.

Performance comes third.

---

# Simplicity

Prefer the simplest implementation that satisfies the requirements.

Simple code is:

- easier to test

- easier to review

- easier to modify

- easier to debug

Complexity should always require justification.

---

# Documentation

Documentation should explain:

WHY

before

HOW.

Implementation details belong in code.

Engineering decisions belong in documentation.

---

# Engineering Smells

The following situations should cause the agent to pause and reconsider.

---

## Smell

"I need to modify ten unrelated files."

Question

Can this be split into smaller work?

---

## Smell

"I don't understand this module."

Question

Should I read more before changing it?

---

## Smell

"I need another helper."

Question

Does one already exist?

---

## Smell

"This architecture feels wrong."

Question

Should this begin with grill-with-docs?

---

## Smell

"I'm changing behavior during a refactor."

Question

Was this behavior change requested?

---

## Smell

"I'm touching unrelated code."

Question

Does this belong in another change?

---

# Repository Anti-Patterns

Avoid the following.

❌ Rewriting working code because a different design looks cleaner.

❌ Creating abstractions before duplication exists.

❌ Mixing unrelated refactors.

❌ Introducing parallel architectures.

❌ Expanding implementation scope during coding.

❌ Optimizing without measurement.

❌ Creating reusable code before a second use case exists.

❌ Favoring novelty over consistency.

---

# Repository Values

When trade-offs exist,
prefer the option that best preserves the following order.

1. Correctness

2. Repository consistency

3. Maintainability

4. Simplicity

5. Reuse

6. Readability

7. Performance

8. Cleverness

If an implementation improves a lower priority by harming a higher one,

it should generally be rejected.

---

# Repository Principle

The repository should become easier to understand after every change.

Never harder.

---

# 5. Engineering Execution & Definition of Done

Implementation is only one phase of engineering.

A task is not complete when code has been written.

A task is complete only when the requested change has been:

- correctly implemented
- validated
- reviewed
- documented (when necessary)
- committed
- left in a maintainable state

The repository values finished engineering—not unfinished implementation.

---

# Engineering Lifecycle

Every change should naturally progress through the following lifecycle.

```
Understand

↓

Decide

↓

Plan

↓

Implement

↓

Validate

↓

Review

↓

Complete
```

Implementation is only one stage.

Skipping later stages produces unfinished engineering.

---

# Definition of Done

A task is considered complete only when every applicable criterion has been satisfied.

Writing code alone is never sufficient.

---

## Repository Understanding

Before implementation:

✓ Existing implementation understood

✓ Similar modules reviewed

✓ Existing abstractions searched

✓ Repository conventions identified

---

## Planning

When required:

✓ Engineering uncertainty removed

✓ Architecture agreed

✓ Specification completed

✓ Tickets created (if appropriate)

---

## Implementation

Implementation should satisfy all of the following.

✓ Requested behavior implemented

✓ Existing behavior preserved

✓ Repository conventions followed

✓ No unnecessary abstractions

✓ No duplicated functionality

✓ Minimal surface area

✓ Smallest reasonable implementation

---

## Validation

The implementation should be verified before review.

Validation is evidence—not confidence.

Whenever applicable:

✓ ShellCheck passes

✓ Typecheck passes

✓ Formatter passes

✓ Unit tests pass

✓ Integration tests pass

✓ Manual verification completed

✓ Build succeeds

✓ Installation succeeds

Do not assume correctness.

Demonstrate correctness.

---

## Review

Every implementation ends with review.

Review verifies:

✓ Repository standards

✓ Specification compliance

✓ Regression risks

✓ Maintainability

✓ Readability

✓ Architectural consistency

Implementation is not complete until review has concluded.

---

## Documentation

Documentation should be updated whenever:

- behavior changes

- configuration changes

- installation changes

- user-facing functionality changes

- architectural decisions become important

Documentation should explain engineering decisions.

Not implementation details.

---

## Commit Quality

Every completed task should produce a meaningful commit.

Good commits are:

- focused

- reviewable

- atomic

- reversible

Avoid combining unrelated work.

---

# Validation Philosophy

Never trust intuition.

Trust evidence.

Evidence includes:

- passing tests

- successful builds

- successful execution

- review findings

- reproducible verification

Confidence without evidence is not engineering.

---

# Engineering Checklist

Before considering work complete, verify the following.

## Understanding

□ I understand the surrounding module.

□ I searched for existing implementations.

□ I reused existing repository patterns.

---

## Scope

□ Only relevant files were modified.

□ Scope did not expand during implementation.

□ No opportunistic refactors were introduced.

---

## Correctness

□ Requested functionality works.

□ Existing functionality still works.

□ No behavioral regressions were introduced.

---

## Quality

□ Code follows repository conventions.

□ Naming is consistent.

□ Complexity was reduced or remained unchanged.

□ No duplicate abstractions exist.

---

## Validation

□ ShellCheck passes.

□ Typecheck passes.

□ Tests pass.

□ Manual validation completed.

---

## Review

□ Code review completed.

□ Review findings resolved or documented.

---

## Completion

□ Documentation updated (if required).

□ Changes committed.

□ Repository left cleaner than before.

---

# Leave It Better

Every accepted change should improve the repository.

Improvements may include:

- clearer naming

- simpler logic

- better modularity

- improved comments

- removed duplication

- safer behavior

Do not pursue perfection.

Leave the repository slightly better than you found it.

---

# Completion Anti-Patterns

The following statements indicate incomplete engineering.

❌ "It probably works."

❌ "The tests should pass."

❌ "I didn't run ShellCheck."

❌ "The reviewer will catch it."

❌ "I changed a few unrelated things while I was here."

❌ "I'll document it later."

❌ "Someone else can clean this up."

These are signs that engineering has stopped before completion.

---

# Definition of Excellence

Excellent engineering is not measured by how much code was written.

It is measured by how confidently future contributors can understand, trust, and extend the repository.

Every completed task should leave the project:

- more understandable

- more maintainable

- more consistent

than it was before.

---

# 6. Production Review Policy

Every review should be performed as if the reviewer has the authority to approve or block a production pull request.

The purpose of review is not to validate effort.

The purpose of review is to protect the long-term quality of the repository.

Assume the implementation will become production code immediately after approval.

Review accordingly.

---

# Reviewer Mindset

The reviewer is not an assistant.

The reviewer is not a collaborator.

The reviewer is the final engineering gate before production.

Their responsibility is to protect:

- correctness
- maintainability
- repository consistency
- future contributors

Approval should only be given when confidence has been earned.

Never approve code because it "looks reasonable."

---

# Burden of Proof

The burden of proof belongs to the implementation.

Not to the reviewer.

Implementation must demonstrate that it is correct.

The reviewer should never be expected to assume correctness.

Evidence always wins over confidence.

---

# Review Philosophy

A review is an engineering investigation.

Not a conversation.

Assume defects exist.

Attempt to discover them.

Every review begins from the question:

> "Why should this change NOT be merged?"

Only after every concern has been resolved should approval be considered.

---

# Independent Verification

Do not trust implementation claims.

Verify them.

Examples:

❌ "The tests should pass."

✔ Run the tests.

---

❌ "This shouldn't affect anything."

✔ Verify affected modules.

---

❌ "The refactor is behavior preserving."

✔ Compare observable behavior.

---

# Standards Review

Every review should verify repository standards independently from correctness.

Questions include:

- Does the code follow repository conventions?

- Does it introduce new architectural patterns?

- Is naming consistent?

- Is complexity justified?

- Does it duplicate existing logic?

- Does it increase maintenance cost?

Passing tests alone is insufficient.

---

# Specification Review

Separately verify:

Did the implementation satisfy the agreed specification?

No more.

No less.

Common failures include:

- partially implemented features

- unnecessary scope expansion

- missing acceptance criteria

- undocumented behavioral changes

---

# Repository Review

Every review should ask:

Does this repository become better after this change?

Possible improvements include:

- readability

- maintainability

- consistency

- modularity

Possible regressions include:

- duplication

- hidden coupling

- unnecessary abstraction

- architectural drift

---

# Refactor Review

Behavior-preserving refactors should receive special attention.

Verify:

✓ behavior remains identical

✓ public interfaces remain compatible

✓ configuration remains compatible

✓ startup behavior remains unchanged

✓ scripts execute in the same order

Never assume behavior preservation.

Prove it.

---

# Bash Review

Every modified shell script should be reviewed for:

- quoting

- error handling

- portability (when applicable)

- ShellCheck compliance

- readability

- defensive programming

---

# Architectural Review

Whenever architecture changes:

Verify:

- responsibilities remain clear

- coupling decreases

- cohesion increases

- abstractions justify themselves

- complexity is reduced

Architecture should become simpler.

Not merely different.

---

# Engineering Smells

The following findings should trigger additional investigation.

## Smell

Large implementation.

Question

Could this have been multiple PRs?

---

## Smell

Many unrelated files modified.

Question

Has scope expanded?

---

## Smell

New abstraction introduced.

Question

Was the previous abstraction insufficient?

---

## Smell

Many comments explaining code.

Question

Could the code become simpler instead?

---

## Smell

Many conditionals.

Question

Can complexity be reduced?

---

## Smell

Duplicated logic.

Question

Can existing code be reused?

---

## Smell

Unexpected behavior changes.

Question

Were these changes requested?

---

# Review Severity

Every finding should have a severity.

## Blocker

Must be fixed before merge.

Examples:

- incorrect behavior

- regression

- broken tests

- security issue

- architecture violation

- specification violation

---

## Major

Should normally be fixed before merge.

Examples:

- unnecessary complexity

- duplicated logic

- maintainability concerns

- poor modularity

---

## Minor

Can be merged but should be addressed.

Examples:

- naming

- comments

- formatting

- documentation

---

## Suggestion

Optional improvements.

Should not block merge.

---

# Approval Criteria

Approve only if all of the following are true.

✓ Correctness demonstrated

✓ Repository standards respected

✓ Specification satisfied

✓ No significant regressions

✓ Maintainability preserved

✓ Complexity justified

✓ Review findings resolved

If any item fails,

do not approve.

---

# Blocking Philosophy

Blocking a PR is not failure.

Blocking protects the repository.

Reject implementations when:

- uncertainty remains

- correctness has not been demonstrated

- repository quality decreases

- maintainability regresses

- unnecessary complexity is introduced

The cost of rejecting a poor implementation is far lower than maintaining it for years.

---

# Final Question

Before approving any implementation, ask:

> Would I be comfortable maintaining this code for the next five years?

If the answer is anything other than an unambiguous "yes",

the review is not finished.