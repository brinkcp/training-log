# Requests

**Written by the trainer AI. Claude Code reads this and does not edit it.**

This is where changes to the app get asked for. You and the trainer agree what you
want; the trainer writes it here; Claude Code builds it and reports back in
`CHANGELOG.md`.

## How to write a request

Add a new entry **at the top**, under the divider. Never edit or delete an existing
one — the history is the point.

```markdown
### 2026-08-10-shorthand-slug
**Want:** one sentence on what should change.
**Why:** what it's for — this matters more than the how.
**Priority:** normal | urgent
```

**Say what you want, not how to build it.** "Readiness should be out of 5, because 10
options is too many to think about mid-session" is a good request. "Change `max` to 5
in the scale function" is not — it names one line and misses the four other places
that need to agree, plus the docs.

Claude Code replies in `CHANGELOG.md`, referencing the slug. If something can't be
done as asked, or the request has a consequence worth knowing about, that's where it
says so. Check there before assuming a request was ignored.

## Emergency changes

The trainer keeps write access to everything for emergencies — a broken page on a
training morning shouldn't wait.

**If you change any file other than `program.json`, log it here** under
`### EMERGENCY <date>`, saying what you changed and why. Otherwise the next person to
touch that code has no idea it moved, and the change gets silently undone.

Publishing a new week in `program.json` is normal work, not an emergency, and needs
no entry here.

---

### 2026-08-10-initial
**Want:** Nothing yet — this file is new.
**Why:** Establishing the handoff so app changes stop being made blind.
**Priority:** normal
