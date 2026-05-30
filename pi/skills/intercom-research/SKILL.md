---
name: intercom-research
description: Research protocol for subagents to request fact verification via intercom. Verification only — never exploration.
---

## Research via Intercom

When you need a fact verified that requires web search or external documentation:

```
intercom({ action: "ask", to: "[SESSION]",
  message: "RESEARCH: {specific question}. Official docs. Verified facts with source URLs." })
```

**Rules:**
- **Verification only** — answer the specific question. Never explore alternatives.
- **Official sources** — prefer pub.dev, api.flutter.dev, Google API docs, Android developer docs.
- **Cite URLs** — include source links in your answer.
- **If unsure** — say so. Don't guess.
- **Be quick** — the agent asking is blocked waiting.
