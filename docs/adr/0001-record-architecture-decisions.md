# 1. Record Architecture Decisions

Date: 2026-09-12

## Status

Accepted

## Context

We need to record the architectural decisions made on the YieldPoint platform so
that current and future team members can understand why the system is built the
way it is.

Architecture Decision Records (ADRs) provide a lightweight way to capture the
context, reasoning, and trade-offs behind significant technical choices. Without
them, knowledge lives only in people's heads and gets lost with team turnover.

## Decision

We will use Architecture Decision Records as described by Michael Nygard in
his article "Documenting Architecture Decisions"
(https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions).

Each ADR will:
- Be numbered sequentially (0001, 0002, ...).
- Live in `docs/adr/` in the repository root.
- Follow the template in `docs/adr/template.md`.
- Be immutable once accepted — superseded decisions get a new ADR that
  references the old one rather than editing the original.

## Consequences

- Every significant architectural choice will have a written record.
- New team members can read the ADR log to understand the rationale behind the
  system's design.
- The ADR directory becomes a living log that grows with the project.
- We accept the small overhead of writing an ADR for each decision, which is
  offset by the clarity it provides during reviews and onboarding.
