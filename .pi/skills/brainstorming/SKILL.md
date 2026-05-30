---
name: brainstorming
description: "You MUST use this before any creative work — explores user intent, requirements, and design before implementation. Ask clarifying questions, propose approaches, write a spec, and get user approval."
---

# Brainstorming Ideas Into Designs

Help turn ideas into fully formed designs and specs through natural collaborative dialogue.

Start by understanding the current project context, then ask questions one at a time to refine the idea. Once you understand what you're building, present the design and get user approval.

<HARD-GATE>
Do NOT write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it. This applies to EVERY project regardless of perceived simplicity.
</HARD-GATE>

## Checklist

Complete these in order:

1. **Explore project context** — check files, docs, recent commits
2. **Ask clarifying questions** — one at a time, understand purpose/constraints/success criteria
   - Use the `ask_user` tool to ask multiple-choice questions
   - Only one question per message
   - Focus on: purpose, constraints, success criteria, target users, core functionality
3. **Assess scope** — if the request describes multiple independent subsystems, flag it immediately. Help the user decompose into smaller sub-projects before proceeding with the first one.
4. **Propose 2-3 approaches** — with trade-offs and your recommendation. Lead with your recommended option.
5. **Present design** — in sections scaled to their complexity (a few sentences to 200-300 words). Cover: architecture, components, data flow, error handling, testing. Get approval after each section.
6. **Write spec** — save to a project spec file (ask user for preferred path or use default). Commit if in a git repo.
7. **Self-review the spec** — check for:
   - Placeholders (TBD, TODO, incomplete sections)
   - Internal consistency (do sections contradict each other?)
   - Scope (focused enough for one implementation plan?)
   - Ambiguity (could any requirement be interpreted two ways?)
   Fix any issues found.
8. **User review** — ask the user to review the spec file before proceeding:
   > "Spec written to `<path>`. Please review it and let me know if you want any changes."
   Wait for response. If changes requested, fix them and re-run self-review.
9. **Transition** — ask if the user wants to proceed to implementation planning.

## Key Principles

- **One question at a time** — Don't overwhelm with multiple questions
- **Multiple choice preferred** — Use `ask_user` with options when possible
- **YAGNI ruthlessly** — Remove unnecessary features from all designs
- **Explore alternatives** — Always propose 2-3 approaches before settling
- **Incremental validation** — Present design, get approval before moving on
- **Be flexible** — Go back and clarify when something doesn't make sense
