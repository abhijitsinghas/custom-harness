---
name: writing-plans
description: Creates detailed, bite-sized implementation plans from approved specs. Use when you have a spec or requirements for a multi-step task, before touching code.
---

# Writing Plans

Write comprehensive implementation plans with bite-sized tasks (2-5 minutes each).

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Save plans to:** Ask the user for their preferred plan location, or use a sensible default.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. Each file should have one clear responsibility.

## Task Structure

Each step is one action (2-5 minutes):
- Write the failing test
- Run it to verify it fails
- Write minimal implementation
- Run tests to verify they pass
- Commit (if user wants commits in the plan)

### Header (required)

```markdown
# [Feature Name] Implementation Plan

**Goal:** [One sentence]
**Architecture:** [2-3 sentences]
**Tech Stack:** [Key technologies]

---
```

### Task format

```markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

**Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL

**Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

**Step 4: Run tests to verify they pass**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS
```

## No Placeholders

Never write these in a plan:
- TBD, TODO, "implement later"
- "Add validation" without showing the validation code
- "Write tests" without showing the test code
- "Similar to Task N" — repeat the code
- References to types/functions not defined in any task

## Quality Checklist (Self-Review)

After writing the plan, check:
1. **Spec coverage** — Can you point to a task for each requirement? Fix gaps.
2. **Placeholder scan** — Any TBD, vague steps, or missing code? Fix them.
3. **Consistency** — Do method signatures and types match across tasks? Fix mismatches.
4. **Completeness** — Are file paths exact? Are test commands specific with expected output?

## Execution Handoff

After saving the plan, offer the user a choice:
> "Plan complete at `<path>`. Want me to start implementation, or would you like to review the plan first?"
